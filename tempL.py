import RPi.GPIO as GPIO
from hx711 import HX711
import time

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

# Initialize HX711
hx = HX711(dout_pin=27, pd_sck_pin=21)

# Tare (zero)
print("Taring... Remove all weight.")
hx.zero()

input("Place known weight and press Enter...")
reading = hx.get_data_mean(readings=100)
known_weight = float(input("Enter known weight in grams: "))

# Calculate and set scale ratio
ratio = reading / known_weight
hx.set_scale_ratio(ratio)
print(f"Scale ratio set to: {ratio}")

# Read continuously
print("\nStarting weight readings...\n")
while True:
    weight = hx.get_weight_mean(readings=10)
    print(f"Weight: {weight:.2f} g")
    time.sleep(0.5)

