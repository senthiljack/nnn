#!/bin/bash

cd /opt/computer_vision/
docker build -t image . > /opt/docker_out.txt
docker run -i -d -p port:port -m memory image >> /opt/docker_out.txt
