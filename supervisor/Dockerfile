FROM nginx

# Install Python and supervisor
RUN apt-get update && \
    apt-get install -y python3 supervisor && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy your Python script
COPY my_clock.py ./

# Create a supervisor configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

