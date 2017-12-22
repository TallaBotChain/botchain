FROM node:8

ENV APP_DIR /srv/app

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
        netcat \
        vim \
        less \
        curl \
        && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR

COPY . $APP_DIR/

RUN npm install

ENTRYPOINT ["/srv/app/docker-entrypoint.sh"]
