#commands adapted from the BDP1 course notes

chmod 775 /project_data/                   #grant read, write, and execute permissions to the owner (master node) of the directory and to the group associated to it, but only read and execute permissions (4+1) to other users (worker nodes)

############IN THE SERVER (MASTER)############
sudo su - 

yum install nfs-utils rpcbind
systemctl enable nfs-server
systemctl enable rpcbind
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
systemctl status nfs              #verify that nfs status is active

vi /etc/exports                   #add the following lines in the the exports file (as much lines as clients you have). This will make the /project_data directory accessible to the worker nodes 
#          /project_data <WORKER1_PRIVATE_IP>(rw,sync,no_wdelay)
#          /project_data <WORKER2_PRIVATE_IP>(rw,sync,no_wdelay)

exportfs -r                       #export the changes, so that NFS-server is accessible from the client
exportfs                          #check that the desired directory has been exported to the desired IP address

###########IN THE CLIENTS (WORKERS)###########
sudo su -
yum install nfs-utils
mkdir /project_data               #create the directory from where you want the NFS client to access the NFS server
vi /etc/fstab                     #add the following line at the end of the fstab file. This will allow the NFS to be mounted automatically at boot time
#          <MASTER_PRIVATE_IP>:/project_data /project_data   nfs defaults        0 0

mount -a                          #mount the changes
