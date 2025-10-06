from pn532pi import Pn532Spi, Pn532
from time import sleep
from gpiozero import LED,AngularServo

# Initialize SPI interface
spi = Pn532Spi(Pn532Spi.SS0_GPIO8)  # SS0_GPIO8 is GPIO8 (CE0)
nfc = Pn532(spi)
led = LED(5)
servo = AngularServo(17,min_angle = 0, max_angle = 180)
def setup():
    nfc.begin()
    version = nfc.getFirmwareVersion()
    if not version:
        print("Didn't find PN532 board")
        return
    print(f"Found PN532 with firmware version: {version >> 24}.{(version >> 16) & 0xFF}")
    nfc.SAMConfig()

def loop():
    print("Waiting for an NFC card...")
    while True:
        status, uid = nfc.readPassiveTargetID(0x00)
        if status and len(uid) > 0:
            servo.angle = 180
            sleep(2)
            servo.angle = 0

if __name__ == "__main__":
    setup()
    loop()

