FROM python:3.11-bookworm

RUN apt update
RUN apt install -fy make cmake tree micro wget curl git tar virtualenv
RUN apt install -fy gcc g++

RUN mkdir -p /root
WORKDIR /root

RUN wget https://github.com/mummer4/mummer/releases/download/v4.0.0rc1/mummer-4.0.0rc1.tar.gz
RUN tar -xvf mummer-4.0.0rc1.tar.gz

# we configure and build inside the mummer source code directory
# then cd back to /root (our workdir)
#   - this is superfluous in dockerfile
#   - but required in singularity
RUN cd mummer-4.0.0rc1 && \
	 ./configure --prefix /root/mummer4 && \
	 make -j CPPFLAGS="-O3 -DSIXTYFOURBITS" && \
	 make install && \
	 cd /root
	 
RUN virtualenv venv
ENV py3=/root/venv/bin/python3
RUN $py3 -m pip install --upgrade pip
RUN $py3 -m pip install RagTag==2.1.0

# copy all files from myfiles/* into the container
# $ tree
# docker-ragtag
# ├── LICENSE
# ├── README.md
# ├── < lots of other files >
# └── ragtag_input
#     ├── reference.fasta
#     └── query.fasta

COPY ragtag_input /root/ragtag_input/

# required for ragtag to internally be able to run subcommands (which \
# is done by using popen, without doing any lookup themselves..)
ENV PATH="/root/venv/bin:${PATH}"

RUN chmod +x /root/venv/bin/*
RUN chmod +x /root/mummer4/bin/*

RUN mkdir -p /root/ragtag_output

COPY runragtag.sh /root/runragtag.sh
RUN chmod +x /root/runragtag.sh

#ENTRYPOINT /root/venv/bin/python3
# CMD /root/venv/bin/python3 /root/venv/bin/ragtag.py scaffold /root/ragtag_input/reference.fasta /root/ragtag_input/query.fasta -u -t 1 --aligner /root/mummer4/bin/nucmer
# CMD /root/mummer4/bin/nucmer --maxmatch -l 100 -c 500 -p /root/ragtag_output/ragtag.scaffold.asm /root/ragtag_input/reference.fasta /root/ragtag_input/query.fasta
CMD /root/runragtag.sh
