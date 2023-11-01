#!/bin/bash

id=$(uuidgen)
job_id=$(uuidgen)
now=$(date +%s%N)
ttl=$(date +%s -d "14 days")
tag=${BUILD_TAG-latest}
network=${1-dev}

docker run --rm -i \
  -e "AWS_REGION=$AWS_REGION" \
  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
  -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
  -v ~/.aws:/root/.aws \
  -v "$PWD":/aws \
  amazon/aws-cli dynamodb put-item --table-name "ceramic-$network-ops" --item \
  "{                                                \
    \"id\":     {\"S\": \"$id\"},                   \
    \"job\":    {\"S\": \"$job_id\"},               \
    \"ts\":     {\"N\": \"$now\"},                  \
    \"ttl\":    {\"N\": \"$ttl\"},                  \
    \"stage\":  {\"S\": \"queued\"},                \
    \"type\":   {\"S\": \"workflow\"},              \
    \"params\": {                                   \
      \"M\": {                                      \
        \"name\":     {\"S\": \"Durable Tests\"},   \
        \"org\":      {\"S\": \"3box\"},            \
        \"repo\":     {\"S\": \"ceramic-tests\"},   \
        \"ref\":      {\"S\": \"main\"},            \
        \"workflow\": {\"S\": \"run-durable.yml\"}, \
        \"inputs\":   {                             \
          \"M\": {                                  \
            \"build_tag\": {\"S\": \"$tag\"}        \
          }                                         \
        }                                           \
      }                                             \
    }                                               \
  }"
