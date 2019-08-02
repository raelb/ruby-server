FROM ubuntu:16.04

ENV PROJECT_DIR=/data/src/

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get -y update && \
    apt-get -y install git build-essential ruby-dev ruby-rails libz-dev libmysqlclient-dev curl tzdata && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get -y update && \
    apt-get -y install nodejs && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean

WORKDIR $PROJECT_DIR

COPY Gemfile Gemfile.lock $PROJECT_DIR
RUN bundle install

COPY . $PROJECT_DIR
RUN bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT [ "./docker/entrypoint" ]
CMD [ "start" ]
