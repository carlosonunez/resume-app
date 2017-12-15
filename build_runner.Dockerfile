FROM alpine:latest

ENV PATH="$PATH:/root/go/bin"
ENV GOPATH="/root/go"

RUN \
  apk update && \
  apk upgrade && \
  apk add go && \
  apk add ruby-bundler ruby-json ruby-dev ruby-rake libffi-dev build-base git && \
  apk add terraform && \
  go get github.com/wybczu/tfjson && \
  gem install travis --no-document && \
  export PATH="$PATH:/work/.gem/bin" && \
  rm -rf /var/cache/apk/*

ENTRYPOINT ["/bin/sh", "-c"]
