import RPi.GPIO as GPIO
import time
from mqtt import client  # your existing MQTT client

BUTTON_PIN = 25  # GPIO25

# Set up GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

def AudioPlayer():
    # When button is pressed, the input reads LOW
    if GPIO.input(BUTTON_PIN) == GPIO.HIGH:
        print("Button Pressed!")
        client.publish("what is that artifact?", "BUTTON PRESSED")
        time.sleep(5)  # wait to avoid multiple triggers


while True:
        AudioPlayer()
        time.sleep(0.1)  # small delay to reduce CPU usage


