FROM nginx
WORKDIR /app

RUN apt update && \
    apt install -y python3

COPY my_clock.py ./
COPY run_all.sh ./
RUN chmod u+x run_all.sh

CMD ["./run_all.sh"]

