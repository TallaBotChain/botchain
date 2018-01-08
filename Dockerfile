FROM node:8

ENV SRV_DIR /srv
ENV APP_DIR $SRV_DIR/app
RUN mkdir -p $SRV_DIR $APP_DIR

# set our node environment, either development or production
# defaults to development since truffle doesn't seem to work otherwise
ARG NODE_ENV=development
ENV NODE_ENV $NODE_ENV

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
        netcat \
        vim \
        less \
        curl \
        python-dev \
        python-pip \
        && \
    rm -rf /var/lib/apt/lists/*

RUN pip install awscli

# stuff doesn't seem to work with an external node_modules with
# PATH/NODE_PATH set accordingly, so install in app dir
WORKDIR $APP_DIR
COPY package*.json $APP_DIR/
RUN npm install && npm cache clean --force
ENV PATH $APP_DIR/node_modules/.bin:$PATH

COPY . $APP_DIR/
RUN npm run compile

ENTRYPOINT ["/srv/app/docker-entrypoint.sh"]
