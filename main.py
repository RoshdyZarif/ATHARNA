#!/usr/bin/env python3
"""
main.py  (PyQt5 Museum Dashboard)

Layout requested:
[Temperature]  [Humidity]
[Visitors + Reset]
[Gas] + Status

Features:
- Real DHT11 on GPIO18 (adafruit_dht)
- MQ2 digital on GPIO4 with buzzer on GPIO23
- PN532 NFC via pn532pi (SPI CE0 / GPIO8), LED on GPIO5, AngularServo on GPIO17
- English-only UI, simple modern cards, single-pane layout
- Status label shows "Status: OK" normally, changes to alarm when gas detected

How to run:
    python3 pyqt_museum_dashboard.py

Place this file in your project directory. Make sure your venv has PyQt5 installed.
If sensor libraries are missing the program will raise runtime errors where appropriate.

"""

import sys
import time
import threading
from functools import partial
from PyQt5 import QtCore, QtGui, QtWidgets

# -------------------------
# Configuration
# -------------------------
POLL_INTERVAL_SEC = 1.0  # seconds

# -------------------------
# Hardware integration functions (clear and separate)
# Replace / adapt pins or library use if your hardware differs
# -------------------------

# --- DHT (DHT11 on GPIO18) ---
def read_dht():
    """Read DHT11 using adafruit_circuitpython_dht. Return (temp_c: float, hum_pct: float).
    Raises RuntimeError on failure so the worker can handle it.
    """
    try:
        import board
        import adafruit_dht
    except Exception as e:
        raise RuntimeError(f"DHT libraries not available: {e}")

    global _dht_device
    try:
        _dht_device
    except NameError:
        # create once
        _dht_device = adafruit_dht.DHT11(board.D18)

    try:
        t = _dht_device.temperature
        h = _dht_device.humidity
        if t is None or h is None:
            raise RuntimeError("DHT returned None")
        # optional MQTT publish (if you have mqtt.client)
        try:
            from mqtt import client as mqtt_client
            try:
                mqtt_client.publish('temperature', float(t))
                mqtt_client.publish('humidity', float(h))
            except Exception:
                pass
        except Exception:
            pass
        return float(t), float(h)
    except Exception as e:
        raise RuntimeError(f"Failed to read DHT: {e}")


# --- Gas (MQ2) digital read on GPIO4, buzzer on GPIO23 ---
def init_gas_hardware():
    """Initialize MQ2 and buzzer hardware objects. Called lazily."""
    global _mq2, _buzzer_pin_inited
    try:
        _mq2
    except NameError:
        try:
            from gpiozero import DigitalInputDevice
            _mq2 = DigitalInputDevice(4)  # MQ2_PIN
        except Exception as e:
            raise RuntimeError(f"MQ2 (gpiozero) not available: {e}")

    try:
        import RPi.GPIO as GPIO
        if not globals().get('_buzzer_pin_inited', False):
            BUZZER_PIN = 23
            GPIO.setmode(GPIO.BCM)
            GPIO.setup(BUZZER_PIN, GPIO.OUT)
            globals()['_buzzer_pin'] = BUZZER_PIN
            globals()['_buzzer_pin_inited'] = True
    except Exception:
        # If RPi.GPIO is unavailable we continue without buzzer
        pass


def read_gas():
    """Return True if gas detected (digital logic: mq2.value == 0), False otherwise.
    Also performs a short buzzer sound when gas is detected.
    Raises RuntimeError if MQ2 cannot be read.
    """
    try:
        init_gas_hardware()
    except Exception as e:
        raise RuntimeError(f"Gas init failed: {e}")

    try:
        detected = (_mq2.value == 0)
    except Exception as e:
        raise RuntimeError(f"Failed to read MQ2: {e}")

    if detected:
        # buzzer short pattern (non-blocking small delays acceptable)
        try:
            import RPi.GPIO as GPIO
            buz_pin = globals().get('_buzzer_pin')
            if buz_pin is not None:
                for _ in range(3):
                    GPIO.output(buz_pin, GPIO.HIGH)
                    time.sleep(0.08)
                    GPIO.output(buz_pin, GPIO.LOW)
                    time.sleep(0.08)
        except Exception:
            pass

    return detected


# --- NFC / PN532 + Servo + LED ---
def start_nfc_listener(on_tag_callback):
    """Start background thread polling PN532. Calls on_tag_callback() when a tag is read.
    Also toggles LED on GPIO5 and moves AngularServo on GPIO17 (if available).
    """
    def _nfc_loop():
        try:
            from pn532pi import Pn532Spi, Pn532
        except Exception:
            # PN532 not installed; just exit thread silently
            return

        try:
            spi = Pn532Spi(Pn532Spi.SS0_GPIO8)  # CE0 / GPIO8
            nfc = Pn532(spi)
            nfc.begin()
            version = nfc.getFirmwareVersion()
            if not version:
                return
            nfc.SAMConfig()
        except Exception:
            return

        # optional hardware feedback
        led = None
        servo = None
        try:
            from gpiozero import LED, AngularServo
            led = LED(5)
            try:
                servo = AngularServo(17, min_angle=0, max_angle=180)
            except Exception:
                servo = None
        except Exception:
            led = None
            servo = None

        while True:
            try:
                status, uid = nfc.readPassiveTargetID(0x00)
                if status and uid and len(uid) > 0:
                    # call main UI callback
                    try:
                        on_tag_callback()
                    except Exception:
                        pass
                    # LED blink and servo sweep
                    try:
                        if led:
                            led.blink(on_time=0.1, off_time=0.1, n=3)
                    except Exception:
                        pass
                    try:
                        if servo:
                            servo.angle = 180
                            time.sleep(1.5)
                            servo.angle = 0
                    except Exception:
                        pass
                time.sleep(0.5)
            except Exception:
                time.sleep(1.0)

    t = threading.Thread(target=_nfc_loop, daemon=True)
    t.start()
    return t


# -------------------------
# Sensor worker thread (polls DHT & gas)
# -------------------------
class SensorWorker(QtCore.QObject):
    updated = QtCore.pyqtSignal(float, float, bool)
    # emits: temp_c, hum_pct, gas_alarm

    def __init__(self, parent=None):
        super().__init__(parent)
        self._running = False
        self._thread = None

    def start(self):
        if self._thread is None:
            self._running = True
            self._thread = threading.Thread(target=self._run, daemon=True)
            self._thread.start()

    def stop(self):
        self._running = False
        if self._thread is not None:
            self._thread.join(timeout=1.0)
            self._thread = None

    def _run(self):
        while self._running:
            try:
                t, h = read_dht()
            except Exception:
                t, h = None, None
            try:
                gas = read_gas()
            except Exception:
                gas = False

            tval = t if t is not None else -1.0
            hval = h if h is not None else -1.0
            self.updated.emit(tval, hval, bool(gas))
            time.sleep(POLL_INTERVAL_SEC)


# -------------------------
# GUI: single-pane layout per user spec
# -------------------------
class Dashboard(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Museum Dashboard")
        self.resize(640, 360)

        main = QtWidgets.QVBoxLayout(self)
        # Top row: Temperature and Humidity side-by-side
        top_row = QtWidgets.QHBoxLayout()
        main.addLayout(top_row)

        self.temp_card = self._make_card()
        self.temp_title = QtWidgets.QLabel("Temperature")
        self.temp_title.setFont(QtGui.QFont('Arial', 10))
        self.temp_value = QtWidgets.QLabel("-- °C")
        self.temp_value.setFont(QtGui.QFont('Arial', 28, QtGui.QFont.Bold))
        self.temp_card.layout().addWidget(self.temp_title)
        self.temp_card.layout().addWidget(self.temp_value)
        top_row.addWidget(self.temp_card)

        self.hum_card = self._make_card()
        self.hum_title = QtWidgets.QLabel("Humidity")
        self.hum_title.setFont(QtGui.QFont('Arial', 10))
        self.hum_value = QtWidgets.QLabel("-- %")
        self.hum_value.setFont(QtGui.QFont('Arial', 28, QtGui.QFont.Bold))
        self.hum_card.layout().addWidget(self.hum_title)
        self.hum_card.layout().addWidget(self.hum_value)
        top_row.addWidget(self.hum_card)

        # Visitors card (full-width below)
        self.vis_card = self._make_card()
        self.vis_title = QtWidgets.QLabel("Visitors")
        self.vis_title.setFont(QtGui.QFont('Arial', 10))
        self.vis_count = QtWidgets.QLabel('0')
        self.vis_count.setFont(QtGui.QFont('Arial', 28, QtGui.QFont.Bold))
        # reset button sits inside same card (right side)
        vis_h = QtWidgets.QHBoxLayout()
        left_v = QtWidgets.QVBoxLayout()
        left_v.addWidget(self.vis_title)
        left_v.addWidget(self.vis_count)
        vis_h.addLayout(left_v)
        self.reset_btn = QtWidgets.QPushButton('Reset Visitors')
        self.reset_btn.clicked.connect(self.reset_visitors)
        vis_h.addStretch()
        vis_h.addWidget(self.reset_btn)
        self.vis_card.layout().addLayout(vis_h)
        main.addWidget(self.vis_card)

        # Gas card + Status (full-width)
        self.gas_card = self._make_card()
        gas_h = QtWidgets.QHBoxLayout()
        gas_left = QtWidgets.QVBoxLayout()
        self.gas_title = QtWidgets.QLabel('Gas')
        self.gas_title.setFont(QtGui.QFont('Arial', 10))
        self.gas_state = QtWidgets.QLabel('Safe')
        self.gas_state.setFont(QtGui.QFont('Arial', 16, QtGui.QFont.Bold))
        gas_left.addWidget(self.gas_title)
        gas_left.addWidget(self.gas_state)
        gas_h.addLayout(gas_left)
        gas_h.addStretch()
        # status label on the right
        self.status_label = QtWidgets.QLabel('Status: OK')
        self.status_label.setFont(QtGui.QFont('Arial', 12))
        gas_h.addWidget(self.status_label)
        self.gas_card.layout().addLayout(gas_h)
        main.addWidget(self.gas_card)

        # setup sensor worker and NFC
        self.worker = SensorWorker()
        self.worker.updated.connect(self.on_sensor_update)
        self.worker.start()

        self.visitors = 0
        start_nfc_listener(self.on_nfc_tag)

    def _make_card(self):
        frame = QtWidgets.QFrame()
        frame.setFrameShape(QtWidgets.QFrame.StyledPanel)
        frame.setStyleSheet("QFrame { background: #f7f7f8; border-radius: 8px; padding: 10px; }")
        layout = QtWidgets.QVBoxLayout(frame)
        # attach a helper method to retrieve the layout
        frame.layout = lambda: layout
        return frame

    @QtCore.pyqtSlot(float, float, bool)
    def on_sensor_update(self, t, h, gas_alarm):
        # update temp/hum display
        if t >= -0.5:
            self.temp_value.setText(f"{t:.1f} °C")
        else:
            self.temp_value.setText("-- °C")

        if h >= 0.0:
            self.hum_value.setText(f"{h:.0f} %")
        else:
            self.hum_value.setText("-- %")

        if gas_alarm:
            self.gas_state.setText('ALARM')
            self.gas_state.setStyleSheet('color: red;')
            self.status_label.setText('Status: GAS ALARM!')
        else:
            self.gas_state.setText('Safe')
            self.gas_state.setStyleSheet('color: green;')
            self.status_label.setText('Status: OK')

    def on_nfc_tag(self):
        self.visitors += 1
        self.vis_count.setText(str(self.visitors))

    def reset_visitors(self):
        self.visitors = 0
        self.vis_count.setText(str(self.visitors))

    def closeEvent(self, event):
        try:
            self.worker.stop()
        except Exception:
            pass
        super().closeEvent(event)


# -------------------------
# Entrypoint
# -------------------------

def main():
    app = QtWidgets.QApplication(sys.argv)
    win = Dashboard()
    win.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()

