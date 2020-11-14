FROM ubuntu:latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="dwilicious"

# environment settings
ENV HOME="/code"
ENV TZ Asia/Jakarta

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
    echo "**** Update Package ****" && \
    apt-get update && \
    apt-get install -y 

RUN \
    echo "***install gnupg and curl***" && \
    apt install -y gnupg dirmngr curl

RUN \
    echo "***install node and yarn***" && \
    #    gnupg && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node_12.x focal main' \
    > /etc/apt/sources.list.d/nodesource.list && \
    curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo 'deb https://dl.yarnpkg.com/debian/ stable main' \
    > /etc/apt/sources.list.d/yarn.list 

RUN \    
    echo "**** install build dependencies ****" && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    pkg-config 

RUN \
    echo "**** install runtime dependencies ****" && \
    apt-get install -y \
    git \
    jq \
    nano \
    net-tools \
    nodejs \
    sudo \
    python3-pip \
    yarn 

RUN \
    echo "**** install code-server ****" && \
    if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET "https://api.github.com/repos/cdr/code-server/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
    fi && \
    CODE_VERSION=$(echo "$CODE_RELEASE" | awk '{print substr($1,2); }') && \
    yarn --production --frozen-lockfile global add code-server@"$CODE_VERSION" && \
    yarn cache clean 

RUN \
    echo "**** clean up ****" && \
    apt-get purge --auto-remove -y \
    build-essential \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    pkg-config && \
    apt-get clean && \
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
