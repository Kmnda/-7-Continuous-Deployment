#!/usr/bin/env bash
set -euo pipefail

: "${AWS_DEFAULT_REGION:?Set AWS_DEFAULT_REGION}"
: "${ECR_ACCOUNT_ID:?Set ECR_ACCOUNT_ID}"
: "${ECR_REPO:?Set ECR_REPO}"
: "${EC2_HOST:?Set EC2_HOST}"
: "${GIT_SHA:?Set GIT_SHA}"

ECR_URI="${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}"

# Login to ECR from local (optional if already done)
aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login --username AWS --password-stdin "${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"

# Remote deploy via SSH
ssh -o StrictHostKeyChecking=no "${EC2_HOST}" bash -s <<EOF
set -eux
aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
docker pull "${ECR_URI}:${GIT_SHA}"
docker rm -f web || true
docker run -d --name web -p 80:8000 -e GIT_SHA="${GIT_SHA}" "${ECR_URI}:${GIT_SHA}"
docker ps
EOF
