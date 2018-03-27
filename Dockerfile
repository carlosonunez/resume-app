FROM ruby:2.4.2-alpine3.6
RUN \
  apk update && \
  apk upgrade && \
  apk add ruby-bundler ruby-json ruby-dev && \
	export GEM_HOME="/root/.gem" && \
	export BUNDLE_PATH="/root/.gem" && \
  export PATH="$PATH:/root/.gem/bin" && \
  rm -rf /var/cache/apk/*
ADD . /work
WORKDIR /work
RUN \
  rm -rf .env* && \
  bundle install && \
  gem build resume_app.gemspec && \
	gem install resume_app*.gem
WORKDIR /
RUN \
	rm -rf /work
ENTRYPOINT ["resume_app"]
