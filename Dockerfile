FROM ubuntu:latest

LABEL maintainer="dwilicious"

# environment settings
ENV HOME="/code"
ENV TZ Asia/Jakarta

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
    echo "**** Update repos and install some programs ****" && \
    apt update && \
    apt install -y \
    wget \
    apt-get install -y \
    git \
    nano \
    python3-pip 

RUN \
    echo "**** install code-server ****" && \
    CODE_LATEST=$(curl -s https://api.github.com/repos/cdr/code-server/releases/latest | grep "bowser_download_url.*amd64.deb" | cut -d '"' -f 4) && \
    wget $CODE_LATEST && \
    dpkg -i $CODE_LATEST 

RUN \
    echo "**** clean up ****" && \
    apt purge --auto-remove -y \
    apt clean && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

RUN \
    echo "**** installing Python Module ****" && \
    pip3 install -U ipykernel pylint pytest numpy pandas matplotlib requests flask

RUN \
    echo "**** installing vscode extension ****" && \
    code-server --install-extension dbaeumer.vscode-eslint \
    code-server --install-extension esbenp.prettier-vscode \
    code-server --install-extension github.vscode-pull-request-github \
    code-server --install-extension ms-python.python \
    code-server --install-extension ritwickdey.liveserver 

# expose port to local machine for code-server and live-server
EXPOSE 8080 5500

# run code server
ENTRYPOINT  code-server --bind-addr 0.0.0.0:8080 --auth none
