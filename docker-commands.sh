#!/bin/bash

# For trying on my local ubuntu.

# Build the test image
docker --debug build --target tester \
      -t avrahamm/clock-app:test .

# Run the tests.
# If tests pass, build the production image
if docker run --rm -d \
       --name host-clock-test \
       -e CLOCK_APP_URL="http://localhost" \
       -p 8775:80 avrahamm/clock-app:test;
then

    echo "Tests passed. Building production image..."
    docker --debug build --target production -t avrahamm/clock-app:prod .

    # Run the production container
    docker run -d \
        --name host-clock \
        -p 8776:80 avrahamm/clock-app:prod
else
    echo "Tests failed. Not building production image."
fi