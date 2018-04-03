FROM ruby:2.4.2-alpine3.6
ARG GEM_AUTHOR
ARG GEM_EMAIL
ADD . /work
WORKDIR /work
RUN \
  apk update && \
  apk add --no-cache ruby-bundler ruby-json ruby-dev && \
	export GEM_HOME="/root/.gem" && \
	export BUNDLE_PATH="/root/.gem" && \
  export PATH="$PATH:/root/.gem/bin" && \
  export GEM_AUTHOR="$GEM_AUTHOR" && \
  export GEM_EMAIL="$GEM_EMAIL" && \
  rm -rf /var/cache/apk/* && \
  rm -rf .env* && \
  bundle install --without test && \
  gem build resume_app.gemspec
COPY resume_app*.gem /tmp
RUN gem install /tmp/resume_app*.gem
ENTRYPOINT ["resume_app"]
