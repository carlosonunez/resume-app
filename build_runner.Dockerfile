FROM ruby:2.4.2-alpine3.6

RUN \
  apk update && \
  apk upgrade && \
  apk add ruby-bundler ruby-json ruby-dev ruby-rake libffi-dev build-base git && \
  gem install travis && \
  export PATH="$PATH:/work/.gem/bin" && \
  rm -rf /var/cache/apk/*

ENTRYPOINT ["/bin/sh", "-c"]
