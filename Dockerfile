FROM python:3.11-bookworm

RUN apt update
RUN apt install -fy make cmake tree micro wget curl git tar virtualenv
RUN apt install -fy gcc g++

RUN virtualenv venv
ENV python3=venv/bin/python3
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install RagTag==2.1.0

RUN wget https://github.com/mummer4/mummer/releases/download/v4.0.0rc1/mummer-4.0.0rc1.tar.gz
RUN tar -xvf mummer-4.0.0rc1.tar.gz

RUN cd mummer-4.0.0rc1 ; ./configure --prefix /root/mummer4
RUN cd mummer-4.0.0rc1 ; make -j CPPFLAGS="-O3 -DSIXTYFOURBITS"
RUN cd mummer-4.0.0rc1 ; make install

# copy all files from myfiles/* into the container
# $ tree
# docker-ragtag
# ├── LICENSE
# ├── README.md
# ├── Dockerfile
# └── myfiles
#     ├── reference.fasta
#     └── query.fasta
COPY myfiles myfiles/
WORKDIR myfiles

CMD python3 $(which ragtag.py) scaffold reference.fasta query.fasta -u -t 1 --aligner /root/mummer4/bin/nucmer
