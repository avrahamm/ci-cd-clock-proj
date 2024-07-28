# Start from an official Python runtime as a parent image
FROM python:3.9
#ARG WORKDIR="/usr/src/app"
ARG WORKDIR

# Set the working directory
WORKDIR $WORKDIR

# Install Nginx
RUN apt update && apt install -y nginx

# Install any needed packages specified in requirements.txt
COPY requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt

# to fix python module issues
ENV PYTHONPATH=.

# Copy code into the container
COPY my_clock.py ./
COPY tests/test_my_clock.py ./tests/

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the entrypoint script
COPY entrypoint.sh ./entrypoint.sh
RUN chmod u+x ./entrypoint.sh

# Make port 80 available to the world outside this container
EXPOSE 80

# Set the entrypoint
ENTRYPOINT ["./entrypoint.sh"]

