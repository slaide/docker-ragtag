docker buildx build --platform linux/amd64 -t bioinf/ragtag:2.1.0-amd64 . --load
docker run -v /var/run/docker.sock:/var/run/docker.sock -v /Users/$(whoami)/Downloads:/output --privileged -t --rm singularityware/docker2singularity bioinf/ragtag:2.1.0-amd64
