import threading
from time import sleep
from tempL import calepration, LoadTheftDetection
from NFCandSERVOandButton import setupNFC
from audio import AudioPlayer
from gasSensor import gas
from dht import tempAndHumi
from ultrasonicAlarm import AlarmSystemUs



calepration()
setupNFC()





threading.Thread(target=LoadTheftDetection, daemon=True).start()
threading.Thread(target=AudioPlayer, daemon=True).start()
threading.Thread(target=gas, daemon=True).start()
threading.Thread(target=tempAndHumi, daemon=True).start()
threading.Thread(target=AlarmSystemUs, daemon=True).start()


while True:

    sleep(10)
