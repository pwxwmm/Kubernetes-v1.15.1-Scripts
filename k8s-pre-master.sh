#!/bin/bash

#Author:weimengmeng
#Date:August 3, 2019
#Mail:1300042631@qq.com
#Version:v0.1
#K8s:V1.15.1
#Docker:V18.09.1
#This is Kubernetes Install One-Click Scripts

source /opt/k8s-openrc.sh

printf "==========================================\n"
printf "+                                        +\n"
printf "+                                        +\n"
echo -e "\033[32m+    Hi.    Welcome To Kubernetes        +\033[0m"
printf "+                                        +\n"
printf "+                                        +\n"
printf "==========================================\n"

#-------------------Judge EveryOne Node Hostname------------------------------
if [[ `ip a |grep -w $HOST_MASTER_IP ` != '' ]];then
        hostnamectl set-hostname $HOST_MASTER_NAME
elif [[ `ip a |grep -w $HOST_WORKER1_IP ` != '' ]];then
        hostnamectl set-hostname $HOST_WORKER1_NAME
elif [[ `ip a |grep -w $HOST_WORKER2_IP ` != '' ]];then
        hostnamectl set-hostname $HOST_WORKER2_NAME
else
        hostnamectl set-hostname $HOST_MASTER_NAME
fi

#--------------------Hosts Map----------------------------
sed -i -e "/$HOST_MASTER_NAME/d" -e "/$HOST_WORKER1_NAME/d"  -e "/$HOST_WORKER2_NAME/d" /etc/hosts
echo "$HOST_MASTER_IP $HOST_MASTER_NAME" >> /etc/hosts
echo "$HOST_WORKER1_IP $HOST_WORKER1_NAME" >> /etc/hosts
echo "$HOST_WORKER2_IP $HOST_WORKER2_NAME" >> /etc/hosts

#------------------DNS Examine-------------------
sed -i -e 's/#UseDNS yes/UseDNS no/g' -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config

#----------------Judge  install software for  wget--------------------
TMP_WGET=`rpm -qa wget`
if [ $TMP_WGET==" " ];then
    echo -e "\033[33m##-----------------------------Please wait a moment Checking install  wget------------------------##\033[0m"
    yum install -y wget
else
    echo -e "\033[31mThis wget aleary exist\n\033[0m"
fi
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache


#-----------------Selinux config---------------------
sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
getenforce 

#-----------------Firewalld config---------------
systemctl stop firewalld & systemctl disable firewalld

#-----------------Swap config--------------------
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

#-----------------Judge Install Need Software yum-utils.noarch---------------------
TMP_YUMUTILS=`rpm -qa yum-config-manager`
if [ $TMP_YUMUTILS==" " ];then
    echo -e "\033[33m##----------------------------------------Please wait a moment installing yum-utils.noarch----------------------##\n\033[0m"
    yum install -y yum-utils.noarch
else
    echo -e "\033[31mThe software for yum-utils.noarch aleary exist\n\033[0m"
fi

#------ailiyun.Registry----------------
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#-----------------Install Docker-----------------
yum install docker-ce-18.09.8-3.el7 -y

printf "\033[35m $(docker --version)\n\033[0m"

#-----------------Docker config------------------
systemctl start docker & systemctl enable docker

#-----------------Judge Docker run-----------
docker run hello-world > /opt/Hello_Docker.txt 
HELLO_DOCKER=`cat Hello_Docker.txt | grep -o Hello[[:space:]]from[[:space:]]Docker`
if [ ! "$HELLO_DOCKER" ];then
    printf "Docker Run is failed\n"
    exit
else
    echo -e "\033[32mDocker Run Successful!\n\033[0m"
fi

#=============k8s.yum.repo============
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg  http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

#=============k8s.install.kubelet、kubeadm、kubectl==============
yum install -y kubelet kubeadm kubectl
echo 'Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs" '  >> /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf 
systemctl daemon-reload
systemctl enable kubelet && systemctl start kubelet


#=============Download.K8S===================
 echo -e "\033[32mUp to date version\n\033[0m"
kubeadm config images list

#=============pull images====================
#kubeadm config images list |sed -e 's/^/docker pull /g' -e 's#k8s.gcr.io#pwxwmm#g' |sh -x
docker pull pwxwmm/kube-controller-manager:v1.15.1
docker pull pwxwmm/kube-apiserver:v1.15.1
docker pull pwxwmm/kube-scheduler:v1.15.1
docker pull pwxwmm/kube-proxy:v1.15.1
docker pull pwxwmm/pause:3.1
docker pull pwxwmm/etcd:3.3.10
docker pull pwxwmm/coredns:1.3.1

#=============Alter Tag=====================
docker images |grep pwxwmm |awk '{print "docker tag ",$1":"$2,$1":"$2}' |sed -e 's#pwxwmm#k8s.gcr.io#2' |sh -x
#docker tag coredns/coredns:1.3.1  k8s.gcr.io/coredns:1.3.1
#docker tag  mirrorgooglecontainers/kube-apiserver-amd64:v1.15.1 k8s.gcr.io/kube-apiserver:v1.15.1
#docker tag  mirrorgooglecontainers/kube-scheduler-amd64:v1.15.1 k8s.gcr.io/kube-scheduler:v1.15.1
#docker tag  mirrorgooglecontainers/kube-controller-manager-amd64:v1.15.1 k8s.gcr.io/kube-controller-manager:v1.15.1
#docker tag  mirrorgooglecontainers/kube-proxy-amd64:v1.15.1  k8s.gcr.io/kube-proxy:v1.15.1
#docker tag  mirrorgooglecontainers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
#docker tag  mirrorgooglecontainers/pause:3.1 k8s.gcr.io/pause:3.1

#=============Delete Repeat images===========
docker images | grep pwxwmm | awk '{print "docker rmi "  $1":"$2}' | sh -x
#docker rmi coredns/coredns:1.3.1


#==============K8s.Init=================
echo "1" >/proc/sys/net/bridge/bridge-nf-call-iptables
kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v1.15.1 --apiserver-advertise-address=$HOST_MASTER_IP  > /opt/k8s.init.txt

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#==============Create Internet=============
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
kubectl get pods -n kube-system

#==============Schedule The Node For Pod  With Master =============
kubectl taint nodes --all node-role.kubernetes.io/master-


printf "==================================================================================================\n"
printf "+                                                                                                +\n"
printf "+ If you want See kubeadm join Token, Please Use cat Command See Master Node: /opt/k8s-init.txt  +\n"
printf "+                                                                                                +\n"
printf "+ If has place of the mistake, asks respectfully to point out mistakes.                          +\n"
printf "+                                                                                                +\n"
printf "+ You can contact me ,Mail:1300042631@qq.com                                                     +\n"
printf "+                                                                                                +\n"
printf "==================================================================================================\n"


printf "==============================================\n"
printf "+                                            +\n"
printf "+                                            +\n"
echo -e "\033[32m+  Kubernetes Install Completed.   ByeBye    +\033[0m"
printf "+                                            +\n"
printf "+                                            +\n"
printf "==============================================\n"
