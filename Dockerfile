FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y python3
 
COPY align.py /
COPY bwa /

WORKDIR /

ENTRYPOINT ["/bin/python3", "align.py"]
