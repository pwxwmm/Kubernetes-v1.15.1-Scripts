# Kubernetes-v1.15.1-Scripts
This is Kubernetes One-click Scripts



Firstly: 

      Please download three scripts ,There are k8s-openrc.sh and k8s-pre-master.sh and k8s-pre-worker.sh  
 
      Forexample:
 
            Master: k8s-openrc.sh 、k8s-pre-master.sh.
            Worker1: k8s-openrc.sh 、 k8s-pre-worker.sh 
            Worker1: k8s-openrc.sh 、 k8s-pre-worker.sh 

 

Secondly:

         First According to your own needs  configuration    k8s-openrc.sh 
   


Thirdly:

        
        In Kubernetes Master Node , Execute the Command          source k8s-pre-master.sh
 
        Then, In Kubernetes Worker Node , Execute the Command       source k8s-pre-worker.sh
           
           
           
           
  

In fact , If you Can See kubeadm join Token, Please Use cat Command See /opt/k8s-init.txt   




Finally： If has place of the mistake, asks respectfully to point out mistakes.
