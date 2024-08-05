# Start from an official Python runtime as a parent image
FROM python:3.9 AS builder

# Set environment variables
ENV WORKDIR=/usr/src/app \
    PYTHONPATH=. \
    PATH="/home/myuser/.local/bin:${PATH}"

# Create a non-root user and give them sudo permissions.
# To run as non-root user for security reasons.
RUN useradd -m -s /bin/bash myuser && \
    apt update && \
    echo "myuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set the working directory
WORKDIR ${WORKDIR}

# Copy requirements file
COPY --chown=myuser:myuser requirements.txt ./

# Switch to non-root user
USER myuser

# Install Python packages
RUN pip -v install --user pip && \
    pip -v install -r requirements.txt


# Test stage
FROM builder AS tester

USER root

# Set environment variables
ENV CONTAINER_APP_PORT=80 \
    CHROME_DRIVER_VERSION=126.0.6478.62 \
    CHROME_DRIVER_PATH=/usr/local/bin/chromedriver \
    OUTPUT_FILE_PATH=/usr/share/nginx/html/myclock.html \
    CLOCK_APP_URL="http://localhost"

# Install Nginx
RUN apt update && \
    apt install -y wget gnupg unzip && \
    apt install -y nginx

# Install Chrome (specify the version explicitly)
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt update && \
    apt install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Install ChromeDriver (specify the version explicitly)
RUN wget -O /tmp/chromedriver.zip https://storage.googleapis.com/chrome-for-testing-public/${CHROME_DRIVER_VERSION}/linux64/chromedriver-linux64.zip && \
    unzip /tmp/chromedriver.zip -d . && \
    mv ./chromedriver-linux64/chromedriver ${CHROME_DRIVER_PATH} && \
    rm /tmp/chromedriver.zip && rm -rf chromedriver-linux64

COPY nginx-tester.conf /etc/nginx/nginx.conf
RUN chown -R myuser:myuser /var/log/nginx /var/lib/nginx /var/run /run /usr/share/nginx/html ${WORKDIR} && \
    chmod 755 /var/log/nginx /var/lib/nginx /var/run /run /usr/share/nginx/html ${WORKDIR}

# Switch back to non-root user
USER myuser

# Copy code and configuration files
COPY --chown=myuser:myuser my_clock.py ./
COPY --chown=myuser:myuser tests/*.py ./tests/
COPY --chown=myuser:myuser run-tests.sh ./run-tests.sh
RUN chmod u+x ./run-tests.sh

# Make port available to the world outside this container
EXPOSE ${CONTAINER_APP_PORT}

# Set the entrypoint
ENTRYPOINT ["./run-tests.sh"]

# Production stage
FROM python:3.9-alpine AS production

# Set environment variables
ENV CONTAINER_APP_PORT=80 \
    WORKDIR=/usr/src/app \
    PYTHONPATH=. \
    PATH="/home/myuser/.local/bin:${PATH}" \
    OUTPUT_FILE_PATH=/var/lib/nginx/html/myclock.html

# Create a non-root user
RUN adduser -D myuser

# Set the working directory
WORKDIR ${WORKDIR}

# Install nginx
RUN apk add --no-cache nginx

RUN apk add --no-cache nginx && \
    mkdir -p /run/nginx

# Copy Python packages and application code
COPY --from=builder --chown=myuser:myuser /home/myuser/.local /home/myuser/.local
COPY --chown=myuser:myuser my_clock.py ./
COPY nginx-alpine.conf /etc/nginx/nginx.conf

# Set correct permissions
RUN chown -R myuser:myuser /var/log/nginx /var/lib/nginx /run/nginx && \
    chmod 755 /var/log/nginx /var/lib/nginx /run/nginx

# Switch to non-root user
USER myuser

# Copy the entrypoint script
COPY --chown=myuser:myuser entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Expose the container port
EXPOSE ${CONTAINER_APP_PORT}

# Set the entrypoint
ENTRYPOINT ["./entrypoint.sh"]
