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

# GH Actions labels
LABEL "com.github.actions.name"="Deploy to GitHub Pages"
LABEL "com.github.actions.description"="This action will handle the building and deploying process of your project to GitHub Pages."
LABEL "com.github.actions.icon"="git-commit"
LABEL "com.github.actions.color"="orange"

LABEL "repository"="http://github.com/JacksonMaxfield/gh-pages-github-action-python"
LABEL "homepage"="http://github.com/JacksonMaxfield/gh-pages-github-action-python"
LABEL "maintainer"="Jackson Maxfield Brown <jmaxfieldbrown@gmail.com>"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
