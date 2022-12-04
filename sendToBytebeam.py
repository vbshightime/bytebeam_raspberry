import socket
import json
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    s.connect(("localhost", 5555))
except Exception as err:
    print(err)

def send_data(s, sequence):
    t = int(time.time()*1000)
    data = { "stream": "demo", "sequence": sequence, "timestamp": t, "state":1}
    send = json.dumps(data) + "\n"
    s.sendall(bytes(send, encoding="utf-8"))

counter = 1

while True:
    time.sleep(5)
    send_data(s, counter)
    print(counter)
    counter += 1
