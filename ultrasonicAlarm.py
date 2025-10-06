from gpiozero import DistanceSensor, Buzzer, LED
import RPi.GPIO as GPIO
from time import sleep
from mqtt import client


Ultra1 = DistanceSensor(20, 16)
Ultra2 = DistanceSensor(26, 19) 
Ultra3 = DistanceSensor(13, 6) 
Ultra4 = DistanceSensor(23, 24) 
LED1 = LED(5)

TempDist = 10

def AlarmSystemUs():
    TempDist = 80
    Distance1 = Ultra1.distance *100
    Distance2 = Ultra2.distance *100 
    Distance3 = Ultra3.distance *100 
    Distance4 = Ultra4.distance *100 
    TotalDist = Distance1 + Distance2 + Distance3 + Distance4
    
    print(TotalDist)
    
    if TotalDist < TempDist:
        #LED.on()
        LED1.on()
        SomeOneCrosed=1
        client.publish("AlarmToSec", SomeOneCrosed)
        SomeOneCrosed=0
        #send email to the security
        sleep(5)
        LED1.off()

while True :
	AlarmSystemUs()


