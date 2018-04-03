FROM ruby:2.4.2-alpine3.6
ARG GEM_AUTHOR
ARG GEM_EMAIL
ADD . /work
WORKDIR /work
RUN \
  apk update && \
  apk add --no-cache ruby-bundler ruby-json ruby-dev && \
  export GEM_AUTHOR="$GEM_AUTHOR" && \
  export GEM_EMAIL="$GEM_EMAIL" && \
  rm -rf /var/cache/apk/* && \
  rm -rf .env* && \
  bundle install --without test && \
  gem build resume_app.gemspec && \
	gem install resume_app*.gem
WORKDIR /
RUN \
	rm -rf /work
ENTRYPOINT ["resume_app"]
