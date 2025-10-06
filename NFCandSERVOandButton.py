from pn532pi import Pn532Spi, Pn532
from time import sleep
from gpiozero import LED,AngularServo,Button
from mqtt import client

#glopal variable
NumOfVisitors = 0

# Initialize SPI interface
spi = Pn532Spi(Pn532Spi.SS0_GPIO8)
spi._speed = 500000
nfc = Pn532(spi)
button2 = Button(22)
servo = AngularServo(17,min_angle = 0, max_angle = 180)
def setup():
    nfc.begin()
    version = nfc.getFirmwareVersion()
    if not version:
        print("Didn't find PN532 board")
        return
    print(f"Found PN532 with firmware version: {version >> 24}.{(version >> 16) & 0xFF}")
    nfc.SAMConfig()

def readingNFCandCountVisitor():
    global NumOfVisitors 
    print("Waiting for an NFC card...")
    status, uid = nfc.readPassiveTargetID(0x00)
    if status and len(uid) > 0:
         servo.angle = 180
         sleep(2)
         servo.angle = 0
         NumOfVisitors = NumOfVisitors + 1
    if not button2.is_pressed:
         servo.angle = 180
         sleep(2)
         servo.angle = 0
         NumOfVisitors = NumOfVisitors - 1

    client.publish("NumOfVisitors",NumOfVisitors) 

