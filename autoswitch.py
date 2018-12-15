import RPi.GPIO as GPIO
import requests
from requests.auth import HTTPDigestAuth

GPIO.setmode(GPIO.BCM)
GPIO.setup(13, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
user = 'admin'
password = 'Password'
camera_ip = 'http://192.168.1.201'
camera_uri = camera_ip + '/cgi-bin/rainBrush.cgi?action='
start_wiper_url = camera_uri + 'moveContinuously&interval=1[&channel=1]'
stop_wiper_url = camera_uri + 'stopMove[&channel=1]'
current_state = "tracking"

while True:
    if(GPIO.input(13)):
        if(current_state == "tracking"):
            try:
                print(requests.get(stop_wiper_url,
                                   auth=HTTPDigestAuth(user, password)))
                current_state = "not-tracking"
            except:
                print("ip not found")
        else:
            try:
                print(requests.get(start_wiper_url,
                                   auth=HTTPDigestAuth(user, password)))
                current_state = "tracking"
            except:
                print("ip not found")
        print(current_state)
