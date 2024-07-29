import time
import datetime
import os


def get_current_time(time_format):
    current_time = datetime.datetime.now().strftime(time_format)
    return current_time


def write_time_output(current_time, output_file_path):
    with open(output_file_path, "w") as file:
        file.write(f"<html><body><h1>{current_time}</h1></body></html>")


def main():
    time_format = "%Y-%m-%d %H:%M:%S"
    output_file_path = "/usr/share/nginx/html/myclock.html"
    update_clock_time_interval = int(os.getenv('UPDATE_CLOCK_TIME_INTERVAL', '10'))

    while True:
        current_time = get_current_time(time_format)
        write_time_output(current_time, output_file_path)
        time.sleep(20)


if __name__ == "__main__":
    main()
