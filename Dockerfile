ARG BASE_IMAGE=ubuntu:16.04

FROM $BASE_IMAGE

ARG PYTHON_VERSION=3.7
ARG ARCH=cpu

RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        ca-certificates \
        cmake \
        wget \
        git \
        vim \
        libsm6 \
        libxext6 \
        libxrender-dev \
        nginx \
        jq \
        bc \
        && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-tk \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python${PYTHON_VERSION} ~/get-pip.py && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python3 && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python && \
    $PIP_INSTALL \
        torch_nightly -f https://download.pytorch.org/whl/nightly/${ARCH}/torch_nightly.html && \
    $PIP_INSTALL fastai && \
    ldconfig && \ 
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*
    
# Copy workaround script for incorrect hostname
COPY lib/changehostname.c /
COPY lib/start_with_right_hostname.sh /usr/local/bin/start_with_right_hostname.sh

# Install the SageMaker Fastai container package
COPY dist/sagemaker_fastai_container-1.0-py2.py3-none-any.whl /sagemaker_fastai_container-1.0-py2.py3-none-any.whl    
    
# Install fastai container package
RUN PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    $PIP_INSTALL /sagemaker_fastai_container-1.0-py2.py3-none-any.whl && \
    chmod +x /usr/local/bin/start_with_right_hostname.sh && \
    rm /sagemaker_fastai_container-1.0-py2.py3-none-any.whl

# Python won’t try to write .pyc or .pyo files on the import of source modules
# Force stdin, stdout and stderr to be totally unbuffered. Good for logging
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

ENV SAGEMAKER_TRAINING_MODULE sagemaker_pytorch_container.training:main
ENV SAGEMAKER_SERVING_MODULE sagemaker_pytorch_container.serving:main

WORKDIR /

# Starts framework
ENTRYPOINT ["bash", "-m", "start_with_right_hostname.sh"]