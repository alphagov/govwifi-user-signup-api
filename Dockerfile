FROM ruby:3.3.6-alpine
ARG BUNDLE_INSTALL_CMD
ENV RACK_ENV=development
ENV WORD_LIST_FILE='./tmp/wordlist'

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock .ruby-version ./
#RUN apk --update --upgrade add build-base mysql-dev && \
#  bundle check || ${BUNDLE_INSTALL_CMD} && \
#  apk del build-base && \
#  find / -type f -iname \*.apk-new -delete && \
#  rm -rf /var/cache/apk/*
RUN apk --no-cache add --virtual .build-deps build-base && \
  apk --no-cache add mysql-dev && \
  ${BUNDLE_INSTALL_CMD} && \
  apk del .build-deps

COPY . .

ENV GOVNOTIFY_BEARER_TOKEN ''

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["bundle", "exec", "puma", "-p", "8080", "--quiet", "--threads", "8:32"]
