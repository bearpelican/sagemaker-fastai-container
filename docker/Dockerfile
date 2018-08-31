ARG pytorch_version=0.3.1.post_2
FROM paperspace/fastai:cuda9_pytorch${pytorch_version} 

# install nginx and jq
RUN apt-get update && apt-get install -y --no-install-recommends \
         nginx \
         jq &&\
     rm -rf /var/lib/apt/lists/*

# Copy workaround script for incorrect hostname
COPY lib/changehostname.c /
COPY lib/start_with_right_hostname.sh /usr/local/bin/start_with_right_hostname.sh
RUN chmod +x /usr/local/bin/start_with_right_hostname.sh

# Install the fastai libs as python package
RUN python setup.py bdist_wheel && pip install --no-deps --no-cache dist/fastai-0.7.0-py3-none-any.whl

# Install the SageMaker Fastai container package
COPY dist/sagemaker_fastai_container-1.0-py2.py3-none-any.whl /sagemaker_fastai_container-1.0-py2.py3-none-any.whl
RUN pip install --no-cache /sagemaker_fastai_container-1.0-py2.py3-none-any.whl && \
    rm /sagemaker_fastai_container-1.0-py2.py3-none-any.whl

ENV SAGEMAKER_TRAINING_MODULE sagemaker_pytorch_container.training:main
ENV SAGEMAKER_SERVING_MODULE sagemaker_pytorch_container.serving:main

WORKDIR /

# Starts framework
ENTRYPOINT ["bash", "-m", "start_with_right_hostname.sh"]
