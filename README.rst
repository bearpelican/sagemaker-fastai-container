
===========================
SageMaker Fastai Container
===========================

SageMaker Fastai Container is an open source library for making the fast.ai framework run on Amazon SageMaker. 
It showcases running the open source library `fastai <https://github.com/fastai/fastai>`__ on Amazon SageMaker.

It is based on the SageMaker PyTorch Container that can be found `here <https://github.com/aws/sagemaker-pytorch-container>`__.

For information on running PyTorch jobs on SageMaker: `SageMaker PyTorch Estimators and Models
<https://github.com/aws/sagemaker-python-sdk/tree/master/src/sagemaker/pytorch>`__.

For notebook examples: `SageMaker Notebook
Examples <https://github.com/awslabs/amazon-sagemaker-examples>`__.

Table of Contents
-----------------

#. `Getting Started <#getting-started>`__
#. `Building your Image <#building-your-image>`__
#. `Running the tests <#running-the-tests>`__

Getting Started
---------------

Prerequisites
~~~~~~~~~~~~~

Make sure you have installed all of the following prerequisites on your
development machine:

- `Docker <https://www.docker.com/>`__

For Testing on GPU
^^^^^^^^^^^^^^^^^^

-  `Nvidia-Docker <https://github.com/NVIDIA/nvidia-docker>`__

Recommended
^^^^^^^^^^^

-  A Python environment management tool (e.g.
   `PyEnv <https://github.com/pyenv/pyenv>`__,
   `VirtualEnv <https://virtualenv.pypa.io/en/stable/>`__)

Building your image
-------------------

`Amazon SageMaker <https://aws.amazon.com/documentation/sagemaker/>`__
utilizes Docker containers to run all training jobs & inference endpoints.

The Docker images are built from the Dockerfile specified in
`Docker/ <https://github.com/aws/sagemaker-fastai-container/tree/master/docker/Dockerfile>`__.

Dockerfile
~~~~~~~~~~~~

The Dockerfile encompass the installation of the SageMaker specific support code. 

The Dockerfile is based on the Paperspace fast.ai docker image stored in DockerHub `here <https://hub.docker.com/r/paperspace/fastai/>`__.

These images are specified with the naming convention of
fastai-base:<PyTorch_version>-<processor>-py<python_version>.

::

    # Create the SageMaker PyTorch Container Python package.
    cd sagemaker-fastai-container
    python setup.py bdist_wheel

If you want to build the Docker image, then use:

::

    # All build instructions assume you're building from the root directory of the sagemaker-fastai-container.

    docker build -t <image_name>:<tag> -f docker/Dockerfile --build-arg pytorch_version=<pytorch_version> .

::

    # Example

    docker build -t preprod-fastai:0.3.1-gpu-py3 -f docker/Dockerfile --build-arg pytorch_version=0.3.1.post_2 .


Running the tests
-----------------

Running the tests requires installation of the SageMaker PyTorch Container code and its test
dependencies.

::

    git clone https://github.com/aws/sagemaker-fastai-container.git
    cd sagemaker-fastai-container
    pip install -e .[test]

Tests are defined in
`test/ <https://github.com/aws/sagemaker-fastai-container/tree/master/test>`__
and include unit, local integration, and SageMaker integration tests.

Unit Tests
~~~~~~~~~~

If you want to run unit tests, then use:

::

    # All test instructions should be run from the top level directory

    pytest test/unit

    # or you can use tox to run unit tests as well as flake8 and code coverage

    tox


Local Integration Tests
~~~~~~~~~~~~~~~~~~~~~~~

Running local integration tests require `Docker <https://www.docker.com/>`__ and `AWS
credentials <https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html>`__,
as the local integration tests make calls to a couple AWS services. The local integration tests and
SageMaker integration tests require configurations specified within their respective
`conftest.py <https://github.com/aws/sagemaker-fastai-container/blob/master/test/conftest.py>`__.

Local integration tests on GPU require `Nvidia-Docker <https://github.com/NVIDIA/nvidia-docker>`__.

Before running local integration tests:

#. Build your Docker image.
#. Pass in the correct pytest arguments to run tests against your Docker image.

If you want to run local integration tests, then use:

::

    # Required arguments for integration tests are found in test/conftest.py

    pytest test/integration/local --docker-base-name <your_docker_image> \
                      --tag <your_docker_image_tag> \
                      --py-version <2_or_3> \
                      --framework-version <PyTorch_version> \
                      --processor <cpu_or_gpu>

::

    # Example
    pytest test/integration/local --docker-base-name preprod-fastai \
                      --tag 1.0 \
                      --py-version 3 \
                      --framework-version 0.3.1 \
                      --processor cpu

SageMaker Integration Tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~

SageMaker integration tests require your Docker image to be within an `Amazon ECR repository <https://docs
.aws.amazon.com/AmazonECS/latest/developerguide/ECS_Console_Repositories.html>`__.

The Docker base name is your `ECR repository namespace <https://docs.aws.amazon
.com/AmazonECR/latest/userguide/Repositories.html>`__.

The instance type is your specified `Amazon SageMaker Instance Type
<https://aws.amazon.com/sagemaker/pricing/instance-types/>`__ that the SageMaker integration test will run on.

Before running SageMaker integration tests:

#. Build your Docker image.
#. Push the image to your ECR repository.
#. Pass in the correct pytest arguments to run tests on SageMaker against the image within your ECR repository.

If you want to run a SageMaker integration end to end test on `Amazon
SageMaker <https://aws.amazon.com/sagemaker/>`__, then use:

::

    # Required arguments for integration tests are found in test/conftest.py

    pytest test/integration/sagemaker --aws-id <your_aws_id> \
                           --docker-base-name <your_docker_image> \
                           --instance-type <amazon_sagemaker_instance_type> \
                           --tag <your_docker_image_tag> \

::

    # Example
    pytest test/integration/sagemaker --aws-id 12345678910 \
                           --docker-base-name preprod-pytorch \
                           --instance-type ml.m4.xlarge \
                           --tag 1.0


License
-------

SageMaker Fastai Container is licensed under the Apache 2.0 License. It is copyright 2018 Amazon
.com, Inc. or its affiliates. All Rights Reserved. The license is available at:
http://aws.amazon.com/apache2.0/