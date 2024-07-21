import time
import datetime

while True:
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with open("/usr/share/nginx/html/myclock.html", "w") as file:
        file.write(f"<html><body><h1>{current_time}</h1></body></html>")

    time.sleep(2)