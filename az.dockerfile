#https://hub.docker.com/r/ceshine/cuda-pytorch/~/dockerfile/

FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04



ARG CONDA_PYTHON_VERSION=3
ARG CONDA_DIR=/opt/conda
ARG USERNAME=docker
ARG USERID=1000
Arg PYTHON_VERSION=3.6

# Instal basic utilities
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
    sudo \
    cmake \
    git \
    wget \
    curl \
    unzip\
    vim \
    bzip2\
    build-essential \
    ca-certificates \
    libjpeg-dev \
    libpng-dev &&\
    apt-get clean && \
     rm -rf /var/lib/apt/lists/*


# Install miniconda


ENV PATH $CONDA_DIR/bin:$PATH
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
  wget --quiet https://repo.continuum.io/miniconda/Miniconda$CONDA_PYTHON_VERSION-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
  echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
  /bin/bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
  rm -rf /tmp/* && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Create the user
RUN useradd --create-home -s /bin/bash --no-user-group -u $USERID $USERNAME && \
    chown $USERNAME $CONDA_DIR -R && \
    adduser $USERNAME sudo && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

RUN conda install -y python=$PYTHON_VERSION && \
  conda install -y h5py scikit-learn matplotlib seaborn \
  pandas mkl-service cython && \
  conda clean -tipsy

#torch version 0.3.1 torchvision
RUN  pip install --upgrade pip && \
  pip install pillow-simd && \
  pip install http://download.pytorch.org/whl/cu90/torch-0.3.1-cp36-cp36m-linux_x86_64.whl && \
  pip install torchvision==0.2.0 && rm -rf ~/.cache/pip

ENV CUDA_HOME=/usr/local/cuda
ENV CUDA_ROOT=$CUDA_HOME
ENV PATH=$PATH:$CUDA_ROOT/bin:$HOME/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_ROOT/lib64


