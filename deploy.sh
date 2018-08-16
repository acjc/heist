#!/usr/bin/env bash

version=$(jq -r '.[] | .apkInfo | .versionName' < build/app/outputs/apk/release/output.json)

dpl --provider=gcs --skip_cleanup=true --access-key-id=$GCS_KEY --secret-access-key=$GCS_SECRET --bucket=$BUCKET --local-dir=./build/app/outputs/apk/release --upload-dir=releases/${version}/${TRAVIS_COMMIT}/${TRAVIS_BUILD_NUMBER}
