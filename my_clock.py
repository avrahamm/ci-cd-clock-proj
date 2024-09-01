import time
import datetime
import os
import logging
import requests

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def get_ec2_instance_ip():
    # TODO!
    response = requests.get('http://169.254.169.254/latest/meta-data/public-ipv4', timeout=2)
    return response.text


def get_current_time(time_format):
    current_time = datetime.datetime.now().strftime(time_format)
    return current_time


def write_time_output(current_time, output_file_path):
    try:
        with open(output_file_path, "w") as file:
            file.write(f"<html><body><h1>{current_time}</h1></body></html>")
        # logging.info(f"Time written to {output_file_path}")
    except IOError as e:
        logging.error(f"Error writing to file: {e}")

def get_ec2_instance_ip():
    try:
        response = requests.get('http://169.254.169.254/latest/meta-data/public-ipv4', timeout=2)
        return response.text
    except requests.RequestException:
        return "Unable to retrieve EC2 IP"


def main():
    time_format = os.getenv('TIME_FORMAT', "%Y-%m-%d %H:%M:%S")
    output_file_path = os.getenv('OUTPUT_FILE_PATH', "/usr/share/nginx/html/myclock.html")
    update_clock_time_interval = int(os.getenv('UPDATE_CLOCK_TIME_INTERVAL', '10'))

    logging.info(f"Starting clock. Output file: {output_file_path}, Update interval: {update_clock_time_interval}s")

    while True:
        current_time = get_current_time(time_format)        
        write_time_output(current_time, output_file_path)
        time.sleep(update_clock_time_interval)


if __name__ == "__main__":
    main()
