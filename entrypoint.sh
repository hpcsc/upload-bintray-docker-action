#!/bin/sh

REPOSITORY=$1
PACKAGE=$2
VERSION=$3
SOURCE_PATH=$4

UPLOADED=0
for FILE in ${SOURCE_PATH}; do
    UPLOAD_URL=https://api.bintray.com/content/${INPUT_USERNAME}/${REPOSITORY}/$(basename $FILE)
    echo "=== Uploading ${FILE} to ${UPLOAD_URL}"
    RESULT=$(curl -T "${FILE}" \
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
curl -X POST \
        -u${INPUT_USERNAME}:${INPUT_APIKEY} \
        https://api.bintray.com/content/${INPUT_USERNAME}/${REPOSITORY}/${PACKAGE}/${VERSION}/publish

TIMEOUT=10
for i in $(seq ${TIMEOUT}); do
    echo "\n=== Checking result of publish, attempt: ${i}"
    PUBLISHED_FILES=$(curl -s -u${INPUT_USERNAME}:${INPUT_APIKEY} \
        https://api.bintray.com/packages/${INPUT_USERNAME}/${REPOSITORY}/${PACKAGE}/versions/${VERSION}/files)
    ALL_PUBLISHED=1
    for FILE in ${SOURCE_PATH}; do
        FILE_NAME=$(basename ${FILE})
        PUBLISHED=$(echo ${PUBLISHED_FILES} | jq -r '.[].name | select(. == "'${FILE_NAME}'")')
        if [ -z "${PUBLISHED}" ]; then
            ALL_PUBLISHED=0
            echo "${FILE_NAME} not yet published"
        else
            echo "${FILE_NAME} published"
        fi
    done

    if [ "${ALL_PUBLISHED}" = "0" ]; then
        echo "Not all files are published, sleeping for 2s"
        sleep 2s
    else
        echo "All files published successfully"
        exit 0
    fi
done

echo "=== Not all files are published after ${TIMEOUT} checks"
exit 1
