from gpiozero import DigitalInputDevice
import RPi.GPIO as GPIO
import time


MQ2_PIN = 4
BUZZER_PIN = 18

GPIO.setmode(GPIO.BCM)
GPIO.setup(BUZZER_PIN, GPIO.OUT)


mq2 = DigitalInputDevice(MQ2_PIN)

def alert():
    for _ in range(10):
        GPIO.output(BUZZER_PIN, GPIO.HIGH)
        time.sleep(0.1)
        GPIO.output(BUZZER_PIN, GPIO.LOW)
        time.sleep(0.1)

try:
    while True:
        if mq2.value == 0:
            print("gas detected!")
            alert()
        else:
            print("no gas detected.")

        time.sleep(1)

except KeyboardInterrupt:
    print("exiting program.")
    GPIO.cleanup()


