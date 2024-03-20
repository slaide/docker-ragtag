FROM python:3.11-bookworm

RUN apt-get update
# singularity build prerequisites
RUN apt-get install -y \
   autoconf \
   automake \
   cryptsetup \
   git \
   libfuse-dev \
   libglib2.0-dev \
   libseccomp-dev \
   libtool \
   pkg-config \
   runc \
   squashfs-tools \
   squashfs-tools-ng \
   uidmap \
   wget \
   zlib1g-dev \
   make \
   cmake \
   sudo \
   virtualenv \
   tree

WORKDIR /root/local

RUN virtualenv venv
ENV python3=venv/bin/python3
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install spython

# install go, which singularity is written in
COPY installGO.sh installGO.sh
RUN sh installGO.sh

ENV PATH="/usr/local/go/bin:$PATH"

COPY installSingularity.sh installSingularity.sh
ENV SINGULARITY_VERSION=4.1.0
RUN sh installSingularity.sh
	
ENV PATH="/root/local/singularity-ce-${SINGULARITY_VERSION}:$PATH"

COPY myfiles myfiles/

COPY ragtag.Dockerfile ragtag.Dockerfile
RUN python3 "$(which spython)" recipe ragtag.Dockerfile > ragtag.def

# this needs to be run with elevated privileges
CMD sudo singularity build ragtag.sif ragtag.def
