#!/usr/bin/env bash

dpl --provider=gcs --access-key-id=$GCS_KEY --secret-access-key=$GCS_SECRET --bucket=$BUCKET --local-dir=./build/app/outputs/apk/release --upload-dir=releases
