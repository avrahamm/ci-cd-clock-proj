#!/bin/bash

# For trying on my local ubuntu.

docker --debug build --target tester \
      -t avrahamm/clock-app:test .

docker run -d \
    --name host-clock \
    -e CLOCK_APP_URL="http://localhost" \
    -p 8776:80 avrahamm/clock-app:test
