FROM nginx
#ARG WORKDIR="/usr/src/app"
ARG WORKDIR

WORKDIR $WORKDIR

RUN apt update && \
    apt install -y python3

COPY my_clock.py ./
COPY tests/TestMyClock.py ./tests/
COPY run_all.sh ./

RUN chmod u+x run_all.sh

EXPOSE 80
CMD ["./run_all.sh"]

