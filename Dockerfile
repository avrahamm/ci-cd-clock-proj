# Start from an official Python runtime as a parent image
FROM python:3.9

#ARG WORKDIR="/usr/src/app"
ARG WORKDIR
ARG CHROME_DRIVER_VERSION
ARG CONTAINER_APP_PORT

# Set the working directory
WORKDIR $WORKDIR

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
RUN wget -O /tmp/chromedriver.zip https://storage.googleapis.com/chrome-for-testing-public/$CHROME_DRIVER_VERSION/linux64/chromedriver-linux64.zip && \
    unzip /tmp/chromedriver.zip -d . && \
    #    extracts to chromedriver-linux64 folder #
    mv ./chromedriver-linux64/chromedriver /usr/local/bin/ && \
    rm /tmp/chromedriver.zip && rm -rf chromedriver-linux64

# Install any needed packages specified in requirements.txt
COPY requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt

# to fix python module issues
ENV PYTHONPATH=.

# Copy code into the container
COPY my_clock.py ./
COPY tests/*.py ./tests/

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the entrypoint script
COPY entrypoint.sh ./entrypoint.sh
RUN chmod u+x ./entrypoint.sh

# Make port 80 available to the world outside this container
EXPOSE ${CONTAINER_APP_PORT}

# Set the entrypoint
ENTRYPOINT ["./entrypoint.sh"]

