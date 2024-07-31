# Start from an official Python runtime as a parent image
FROM python:3.9

# Set environment variables
ENV WORKDIR=/usr/src/app \
    CHROME_DRIVER_VERSION=126.0.6478.62 \
    CONTAINER_APP_PORT=80 \
    PYTHONPATH=. \
    CHROME_DRIVER_PATH=/usr/local/bin/chromedriver \
    OUTPUT_FILE_PATH=/usr/share/nginx/html/myclock.html \
    CLOCK_APP_URL="http://localhost"

# Create a non-root user and give them sudo permissions.
# To run as non-root user for security reasons.
RUN useradd -m -s /bin/bash myuser && \
    apt-get update && \
    echo "myuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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

# Copy requirements file
COPY --chown=myuser:myuser requirements.txt ./

# Switch to non-root user
USER myuser

RUN pip install --upgrade pip && \
    pip -v install -r requirements.txt
# Install Python packages
RUN pip install --user --no-warn-script-location --upgrade pip && \
    pip install --user --no-warn-script-location -r requirements.txt && \
    pip install --user --no-warn-script-location pytest

# Copy code and configuration files
COPY --chown=myuser:myuser my_clock.py ./
COPY --chown=myuser:myuser tests/*.py ./tests/
COPY --chown=myuser:myuser entrypoint.sh ./entrypoint.sh
RUN chmod u+x ./entrypoint.sh

USER root
COPY nginx.conf /etc/nginx/nginx.conf
RUN chown -R myuser:myuser /var/log/nginx /var/lib/nginx /var/run /run /usr/share/nginx/html ${WORKDIR} && \
    chmod 755 /var/log/nginx /var/lib/nginx /var/run /run /usr/share/nginx/html ${WORKDIR}

# Switch back to non-root user
USER myuser

# Make port available to the world outside this container
EXPOSE ${CONTAINER_APP_PORT}

# Set the entrypoint
ENTRYPOINT ["./entrypoint.sh"]

