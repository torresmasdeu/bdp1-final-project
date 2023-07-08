#################INSTALL DEPENDENCIES ON THE MASTER AND WORKER(S) NODES#################
yum install wget -y 
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum localinstall epel-release-latest-7.noarch.rpm -y
yum clean all

############INSTALL CONDOR REPOS AND PACKAGES ON THE MASTER AND WORKER NODES############
wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo
cp htcondor-stable-rhel7.repo /etc/yum.repos.d/
yum install condor-all -y

#####################CONDOR BASIC CONFIGURATION ON THE MASTER NODE######################

On the master node, the /etc/condor/condor\_config was modified as such:

#CONDOR\_HOST = master Private IP address

#DAEMON\_LIST = COLLECTOR, MASTER, NEGOTIATOR, STARTD, SCHEDD

#HOSTALLOW\_READ = * HOSTALLOW\_WRITE = * HOSTALLOW\_ADMINISTRATOR =

####################CONDOR BASIC CONFIGURATION ON THE WORKER NODE(S)####################
on the worker nodes, the same file was modified as such:
#CONDOR\_HOST = worker Private IP address
#on the nodes DAEMON\_LIST = MASTER, STARTD
#HOSTALLOW\_READ = * HOSTALLOW\_WRITE = * HOSTALLOW\_ADMINISTRATOR = *

##############CONDOR FINAL CONFIGURATION ON THE MASTER AND WORKER(S) NODES##############
systemctl status condor
systemctl start condor
systemctl enable condor
systemctl status condor
ps -aux | grep condor
