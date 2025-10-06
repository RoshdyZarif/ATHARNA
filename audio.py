from gpiozero import Button
from mqtt import client
from time import sleep


button = Button(25)

def AudioPlayer():
    if not button.is_pressed:
        client.publish("what is that artifact?", "BUTTON PRESSED") 
        sleep(5)

while True:
    AudioPlayer()
