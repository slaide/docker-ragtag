# docker-ragtag
docker container to run ragtag/mummer. runs in ragtag scaffold mode by default (but can be changed to any other ragtag/mummer command).

## how to run

### run locally using docker

to run this container on your own computer:
1. install [docker desktop](https://www.docker.com/products/docker-desktop/)
1. start the docker desktop application, and just leave that window open in the background
1. in the terminal on your computer, run:
    ```sh
    git clone https://github.com/slaide/docker-ragtag
    cd docker-ragtag
    # create folder for input and output files 
    mkdir -p ./myfiles/ragtag_output \
    mkdir -p ./myfiles/ragtag_input
    
    # copy the input files into the directory where the image/container can access them 
    cp /path/to/my_reference.fasta ./myfiles/ragtag_input/reference.fasta \
    cp /path/to/my_query.fasta ./myfiles/ragtag_input/query.fasta
    
    # this commands build the image from the instructions in the dockerfile, this will take a couple minutes \
    docker build -t bioinf/ragtag:2.1.0 -f ragtag.Dockerfile .
    
    # ----- stop here if you want to run this container with singularity in the cloud/hpc
    
    # this actually runs your scaffold query, so it might take a LONG time (minutes, hours, days...) \
    docker run bioinf/ragtag:2.1.0
    ```

if you want to make any adjustments to the container, e.g. to run a different ragtag command, see the dockerfile documentation [here](https://docs.docker.com/reference/dockerfile/). then you can change ```docker-ragtag/Dockerfile``` and continue from there.

### run on hpc/cloud with singularity

documentation for the singularity application is [here](https://docs.sylabs.io/guides/3.6/user-guide/cli.html). check out the section on [host architectures](https://github.com/slaide/docker-ragtag/blob/main/README.md#host-computer-architecture) before continuing.

first follow the steps above, but stop at the indicated step, then:
```sh
# Save Docker Image to a Tar File \
docker save -o ragtag210_image.tar bioinf/ragtag:2.1.0

# Copy the Tar File to the remote storage \
rsync -azP ragtag210_image.tar myuser@supercomputerip:/proj/myprojectdir/ragtagstuff

# log into the remote computer and go to the project directory (all following steps afterwards are executed on the remote computer) \
ssh myuser@supercomputerip
cd /proj/myprojectdir/ragtagstuff

# Build Singularity Image from Docker Tar File \
singularity build ragtag210_image.sif ragtag210_image.tar

# Start Singularity Container with a Bind Mount (to write the output files to the remote storage, and not just to the internal file system of the container) \
singularity instance start --bind /hpccloudstorage/proj/myprojectdir/ragtagstuff/ragtagoutput:/root/myfiles/ragtag_output ragtag210_image.sif

# copy the files back to your computer, if desired \
rsync -azP myuser@supercomputerip:/proj/myprojectdir/ragtagstuff/ragtag_output ./myfiles/ragtag_output
```

## notes

### performance considerations 

make sure to adjust the ```-t 1``` argument to change the number of threads to as many as possible. ```1``` is the default (if ```-t <anynumber>``` is omitted, 1 is also used as default by ragtag), but your computer probably has at least 4.

this flag is especially important when this container is run on a cloud resource, where the number of available cores on the host computer is usually specified explicitely (then set the ```-t``` flag to the same number as the host has cores assigned).

### host computer architecture

this container has been tested running on the ARM64 cpu architecture (a macbook with an M1 processor), and on the AMD64 (x86_64) architecture.

if you run this container on a remote computer make sure that the container is built for the cpu architecture of the remote computer! for example, you need to change the build steps above slightly to be able to build the image on an M1 macbook but then run the container on an AMD64 remote computer.

to build the image to run on an amd64 computer, build the image with:
```sh
# note that building for a non-native architecture is a lot slower (expect 2-4x as long) than building for the native architecture. \
docker buildx build --platform linux/amd64 -t bioinf/ragtag:2.1.0 . --load
```

some notes regarding this cross-build:
1. this image cannot be run on a platform other than one with the target architecture, i.e. if this image is built for amd64, it cannot be run on arm64 architecture. to just test the image, build and run it by following the regular instructions above, then cross-build only to run on a remote computer.
1. there are many other platforms available, other than linux/amd64. this cross-build feature is based on [qemu](https://www.qemu.org/), which supports a wide variety of architectures. though note that the linux component in the command is required, since the container image is based on debian linux (which itself does not require cross-building, so e.g. this container using linux can be run on an M1 macbook with macos without having to cross-build to macos/arm64).
1. singularity is not available for macos (in fact, it is only available for linux!). to convert a docker image to singularity on any othe rplatform, regardless of architecture (amd64 vs. arm64, does not matter if this differs between your computer and the computer you want to run the singularity container on), you need to do the conversion inside another docker container. this repository contains a script that handles the cross-build and docker to singularity conversion.
    - the script is this file: [createAMD64Singularity.sh](https://github.com/slaide/docker-ragtag/blob/main/createAMD64Singularity.sh) (run this script inside the ```docker-ragtag``` folder, the .sif file will then also be inside this folder). run this script _after_ you have copied all requisite files into ```./myfiles/ragtag_input```!

## software used

some basic information and links for the software used here

### docker

widely used containerization software. allows packing not just software but software environments into isolated environments for execution on a wide variety of hosts.

links:
- [homepage](https://www.docker.com/)
- [download](https://www.docker.com/get-started/)
- [docker hub](https://hub.docker.com/): online resource hosting a large variety of existing images that be used without (much) additional setup
- [dockerfile docs](https://docs.docker.com/reference/dockerfile/)
- [bind storage](https://docs.docker.com/storage/bind-mounts/) to access storage that exists outside the container from inside the container

### singularity

containerization software, commonly used to run containers in HPC environments. the main difference to docker is a more restrictive container environment, i.e. some container <-> host interactions are possible with docker, but not with singularity. still shares many similarities with docker, hence the existence of tools to convert and run docker images in singularity environments.

links:
- [homepage](https://sylabs.io/)
- [cli docs](https://docs.sylabs.io/guides/3.6/user-guide/cli.html)
- [docker+singularity by NASA](https://www.nas.nasa.gov/hecc/support/kb/converting-docker-images-to-singularity-for-use-on-pleiades_643.html)
- [definition files](https://docs.sylabs.io/guides/3.7/user-guide/definition_files.html)
- [Dockerfile to singularity.def](https://stackoverflow.com/questions/60314664/how-to-build-singularity-container-from-dockerfile)
- information from my local supercomputer ([uppmax](https://www.uppmax.uu.se/)) on docker+singularity:
    - [user guide](https://www.uppmax.uu.se/support/user-guides/singularity-user-guide/)
    - [docker+singularity basics](https://pmitev.github.io/UPPMAX-Singularity-workshop/docker2singularity/)

### ragtag

software repo [here](https://github.com/malonge/RagTag). used for all sorts of genomics calculations. this container is using ragtag version ```2.1.0```, released on _Oct 31, 2021_.

### mummer

this software is used by ragtag. the latest mummer version at the time of this writing is ```4.0.0rc1```, released on _Oct 2, 2020_, source code available [here](https://github.com/mummer4/mummer/releases/tag/v4.0.0rc1).

mummer is not compiled in 64bit mode by default (unrelated to the arm64 vs amd64 aspect), but this container fixes that (also see [#5](https://github.com/marbl/MUMmer3/issues/5)). if you have seen an issue like the following, this container might be the solution:
> mummer: suffix tree construction failed: textlen=1246843428 larger than maximal textlen=536870908
