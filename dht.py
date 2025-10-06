import adafruit_dht
import board
from time import sleep
from mqtt import client

dht_device = adafruit_dht.DHT11(board.D18) 

def tempAndHumi():
        temperature_c = dht_device.temperature
        sleep(0.1)
        client.publish("temperature", temperature_c, qos = 2)
        humidity = dht_device.humidity
        sleep(0.1)
        client.publish("humidity", humidity, qos = 2) 
