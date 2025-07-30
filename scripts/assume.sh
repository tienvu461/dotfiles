#!/bin/bash
ROLE_NAME=$1
export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn $ROLE_NAME \
--role-session-name aws-sts \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))
