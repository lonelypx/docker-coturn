FROM ubuntu:22.04
LABEL maintainer="Anil Mathew <anilmathewm@yahoo.co.uk>"

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

EXPOSE 3478

ENV USERNAME=username
ENV PASSWORD=password
ENV REALM=realm
ENV MIN_PORT=65435
ENV MAX_PORT=65535

RUN apt-get update && apt-get install -y \
  dnsutils \
  coturn \
  iproute2 \ 
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["bash", "sh/deploy-turnserver.sh"]    
