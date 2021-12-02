FROM python:3.8

MAINTAINER Part Time Larry "parttimelarry@gmail.com"

ADD . /app

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential redis-server sqlite3 \
    curl software-properties-common

# install nodejs and wscat websocket client
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get install -y nodejs && npm install wscat
RUN apt-get install sbcl

# download and build TA-Lib
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
  tar -xvzf ta-lib-0.4.0-src.tar.gz && \
  cd ta-lib/ && \
  ./configure --prefix=/usr && \
  make && \
  make install

RUN rm -R ta-lib ta-lib-0.4.0-src.tar.gz

# install popular Python packages.  numpy is manually installed in the
# docker file here, because of a failure when the latest version was
# called down from the docker-compose.yml configuration. RUN pip3

install --upgrade --no-binary numpy==1.18.1 numpy==1.18.1 \ && pip3

# install -r requirements.txt
