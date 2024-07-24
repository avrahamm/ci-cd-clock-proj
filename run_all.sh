nginx -g 'daemon off;' &
python3 -m unittest tests.TestMyClock
python3 my_clock.py