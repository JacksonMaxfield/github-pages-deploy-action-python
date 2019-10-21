FROM ubuntu

# General upgrades and requirements
RUN apt-get update && apt-get upgrade -y

# Get software props
RUN apt-get install -y \
    software-properties-common

RUN add-apt-repository universe

# Get python3.7 and pip
RUN apt-get update && apt-get install -y \
    python3.7 \
    python3.7-dev \
    python3-pip \
    git \
    jq

# Upgrade pip and force it to use python3.7
RUN python3.7 -m pip install --upgrade pip

# Add aliases to to python3
RUN ln -s /usr/bin/python3.7 /usr/bin/python & \
    ln -s /usr/bin/pip3 /usr/bin/pip
