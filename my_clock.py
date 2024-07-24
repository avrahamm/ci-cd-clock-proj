import time
import datetime


def get_current_time(format):
    current_time = datetime.datetime.now().strftime(format)
    return current_time


def write_time_output(current_time, output_file_path):
    with open(output_file_path, "w") as file:
        file.write(f"<html><body><h1>{current_time}</h1></body></html>")

def main():
    format = "%Y-%m-%d %H:%M:%S"
    output_file_path = "/usr/share/nginx/html/myclock.html"

    while True:
        current_time = get_current_time(format)
        write_time_output(current_time, output_file_path)
        time.sleep(20)

if __name__ == "__main__":
    main()