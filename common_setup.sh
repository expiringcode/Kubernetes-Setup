#!/bin/bash

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common #\
    #golang-go

## To mount a shared folder after installing vbox
# mount -t vboxsf Scripts /media/scripts

## Check mac address and product_uuid
#
echo `ip link`
sudo cat /sys/class/dmi/id/product_uuid

## Adding docker
#
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

## Adding Kubectl Kubeadm and Kubelet
#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

## Checking Docker cgroup which should match kubelet cgroup (on master node)
#
docker info | grep -i cgroup
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

## Update cgroup driver to systemd
sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS\ --cgroup-driver=systemd/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

cat <<EOF >/etc/docker/daemon.json
{
	"exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

## Restart kubelet
systemctl daemon-reload
systemctl restart kubelet
systemctl restart docker


## Disable Swap in Ubuntu
# Gets swap id
# cat /proc/swaps
# Turns swap off
# swapoff -a
# Remove from /etc/fstab
# /etc/fstab
 

## Install crictl
## Run from root
cd $HOME

## Installing Golang
sudo curl -O https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz

sudo tar -xvf go1.8.linux-amd64.tar.gz
sudo mv go /usr/local

echo "export GOROOT=/usr/local/go" >> ~/.profile
echo "export GOPATH=\$HOME/go" >> ~/.profile
echo "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin" >> ~/.profile
source ~/.profile

go version
go get github.com/kubernetes-incubator/cri-tools/cmd/crictl