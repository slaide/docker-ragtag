# docker-ragtag
docker container to run ragtag/mummer. runs in ragtag scaffold mode by default (but can be changed to any other ragtag/mummer command).

## how to run

to run this container on your own computer:
1. install [docker desktop](https://www.docker.com/products/docker-desktop/)
1. start the docker desktop application, and just leave that window open in the background
1. in the terminal on your computer, run:
    1. ```git clone https://github.com/slaide/docker-ragtag ```
    1. ```cd docker-ragtag ```
    1. ```cp /path/to/my_reference.fasta ./myfiles/reference.fasta ```
    1. ```cp /path/to/my_query.fasta ./myfiles/query.fasta ```
    1. ```docker build -t bioinf/mummer:4.0.0rc1 -f Dockerfile .``` - this will take a couple minutes
    1. ```docker run bioinf/mummer:4.0.0rc1``` - this actually runs your scaffold query, so it might take a LONG time (minutes, hours, days...)

## notes

make sure to adjust the ```-t 1``` argument to change the number of threads to as many as possible. 1 is the default (if ```-t <anynumber>``` is omitted, 1 is also used as default by ragtag), but your computer probably has at least 4

## ragtag

software repo [here](https://github.com/malonge/RagTag). used for all sorts of genomics calculations. this container is using ragtag version ```2.1.0```, released on _Oct 31, 2021_.

## mummer

this software is used by ragtag. the latest mummer version at the time of this writing is ```4.0.0rc1```, released on _Oct 2, 2020_, source code available [here](https://github.com/mummer4/mummer/releases/tag/v4.0.0rc1).

mummer is not compiled in 64bit mode by default, but this container fixes that (also see [#5](https://github.com/marbl/MUMmer3/issues/5)). if you have seen an issue like the following, this container might be the solution:
> mummer: suffix tree construction failed: textlen=1246843428 larger than maximal textlen=536870908

# notes on compatibility

this container has been tested running on the ARM64 cpu architecture (a macbook with an M1 processor), and will be tested on x86_64 (a supercomputer node) as well.
