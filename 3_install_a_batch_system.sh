#################INSTALL DEPENDENCIES ON THE MASTER AND WORKER(S) NODES#################
yum install wget -y                                                                 #Install wget if not already installed
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm             
yum localinstall epel-release-latest-7.noarch.rpm -y
yum clean all

##########INSTALL CONDOR REPOS AND PACKAGES ON THE MASTER AND WORKER(S) NODES###########
wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo
cp htcondor-stable-rhel7.repo /etc/yum.repos.d/
yum install condor-all -y

#####################CONDOR BASIC CONFIGURATION ON THE MASTER NODE######################
cd                                                                                   #In both master and worker(s) we have to modify the condor_fig file to configure our nodes in HTCondor system
vi /etc/condor/condor_config
                                                                                     #In the config_file of the master node add at the end the following lines
#CONDOR\_HOST = master Private IP address                                            #Specify the private IP of the master
#DAEMON\_LIST = COLLECTOR, MASTER, NEGOTIATOR, STARTD, SCHEDD                        #The master node is configured as collector, master, negotiator, executer and scheduler
#HOSTALLOW\_READ = * 
#HOSTALLOW\_WRITE = * 
#HOSTALLOW\_ADMINISTRATOR = *

####################CONDOR BASIC CONFIGURATION ON THE WORKER NODE(S)####################
cd
vi /etc/condor/condor_config
                                                                  #In the config_file of the worker node add at the end the following lines
#CONDOR\_HOST = worker Private IP address                         #Specify the private IP of the master
#on the nodes DAEMON\_LIST = MASTER, STARTD                       #The worker node is configured as master and executer
#HOSTALLOW\_READ = * 
#HOSTALLOW\_WRITE = * 
HOSTALLOW\_ADMINISTRATOR = *
                                                                  #Remember that the security Group must allow tcp for ports 0 - 65535 from the same security group, i.e.: All TCP TCP 0 - 65535 sg-008742ba0467986fe (aws_condor) Security group must allow ping
                                                                  #...from the same security group, i.e.: All ICMP-IPv4 All N/A sg-008742ba0467986fe (aws_condor) Security group must allow ssh on port 22 from everywhere as ususal
##############CONDOR FINAL CONFIGURATION ON THE MASTER AND WORKER(S) NODES##############
systemctl status condor
systemctl start condor                                            #Start condor...
systemctl enable condor                                           #...and check that it works
systemctl status condor
ps -aux | grep condor
