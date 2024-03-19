export GO_VERSION=1.21.0
export GO_ARCH=$(uname -m | awk '{print ($1 == "aarch64") ? "arm64" : $1}')
export OS=linux

wget https://dl.google.com/go/go$GO_VERSION.$OS-$GO_ARCH.tar.gz
sudo tar -C /usr/local -xzvf go$GO_VERSION.$OS-$GO_ARCH.tar.gz
rm go$GO_VERSION.$OS-$GO_ARCH.tar.gz
