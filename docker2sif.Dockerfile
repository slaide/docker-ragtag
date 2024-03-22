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

# -- begin ragtag section
RUN apt install -fy make cmake tree micro wget curl git tar virtualenv
RUN apt install -fy gcc g++
# -- end ragtag section

WORKDIR /root

RUN virtualenv venv
ENV py3=/root/venv/bin/python3
RUN $py3 -m pip install --upgrade pip
RUN $py3 -m pip install spython

# -- begin ragtag section
RUN $py3 -m pip install RagTag==2.1.0
# -- end ragtag section

# -- begin ragtag section
RUN wget https://github.com/mummer4/mummer/releases/download/v4.0.0rc1/mummer-4.0.0rc1.tar.gz
RUN tar -xvf mummer-4.0.0rc1.tar.gz

RUN cd mummer-4.0.0rc1 && \
	 ./configure --prefix /root/mummer4 && \
	 make -j CPPFLAGS="-O3 -DSIXTYFOURBITS" && \
	 make install && \
	 cd /root
# -- end ragtag section

# install go, which singularity is written in
COPY installGO.sh installGO.sh
RUN sh installGO.sh

ENV PATH="/usr/local/go/bin:$PATH"

COPY installSingularity.sh installSingularity.sh
ENV SINGULARITY_VERSION=4.1.0
RUN sh installSingularity.sh
	
ENV PATH="/root/local/singularity-ce-${SINGULARITY_VERSION}:$PATH"

COPY ragtag.Dockerfile ragtag.Dockerfile
RUN /root/venv/bin/spython recipe ragtag.Dockerfile > ragtag.def

# make input files visible to singularity
COPY ragtag_input /root/ragtag_input/

# required for ragtag to internally be able to run subcommands (which \
# is done by using popen, without doing any lookup themselves..)
ENV PATH="/root/venv/bin:${PATH}"

RUN chmod +x /root/venv/bin/*
RUN chmod +x /root/mummer4/bin/*

RUN mkdir -p /root/ragtag_output

COPY runragtag.sh /root/runragtag.sh
RUN chmod +x /root/runragtag.sh

COPY runsingularity.sh /root/runsingularity.sh
RUN chmod +x /root/runsingularity.sh

# this needs to be run with elevated privileges (hence the --privileged flag in the docker run command)
ENTRYPOINT ["/root/runsingularity.sh"]
