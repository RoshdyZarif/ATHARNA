import paho.mqtt.client as mqtt
import ssl

url = "1b1c9d84f86c4aa3bcd838e17d625aba.s1.eu.hivemq.cloud"
port = 8883
username = "ATHARNA"
password = "Atharna12345678"
def on_connect(client, user, flags, reason_code, properties):
    print(f"connected with result code {reason_code}")

client = mqtt.Client(client_id="anid",
                     protocol=mqtt.MQTTv5,
                     callback_api_version=mqtt.CallbackAPIVersion.VERSION2)
client.tls_set(tls_version=ssl.PROTOCOL_TLS)
client.username_pw_set(username, password)
client.on_connect = on_connect
client.connect(url, port)
client.loop_start()

