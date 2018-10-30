FROM azadehkhojandi/gpu-minimal-notebook


USER $NB_UID
RUN pip install tensorflow-gpu

USER root
RUN sudo apt-get update
RUN sudo apt-get -y install  apt-utils
RUN sudo apt-get -y install  python-pil python-lxml python-tk

USER $NB_UID
RUN pip install --user Cython
RUN pip install --user contextlib2

USER root
WORKDIR /home/$NB_USER/work
# Setup work directory for backward-compatibility
RUN mkdir -p tensorflow/models && \
    fix-permissions /home/$NB_USER && \
    fix-permissions /home/$NB_USER/work  && \
    fix-permissions /home/$NB_USER/work/tensorflow && \
    fix-permissions /home/$NB_USER/work/tensorflow/models


RUN git clone https://github.com/tensorflow/models.git /home/$NB_USER/work/tensorflow/models/

WORKDIR /home/$NB_USER/work/tensorflow/models/research
# From tensorflow/models/research/
RUN wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.3.0/protoc-3.3.0-linux-x86_64.zip
RUN unzip protobuf.zip -d protoc330
ENV PROTOC=/home/$NB_USER/work/tensorflow/models/research/protoc330/bin/protoc


RUN fix-permissions /home/$NB_USER && \
    fix-permissions /home/$NB_USER/work  && \
    fix-permissions /home/$NB_USER/work/tensorflow && \
    fix-permissions /home/$NB_USER/work/tensorflow/models

RUN chmod 777 /home/$NB_USER/work/tensorflow/models
RUN chmod 777 /home/$NB_USER/work/tensorflow/models/research/protoc330/bin/protoc

# From tensorflow/models/research/
RUN ./protoc330/bin/protoc object_detection/protos/*.proto --python_out=.
RUN export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
