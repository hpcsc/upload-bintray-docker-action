#!/bin/sh

REPOSITORY=$1
PACKAGE=$2
VERSION=$3
SOURCE_PATH=$4

for FILE in ${SOURCE_PATH}; do
    UPLOAD_URL=https://api.bintray.com/content/${INPUT_USERNAME}/${REPOSITORY}/$(basename $FILE)
    echo "=== Uploading ${FILE} to ${URL}"
    curl -T ${FILE} \
            -u${INPUT_USERNAME}:${INPUT_APIKEY} \
            -H "X-Bintray-Package:${PACKAGE}" \
            -H "X-Bintray-Version:${VERSION}" \
            ${UPLOAD_URL}
done

echo "=== Publishing repository [${REPOSITORY}] - package [${PACKAGE}] - version [${VERSION}]"
curl -X POST \
        -u${INPUT_USERNAME}:${INPUT_APIKEY} \
        https://api.bintray.com/content/${INPUT_USERNAME}/${REPOSITORY}/${PACKAGE}/${VERSION}/publish
