#!/usr/bin/env bash

# This script shows how to build the Docker image and push it to ECR to be ready for use
# by SageMaker.

# The argument to this script is the image name. This will be used as the image on the local
# machine and combined with the account and region to form the repository name for ECR.
IMAGE="sagemaker-fastai"

# input parameters
FASTAI_VERSION=${1:-1.0}
PY_VERSION=${2:-py37}

# Get the account number associated with the current IAM credentials
account=$(aws sts get-caller-identity --query Account --output text)

if [ $? -ne 0 ]
then
    exit 255
fi

# Get the region defined in the current configuration (default to us-west-2 if none defined)
region=$(aws configure get region)
region=${region:-us-west-2}

# If the repository doesn't exist in ECR, create it.

aws ecr describe-repositories --repository-names "${IMAGE}" > /dev/null 2>&1

if [ $? -ne 0 ]
then
    aws ecr create-repository --repository-name "${IMAGE}" > /dev/null
fi

# Get the login command from ECR and execute it directly
$(aws ecr get-login --region ${region} --no-include-email)

# Build the python package wheel file
python setup.py bdist_wheel

# Build the GPU docker image locally with the image name and then push it to ECR
tag="${FASTAI_VERSION}-gpu-${PY_VERSION}"
fullname="${account}.dkr.ecr.${region}.amazonaws.com/${IMAGE}:${tag}"
docker build -t ${IMAGE}:${tag} --build-arg PYTHON_VERSION=${PY_VERSION:2:1}.${PY_VERSION:3:1} --build-arg BASE_IMAGE="nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04" --build-arg ARCH=cu90 .
docker tag ${IMAGE}:${tag} ${fullname}
docker push ${fullname}

# Build the CPU docker image locally with the image name and then push it to ECR
tag="${FASTAI_VERSION}-cpu-${PY_VERSION}"
fullname="${account}.dkr.ecr.${region}.amazonaws.com/${IMAGE}:${tag}"
docker build -t ${IMAGE}:${tag} --build-arg PYTHON_VERSION=${PY_VERSION:2:1}.${PY_VERSION:3:1} --build-arg BASE_IMAGE="ubuntu:16.04" --build-arg ARCH="cpu" .
docker tag ${IMAGE}:${tag} ${fullname}
docker push ${fullname}



