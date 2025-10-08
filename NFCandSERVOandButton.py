from pn532pi import Pn532Spi, Pn532
from time import sleep
from gpiozero import LED, AngularServo, Button
import RPi.GPIO as GPIO
from mqtt import client

# Global variable
NumOfVisitors = 0

# ---------------- NFC SETUP ----------------
spi = Pn532Spi(Pn532Spi.SS0_GPIO8)
spi._speed = 500000
nfc = Pn532(spi)

# ---------------- BUTTON SETUP ----------------
button = Button(4) # physical button pin
#GPIO.setmode(GPIO.BCM)
#GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)  # <-- pull-down resistor

# ---------------- SERVO SETUP ----------------
servo = AngularServo(17, min_angle=0, max_angle=180)

# ---------------- NFC FUNCTIONS ----------------
def setupNFC():
    nfc.begin()
    version = nfc.getFirmwareVersion()
    if not version:
        print("Didn't find PN532 board")
        return
    print(f"Found PN532 with firmware version: {version >> 24}.{(version >> 16) & 0xFF}")
    nfc.SAMConfig()

def readingNFCandCountVisitor():
    
    
        global NumOfVisitors

        status, uid = nfc.readPassiveTargetID(0x00)
        if status and len(uid) > 0:
            servo.angle = 180
            sleep(2)
            servo.angle = 0
            NumOfVisitors += 1
        # Button check (pull-down → reads HIGH when pressed)
        if  button.is_pressed:
             print("button pressed")
             servo.angle = 180
             sleep(2)
             servo.angle = 0
             NumOfVisitors -= 1

        client.publish("NumOfVisitors", NumOfVisitors)
        sleep(0.1)

    
      
