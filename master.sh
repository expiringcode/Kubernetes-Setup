#!/bin/bash

## Master

CURRENT_OUTBOUND_IP=$1

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$CURRENT_OUTBOUND_IP # Using flannel

# Configuring system for ipv4 to use by kube-flannel
sysctl net.bridge.bridge-nf-call-iptables=1

exit

# Configuring kubeadm to be run from a non-root user
mkdir -p $HOME/.kube
sudo cp -if /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# cat of config to be used from remote kubectl
cat $HOME/.kube/config

# adding flannel network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml


## create authentication configuration file
mkdir -p kube-config
touch kube-config/config-cluster

# register two clusters (or more)
#kubectl config --kubeconfig=kube-config/config-cluster set-cluster development --server=https://1.2.3.4 --certificate-authority=fake-ca-file
#kubectl config --kubeconfig=kube-config/config-cluster set-cluster scratch --server=https://5.6.7.8 --insecure-skip-tls-verify
kubectl config --kubeconfig=kube-config/config-cluster set-cluster development --server=https://$CURRENT_OUTBOUND_IP --insecure-skip-tls-verify

# create credentials
#kubectl config --kubeconfig=kube-config/config-cluster set-credentials developer --client-certificate=fake-cert-file --client-key=fake-key-seefile
#kubectl config --kubeconfig=kube-config/config-cluster set-credentials experimenter --username=exp --password=some-password
kubectl config --kubeconfig=kube-config/config-cluster set-credentials developer --username=dev --password=dev

# configure user for cluster and 
#kubectl config --kubeconfig=kube-config/config-cluster set-context dev-frontend --cluster=development --namespace=frontend --user=developer
#kubectl config --kubeconfig=kube-config/config-cluster set-context dev-storage --cluster=development --namespace=storage --user=developer
#kubectl config --kubeconfig=kube-config/config-cluster set-context exp-scratch --cluster=scratch --namespace=default --user=experimenter
kubectl config --kubeconfig=kube-config/config-cluster set-context development --cluster=development --namespace=development --user=developer

# View configuration
kubectl config --kubeconfig=config-cluster view