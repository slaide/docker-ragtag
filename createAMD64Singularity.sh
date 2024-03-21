export TARGET_ARCH=amd64

# build the tar2sif image, which will copy the .tar file above, convert it to .sif during the image building process
docker buildx build --platform linux/$TARGET_ARCH -f docker2sif.Dockerfile -t util/docker2sif:latest .
[ $? -eq 0 ] || { echo "Error: building container failed with exit code $?" >&2; exit 1; }
# run container as target arch
docker run --platform linux/$TARGET_ARCH --privileged --name docker2sif_container util/docker2sif
[ $? -eq 0 ] || { echo "Error: running container failed with exit code $?" >&2; exit 1; }

# copy the file out of the container to the host
docker cp docker2sif_container:/root/ragtag.sif ragtag-2.1.0-$TARGET_ARCH.sif

# delete the container
docker rm docker2sif_container
