FROM ruby:2.4.2-alpine3.6
RUN \
  apk update && \
  apk upgrade && \
  apk add ruby-bundler ruby-json ruby-dev && \
  export PATH="$PATH:/work/.gem/bin" && \
  rm -rf /var/cache/apk/*
ADD . /work
WORKDIR /work
RUN \
  rm -rf .env* && \
  gem build resume_app.gemspec
ENTRYPOINT ["resume_app"]
