FROM nginx
#WORKDIR /app
WORKDIR $WORKDIR

RUN apt update && \
    apt install -y python3

COPY my_clock.py ./
COPY run_all.sh ./
RUN chmod u+x run_all.sh

EXPOSE 80
CMD ["./run_all.sh"]

