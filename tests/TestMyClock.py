import unittest
from unittest.mock import patch, mock_open
import datetime
from my_clock import get_current_time, write_time_output

class TestMyClock(unittest.TestCase):

    def test_get_current_time(self):
        mock_time = datetime.datetime(2024, 7, 24, 12, 34, 56)
        with patch('datetime.datetime') as mock_datetime:
            mock_datetime.now.return_value = mock_time

            self.assertEqual(get_current_time("%Y-%m-%d %H:%M:%S"), "2024-07-24 12:34:56")
            self.assertEqual(get_current_time("%H:%M:%S"), "12:34:56")
            self.assertEqual(get_current_time("%Y-%m-%d"), "2024-07-24")

    def test_write_time_output(self):
        mock_time = "2024-07-24 12:34:56"
        mock_file_path = "/tmp/test_myclock.html"

        with patch('builtins.open', mock_open()) as mock_file:
            write_time_output(mock_time, mock_file_path)

            mock_file.assert_called_once_with(mock_file_path, "w")

            expected_content = f"<html><body><h1>{mock_time}</h1></body></html>"
            mock_file().write.assert_called_once_with(expected_content)

if __name__ == '__main__':
    unittest.main()