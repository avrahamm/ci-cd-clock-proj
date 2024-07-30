# Start from an official Python runtime as a parent image
FROM python:3.9

# Set environment variables
ENV WORKDIR=/usr/src/app \
    CHROME_DRIVER_VERSION=126.0.6478.62 \
    CONTAINER_APP_PORT=80 \
    PYTHONPATH=. \
    CHROME_DRIVER_PATH=/usr/local/bin/chromedriver \
    OUTPUT_FILE_PATH=/usr/share/nginx/html/myclock.html \
    CLOCK_APP_URL=http://localhost

RUN useradd -m -s /bin/bash myuser

# Set the working directory
WORKDIR ${WORKDIR}

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

# Install any needed packages specified in requirements.txt
COPY --chown=myuser:myuser requirements.txt ./

USER myuser
RUN pip install --upgrade pip && pip install -r requirements.txt
USER root

# Copy code into the container
COPY --chown=myuser:myuser my_clock.py ./
COPY --chown=myuser:myuser tests/*.py ./tests/

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the entrypoint script
COPY entrypoint.sh ./entrypoint.sh
RUN chmod u+x ./entrypoint.sh

# Switch to non-root user
USER myuser

# Make port available to the world outside this container
EXPOSE ${CONTAINER_APP_PORT}

# Set the entrypoint
ENTRYPOINT ["./entrypoint.sh"]

