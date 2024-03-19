export TARGET_ARCH=amd64
# cross-build ragtag image for $TARGET_ARCH architecture
docker buildx build --platform linux/$TARGET_ARCH -t bioinf/ragtag:2.1.0-$TARGET_ARCH -f ragtag.Dockerfile . --load
# save to local .tar file
docker save -o ragtag.tar bioinf/ragtag:2.1.0-$TARGET_ARCH
# build the tar2sif image, which will copy the .tar file above, convert it to .sif during the image building process
docker buildx build --platform linux/$TARGET_ARCH -f tar2sif.Dockerfile -t util/tar2sif:latest .
# just create a dummy container from the image to be able to copy the .sif file out of it
# the target architecture for this container is amd64, which presumebly is not compatible \
# with the architecture of the host system, so we could not run this container even if we wanted to
docker create --name tar2sif_container util/tar2sif
# copy the file out of the container to the host
docker cp tar2sif_container:/root/ragtag.sif ragtag-2.1.0-$TARGET_ARCH.sif
# delete the container
docker rm tar2sif_container
