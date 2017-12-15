FROM alpine:latest

RUN \
  apk update && \
  apk upgrade && \
  apk add go && \
  apk add ruby-bundler ruby-json ruby-dev ruby-rake libffi-dev build-base git && \
  go get github.com/anubhavmishra/tfjson && \
  gem install travis --no-document && \
  export PATH="$PATH:/work/.gem/bin" && \
  rm -rf /var/cache/apk/*

ENTRYPOINT ["/bin/sh", "-c"]
