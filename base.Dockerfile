FROM alpine:3.11.0
LABEL image=hpcsc/upload-bintray-docker-action-base
LABEL version=0.1.0

RUN apk --no-cache add curl jq

ENTRYPOINT ["/entrypoint.sh"]
