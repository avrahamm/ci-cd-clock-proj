import unittest
import re
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time


class MyClockE2ETest(unittest.TestCase):
    def setUp(self):
        print("setUp")
        print(__class__)
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--remote-debugging-port=9222")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-software-rasterizer")

        chrome_driver_path = os.getenv('CHROME_DRIVER_PATH', '/usr/local/bin/chromedriver')
        self.driver = webdriver.Chrome(service=Service(chrome_driver_path), options=chrome_options)

        clock_app_url = os.getenv('CLOCK_APP_URL', 'http://localhost')
        self.driver.get(clock_app_url)

    def test_clock_updates(self):
        wait = WebDriverWait(self.driver, 30)

        time_element = wait.until(EC.presence_of_element_located((By.TAG_NAME, "h1")))
        initial_time = time_element.text

        update_interval = int(os.getenv('REFRESH_INTERVAL', '25'))
        time.sleep(update_interval)
        self.driver.refresh()

        time_element = wait.until(EC.presence_of_element_located((By.TAG_NAME, "h1")))
        updated_time = time_element.text

        self.assertNotEqual(initial_time, updated_time, f"Clock did not update after {update_interval} seconds")

    def test_time_exists_and_format(self):
        wait = WebDriverWait(self.driver, 30)

        time_element = wait.until(EC.presence_of_element_located((By.TAG_NAME, "h1")))
        time_text = time_element.text

        self.assertTrue(time_text, "Time element is empty")

        time_pattern = r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'
        self.assertTrue(re.match(time_pattern, time_text), f"Time '{time_text}' is not in the correct format")

    def tearDown(self):
        self.driver.quit()


if __name__ == "__main__":
    unittest.main()
