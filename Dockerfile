FROM ruby:2.4.2-alpine3.6

RUN \
  apk update && \
  apk upgrade && \
  apk add ruby-bundler ruby-json ruby-dev ruby-rake && \
  rm -rf /var/cache/apk/*

ENTRYPOINT ["/bin/sh", "-c"]
