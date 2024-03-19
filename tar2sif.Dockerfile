FROM debian:bookworm

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
   sudo

WORKDIR local

# install go, which singularity is written in
COPY installGO.sh installGO.sh
RUN sh installGO.sh

ENV PATH="/usr/local/go/bin:$PATH"

COPY installSingularity.sh installSingularity.sh
ENV SINGULARITY_VERSION=4.1.0
RUN sh installSingularity.sh
	
ENV PATH="/root/local/singularity-ce-${SINGULARITY_VERSION}:$PATH"

COPY ragtag.tar ragtag.tar

RUN singularity build -d ragtag.sif docker-archive://ragtag.tar
RUN cp ragtag.sif /root/ragtag.sif
