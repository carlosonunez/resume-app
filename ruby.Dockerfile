FROM ruby:2.4.2-alpine3.6
ADD https://github.com/madnight/docker-alpine-wkhtmltopdf/raw/master/wkhtmltopdf /usr/local/bin
RUN apk add --update --no-cache \
      libgcc libstdc++ libx11 glib libxrender libxext libintl \
      libcrypto1.0 libssl1.0 \
      ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family
RUN chmod +x /usr/local/bin/wkhtmltopdf
