import RPi.GPIO as GPIO
import time
from mqtt import client  # your existing MQTT client

BUTTON_PIN = 22  # GPIO25

# Set up GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

def AudioPlayer():
    
    while True:
        # When button is pressed, the input reads LOW
        if GPIO.input(BUTTON_PIN) == GPIO.HIGH:
            print("Button Pressed for sound!")
            client.publish("what is that artifact?", "BUTTON PRESSED")
            time.sleep(2)  # wait to avoid multiple triggers

        time.sleep(0.1)  # small delay to reduce CPU usage
   
