FROM alpine:3.11.0

RUN apk --no-cache add curl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
