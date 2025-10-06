import adafruit_dht
import board
import time
from mqtt import client

dht_device = adafruit_dht.DHT11(board.D18) 

def tempAndHumi():
        temperature_c = dht_device.temperature
        client.publish("temperature", temperature_c)
        humidity = dht_device.humidity
        client.publish("humidity", humidity)
        print(f"Temperature: {temperature_c:.2f}°C")
        print(f"Humidity: {humidity:.2f}%")
        time.sleep(2)

tempAndHumi()
