import RPi.GPIO as GPIO
from hx711 import HX711
import time
from mqtt import client
from NFCandSERVOandButton import readingNFCandCountVisitor

GPIO.setwarnings(False)


# Initialize HX711
GPIO.cleanup()
GPIO.setmode(GPIO.BCM)
hx = HX711(dout_pin=27, pd_sck_pin=21)

# Tare (zero)
def calepration():
    print("Taring... Remove all weight.")
    hx.zero()

    input("Place known weight and press Enter...")
    reading = hx.get_data_mean(readings=100)

    known_weight = float(input("Enter known weight in grams: "))

    # Calculate and set scale ratio
    ratio = reading / known_weight
    hx.set_scale_ratio(ratio)
    

# Read continuously
def LoadTheftDetection():
    while True:      
  
        print("\nStarting weight readings...\n")

        weight = hx.get_weight_mean(readings=10)
        print(weight)
        if weight >= 200:
            readingNFCandCountVisitor()
            
        else:
             client.publish("bara2 again!!?", "THEFT DETECTED", qos=2)
             time.sleep(5)

        
