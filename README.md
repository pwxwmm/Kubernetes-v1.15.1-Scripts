# Kubernetes-v1.15.1-Scripts
This is Kubernetes One-click Scripts


      #Author:weimengmeng

      #Date:August 3, 2019
      
      #Mail:1300042631@qq.com

      #Version:v0.1

      #K8s:V1.15.1

      #Docker:V19.03.1




Firstly: 

      Please download three scripts ,There are k8s-openrc.sh and k8s-pre-master.sh and k8s-pre-worker.sh  
 
      Forexample:
 
            Master: k8s-openrc.sh 、k8s-pre-master.sh.
            Worker1: k8s-openrc.sh 、 k8s-pre-worker.sh 
            Worker1: k8s-openrc.sh 、 k8s-pre-worker.sh 
            
         

 

Secondly:

         First According to your own needs  configuration    k8s-openrc.sh 
         As k8s-openrc.sh  : 
         such as :   Hostname   and  IP
                      
                      k8s-node1      192.168.217.131
                      k8s-node2      192.168.217.132
                      k8s-node3      192.168.217.133


Thirdly:

        
        In Kubernetes Master Node , Execute the Command          source k8s-pre-master.sh
 
        Then, In Kubernetes Worker Node , Execute the Command       source k8s-pre-worker.sh
           
           
           
           
  

In fact , If you Can See kubeadm join Token, Please Use cat Command See /opt/k8s-init.txt   




Finally： If has place of the mistake, asks respectfully to point out mistakes.
