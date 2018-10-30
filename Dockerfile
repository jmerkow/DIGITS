FROM nvidia/cuda:9.2-cudnn7-runtime-ubuntu16.04

RUN apt-get update && apt-get install -y wget

#ENV CUDA_REPO_PKG http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
#RUN wget "$CUDA_REPO_PKG" -O /tmp/cuda-repo.deb && dpkg -i /tmp/cuda-repo.deb && rm -f /tmp/cuda-repo.deb

ENV ML_REPO_PKG http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb
RUN wget "$ML_REPO_PKG" -O /tmp/ml-repo.deb && dpkg -i /tmp/ml-repo.deb && rm -f /tmp/ml-repo.deb

RUN apt-get update
RUN apt-get install --no-install-recommends -y git graphviz python-dev python-flask python-flaskext.wtf python-gevent python-h5py python-numpy python-pil python-pip python-scipy python-tk

RUN pip install --upgrade pip
ENV INSTALL_ROOT /opt


#Caffe
ENV CAFFE_ROOT ${INSTALL_ROOT}/caffe
RUN apt-get update && apt-get upgrade -y \
&& apt-get install -y ca-certificates curl \
&& apt-get install -y apt-utils libldap2-dev \
&& apt-get install -y build-essential cmake git pkg-config net-tools \
&& apt-get install -y libfreetype6 libfreetype6-dev \
&& apt-get install -y wget unzip libpq-dev gfortran \
&& apt-get install -y libffi-dev libssl-dev libxml2-dev libxslt1-dev \
&& apt-get install -y libatlas-base-dev libboost-all-dev libgflags-dev libgoogle-glog-dev \
&& apt-get install -y libhdf5-serial-dev libleveldb-dev liblmdb-dev libprotobuf-dev \
&& apt-get install -y libsnappy-dev protobuf-compiler \
&& apt-get install -y libjasper-dev libgtk2.0-dev libavcodec-dev libavformat-dev \
&& apt-get install -y libswscale-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libv4l-dev \
&& apt-get install -y libopencv-dev libopenblas-dev liblapack-dev graphviz \
&& apt-get install -y libboost-filesystem-dev libboost-python-dev libboost-system-dev libboost-thread-dev libgflags-dev \
&& apt-get install -y python-all-dev python-dev python-h5py python-matplotlib python-numpy python-opencv python-pil \
&& apt-get install -y python-pip python-pydot python-scipy python-skimage python-sklearn

RUN git clone https://github.com/NVIDIA/caffe.git $CAFFE_ROOT -b 'caffe-0.15'
RUN pip install setuptools

RUN pip install -r $CAFFE_ROOT/python/requirements.txt
WORKDIR ${CAFFE_ROOT}
RUN mkdir -p build && cd build && cmake .. && make -j4 && make install
ENV PYTHONPATH $PYTHONPATH:$CAFFE_ROOT/python

RUN pip install tensorflow-gpu==1.2.1

#DIGITS
ENV DIGITS_ROOT ${INSTALL_ROOT}/digits
COPY ./requirements.txt /requirements.txt
COPY ./requirements_test.txt /requirements_test.txt
RUN pip install -r /requirements.txt && pip install -r /requirements_test.txt

COPY ./digits-devserver /digits-devserver
RUN sed -i 's/\r//' /digits-devserver
RUN chmod +x /digits-devserver

COPY ./digits-test /digits-test
RUN sed -i 's/\r//' /digits-test
RUN chmod +x /digits-test

COPY ./entrypoint /entrypoint
RUN sed -i 's/\r//' /entrypoint
RUN chmod +x /entrypoint

COPY . ${DIGITS_ROOT}
RUN pip install -e $DIGITS_ROOT

ENTRYPOINT ["/entrypoint"]






#Torch
#ENV TORCH_ROOT ${INSTALL_ROOT}/torch
#RUN apt-get install --no-install-recommends git software-properties-common libhdf5-serial-dev liblmdb-dev
#RUN luarocks install tds && \
#	luarocks install "https://raw.github.com/deepmind/torch-hdf5/master/hdf5-0-0.rockspec" && \
#	luarocks install "https://raw.github.com/Neopallium/lua-pb/master/lua-pb-scm-0.rockspec" && \
#	luarocks install lightningmdb 0.9.18.1-1 LMDB_INCDIR=/usr/include LMDB_LIBDIR=/usr/lib/x86_64-linux-gnu && \
#	luarocks install "https://raw.githubusercontent.com/ngimel/nccl.torch/master/nccl-scm-1.rockspec" && \
#RUN git clone https://github.com/torch/distro.git $TORCH_ROOT --recursive
#WORKDIR ${TORCH_ROOT}
#RUN ./install-deps && ./install.sh -b && source ~/.bashrc
#ENV PATH ${PATH}:${TORCH_ROOT}/install/bin




