#!/usr/bin/env bash

dpl --provider=gcs --skip_cleanup=true --access-key-id=$GCS_KEY --secret-access-key=$GCS_SECRET --bucket=$BUCKET --local-dir=./build/app/outputs/apk/release --upload-dir=releases/${TRAVIS_COMMIT}_${TRAVIS_BUILD_NUMBER}
