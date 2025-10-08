import adafruit_dht
import board
from time import sleep
from mqtt import client

# Initialize DHT11 on GPIO18
dht_device = adafruit_dht.DHT11(board.D18)

def tempAndHumi():
    global dht_device  # ✅ ensure function uses the global variable
    while True:
        try:
            # Read temperature
            temperature_c = dht_device.temperature
            sleep(0.1)
            if temperature_c is not None:
                client.publish("temperature", temperature_c, qos=2)

            # Read humidity
            humidity = dht_device.humidity
            sleep(0.1)
            if humidity is not None:
                client.publish("humidity", humidity, qos=2)

        except RuntimeError:
            # Common DHT read failure — just retry
            sleep(2)
            continue

        except Exception:
            # Unexpected issue — reset sensor and retry
            dht_device.exit()
            sleep(2)
            dht_device = adafruit_dht.DHT11(board.D18)

        sleep(2)


