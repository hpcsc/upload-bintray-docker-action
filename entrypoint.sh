#!/bin/sh

REPOSITORY=$1
PACKAGE=$2
VERSION=$3
SOURCE_PATH=$4

UPLOADED=0
for FILE in ${SOURCE_PATH}; do
    UPLOAD_URL=https://api.bintray.com/content/${INPUT_USERNAME}/${REPOSITORY}/$(basename $FILE)
    echo "=== Uploading ${FILE} to ${UPLOAD_URL}"
    RESULT=$(curl -T ${FILE} \
            -u${INPUT_USERNAME}:${INPUT_APIKEY} \
            -H "X-Bintray-Package:${PACKAGE}" \
            -H "X-Bintray-Version:${VERSION}" \
            -H "X-Bintray-Override:${INPUT_OVERRIDE:-0}" \
            ${UPLOAD_URL})

    if [ "$(echo ${RESULT} | jq -r '.message')" != "success" ]; then
        echo "=== Failed to upload ${FILE} with response: ${RESULT}"
        exit 1
    else
        UPLOADED=$((UPLOADED+1))
        echo "=== ${FILE} uploaded successfully"
    fi
done

echo "=== Publishing repository [${REPOSITORY}] - package [${PACKAGE}] - version [${VERSION}]"
PUBLISH_RESULT=$(curl -X POST \
        -u${INPUT_USERNAME}:${INPUT_APIKEY} \
        https://api.bintray.com/content/${INPUT_USERNAME}/${REPOSITORY}/${PACKAGE}/${VERSION}/publish)

if [ $(echo ${PUBLISH_RESULT} | jq -r '.files') -ne ${UPLOADED} ]; then
    echo "=== Not all files are published successfully, response: ${PUBLISH_RESULT}"
    exit 1
else
    echo "=== Published successfully"
fi
