from gpiozero import DigitalInputDevice
import RPi.GPIO as GPIO
import time
from mqtt import client

MQ2_PIN = 25
BUZZER_PIN = 14

GPIO.setmode(GPIO.BCM)
GPIO.setup(BUZZER_PIN, GPIO.OUT)

mq2 = DigitalInputDevice(MQ2_PIN)

def alert():
    for _ in range(10):
        GPIO.output(BUZZER_PIN, GPIO.HIGH)
        time.sleep(0.1)
        GPIO.output(BUZZER_PIN, GPIO.LOW)
        time.sleep(0.1)

def gas():
   
    while True:
        if mq2.value == 0:
            alert()
            client.publish("GasLevel", "DANGER")
        else:
            client.publish("GasLevel", "SAFE")
        time.sleep(0.1)
    
