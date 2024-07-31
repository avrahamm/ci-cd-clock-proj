#!/bin/bash

# For trying on my local ubuntu.

docker --debug build \
      -t avrahamm/ci-cd-clock-proj:selenium .

docker run -d \
    --name host-clock \
    -e CLOCK_APP_URL="http://localhost" \
    -p 8776:80 avrahamm/ci-cd-clock-proj:selenium

