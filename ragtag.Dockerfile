FROM python:3.11-bookworm

RUN apt update
RUN apt install -fy make cmake tree micro wget curl git tar virtualenv
RUN apt install -fy gcc g++

RUN virtualenv venv
ENV py3=venv/bin/python3
RUN $py3 -m pip install --upgrade pip
RUN $py3 -m pip install RagTag==2.1.0

RUN wget https://github.com/mummer4/mummer/releases/download/v4.0.0rc1/mummer-4.0.0rc1.tar.gz
RUN tar -xvf mummer-4.0.0rc1.tar.gz

RUN cd mummer-4.0.0rc1 && \
	 ./configure --prefix ../mummer4 && \
	 make -j CPPFLAGS="-O3 -DSIXTYFOURBITS" && \
	 make install

# copy all files from myfiles/* into the container
# $ tree
# docker-ragtag
# ├── LICENSE
# ├── README.md
# ├── Dockerfile
# └── ragtag_input
#     ├── reference.fasta
#     └── query.fasta

COPY ragtag_input ragtag_input/
COPY insideContainer_runRagtag.sh insideContainer_runRagtag.sh

ENTRYPOINT sh insideContainer_runRagtag.sh
