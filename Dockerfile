FROM ruby:3.0.1-alpine
ARG BUNDLE_INSTALL_CMD
ENV RACK_ENV=development
ENV WORD_LIST_FILE='./tmp/wordlist'

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock .ruby-version ./
RUN apk --update --upgrade add build-base mysql-dev && \
  bundle check || ${BUNDLE_INSTALL_CMD} && \
  apk del build-base && \
  find / -type f -iname \*.apk-new -delete && \
  rm -rf /var/cache/apk/*

COPY . .

ENV GOVNOTIFY_BEARER_TOKEN ''

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8080"]
