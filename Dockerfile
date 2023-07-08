FROM ubuntu 

RUN apt update 
RUN apt-get install -y python3

COPY /home/ec2-user/docker/align.py align.py 
COPY /home/ec2-user/docker/bwa bwa
