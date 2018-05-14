#!/bin/sh

IP=192.168.1.120:6443
TOKEN='1v3mb1.7wwoh58wh515q726'
DISCOVERY_TOKEN='sha256:7f995b3396fba6d2d7770ce6f19a7fbb012cb83aadb9df06c756f2632d951028'


kubeadm join $IP --token $TOKEN --discovery-token-ca-cert-hash $DISCOVERY_TOKEN 

# --discovery-token-unsafe-skip-ca-verification to not use a discovery token

kubectl config --kubeconfig=config-demo set-credentials experimenter --username=exp --password=some-password