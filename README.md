## 1. Build a cloud computing infrastructure 
We want to create two geographically distributed computing sites, composed by at least 2 nodes each: one master and at least one worker. In this case, we will create 2 sites: 
- Site 1, with 3 nodes: 1 master (`S1_M`) and 2 workers (`S1_W1` and `S1_W2`)
- Site 2, with 2 nodes: 1 master (`S2_M`) and 1 worker (`S2_W1`)

Each site was created using a different AWS account.

### 1.1. Create the nodes
To create each node, click on the "Launch instance" button in the instance page of EC2 AWS.

1. Give a proper name to the istances (`site1_master`, `site1_worker1`, `site1_worker2`, `site2_master`, `site2_worker1`)
2. Select the Red Hat distribution RHEL-7.9 or another open source Linux distribution: we decided to use the `RHEL-7.9_HVM-20221027-x86_64-0-Hourly2-GP2` version, published on the 2022-10-27.
3. Select a tipe of instance for each node: we selected `t2-large` (2 CPU, 8 GB RAM) for all.
4. Create a new key pair (eg:`BDP1_project`). This is done only once, when creating the first instance of each site. Save the key (`.pem`) document to directory (from which you will need to initialise all the instances from this directory, or change the key file directory from the initialisation command). In the other instances, select the previously created key pair.
5. To simulate the geographical sepration, select two differend subnets in the netwrok settings. For example, we selected for site 1 `us-east 1a` and for Site 2 `us-east 1c`.
6. Create a security group for each site (create it for master, select existing for workers). For example, we created for site 1 `ite1-security` and for site 2 `site2-security`.
7. Modify inbound security groups rules so that only you can access the sites: we removed the default (open to all, 0.0.0.0/0) and restricted to the current IP address: ```Security group rule 1 (TCP, 22, <your_IP>/32, SSH for my IP address)```
8. (Optional) Select 
You can select different size storage, default being 10 gb. We selected 30 gp2 for site2, site1 default)

all other things default. create instances

### OPTIONAL

connect to instance
open .bashrc

paste 
```
PS1="\[\033[01;32m\]\u@<prompt_name>\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
```
to have nicer bash prompt (both in normal and root)




add volume in root
```
sudo su -
fdisk -l
mount -t ext4 /dev/xvdf1 /project_data/

vi /etc/fstab
mount -a
chmod 775 /<directory>/
```
775 give us the right to read write and execute in the master but only to read and execute in the workers (put 777 to also write)
in /etc/fstab write
```
/dev/xvdf1	/project_data	ext4 defaults 0 0
```

NFS SERVER

IMPORTANT: add master, worker1 and worker2 private IPs to inbound rules

in the master (still in root):
```
yum install nfs-utils rpcbind
systemctl enable nfs-server
systemctl enable rpcbind
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
systemctl status nfs

vi /etc/exports
```

inside /etc/exports
```
/project_data <WORKER1_PRIVATE_IP>(rw,sync,no_wdelay)
/project_data <WORKER2_PRIVATE_IP>(rw,sync,no_wdelay)
```

finally, export changes:
```
exportfs -r
```

in workers:

```
sudo su -
yum install nfs-utils
mkdir /project_data
vi /etc/fstab
```

inside \etc\fstab
```
<MASTER_PRIVATE_IP>:/project_data /project_data   nfs defaults        0 0
```
mount the changes:
```
mount -a
```
## HT condor
First on the master
INSTALL DEPENDENCIES
```
yum install wget -y 
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum localinstall epel-release-latest-7.noarch.rpm -y
yum clean all
```
INSTALL CONDOR REPOs and PACKAGES
```
wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo
cp htcondor-stable-rhel7.repo /etc/yum.repos.d/
yum install condor-all -y
```
CONDOR BASIC CONFIGURATION
```
cd
vi /etc/condor/condor_config
```
GUIDELINES FOR THE CONDOR_CONFIG FILE
#-------------------------------------
#In the config file add at the end
#the most important variable is the CONDOR_HOST running the master

#ADD the following lines to your condor_config file

#CHANGE THE FOLLOWING IP TO YOUR MASTER IP

CONDOR_HOST = master Private IP address
 
#on the master

DAEMON_LIST = COLLECTOR, MASTER, NEGOTIATOR, STARTD, SCHEDD
 
#on the nodes

DAEMON_LIST = MASTER, STARTD 

#on both

HOSTALLOW_READ = *

HOSTALLOW_WRITE = *

HOSTALLOW_ADMINISTRATOR = *
#-------------------------------------

Security Group must allow tcp for ports 0 - 65535 from the same security group, i.e.:
 All TCP    TCP      0 - 65535     sg-008742ba0467986fe (aws_condor)
Security group must allow ping from the same security group, i.e.:
 All    ICMP-IPv4   All    N/A     sg-008742ba0467986fe (aws_condor)
Security group must allow ssh on port 22 from everywhere as ususal

Once edited the condor_config file you can proceed with the following commands in both master and nodes
```
systemctl status condor
systemctl start condor
systemctl enable condor
systemctl status condor
ps -aux | grep condor
```

## WebDav

on the server: 
```
#enable the epel repository as done for condor, you should see have this file:
cat /etc/yum.repos.d/epel.repo

####

#Install Apache using YUM:
yum install httpd

#Disable Apache's default welcome page:
sed -i 's/^/#&/g' /etc/httpd/conf.d/welcome.conf

#Prevent the Apache web server from displaying files within the web directory:
sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/httpd/conf/httpd.conf

#Start the service 
systemctl start httpd.service

httpd -M | grep dav

#You should see as output something like
#   dav_module (shared)
#   dav_fs_module (shared)
#   dav_lock_module (shared)

mkdir /var/www/html/webdav
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

#you need to create a user account, say it is "user001", to access the WebDAV server, and then input your desired password. 
#Later, you will use this user account to log into your WebDAV server.

htpasswd -c /etc/httpd/.htpasswd bdp1_project
chown root:apache /etc/httpd/.htpasswd
chmod 640 /etc/httpd/.htpasswd

#Create a virtual host for WebDAV

vim /etc/httpd/conf.d/webdav.conf

#Populate it with the following content

DavLockDB /var/www/html/DavLock
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/webdav/
    ErrorLog /var/log/httpd/error.log
    CustomLog /var/log/httpd/access.log combined
    Alias /webdav /var/www/html/webdav
    <Directory /var/www/html/webdav>
        DAV On
        AuthType Basic
        AuthName "webdav"
        AuthUserFile /etc/httpd/.htpasswd
        Require valid-user
    </Directory>
</VirtualHost>
#####################################################

#disable selinux if enabled
setenforce 0
# to have this permanently disabled: https://linuxize.com/post/how-to-disable-selinux-on-centos-7/

systemctl restart httpd.service
```

IMPORTANT: add an inbound rule for port 80 of the **public** client IP to be able to establish a connection

on the client:
IMPORTANT: PUBLIC server IP
```
# On the Client

yum install cadaver
cadaver http://<public-server-ip>/webdav/
          username: f
          password: <your_password>
```

on the server: 
SERVER: private server IP
```
yum install cadaver
cadaver http://<private-server-ip>/webdav/
          username: bdp1
          password: <your_password>
```

to upload files (inside `dav:/webdav/>`): 
`put <path/filename>`: will upload such file to WebDav

to download:
`get <filename>`: will download such file to current directory (outside WebDav)


## docker
become root: `sudo su -`

#######################################
####### INSTALL DOCKER on a RHEL7.6 VM 
#######################################
#install vim and wget
yum install vim wget

#install the docker repo
vim /etc/yum.repos.d/docker-ce.repo
#####################################################
##########   Add the following content in the docker-ce-repo file:

[docker-ce-stable]
name=Docker CE Stable - x86_64
baseurl=https://download.docker.com/linux/centos/7/x86_64/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[centos-extras]
name=Centos extras - x86_64
baseurl=http://mirror.centos.org/centos/7/extras/x86_64
enabled=1
gpgcheck=0
#############################################################

#install the epel repo
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum localinstall epel-release-latest-7.noarch.rpm

#install dependencies (maybe more will be needed, check for errors)
yum install yum-utils device-mapper-persistent-data lvm2
yum install container-selinux -y

# install docker
yum install docker-ce docker-ce-cli containerd.io -y

#start docker
systemctl status docker
systemctl start docker
systemctl status docker
systemctl enable docker

usermod -g docker ec2-user #to access docker from ec2-user DOCKERBUILD DUDNT WORK

exit #go back to user

mkdir docker
cd docker/
vim Dockerfile

######dockerfile
FROM ubuntu
RUN apt update
RUN apt-get install -y python3

COPY /home/ec2-user/docker/align.py align.py
COPY /home/ec2-user/docker/bwa bwa
#########

cp ../proj_100/bwa ../proj_100/align.py .

docker build -t bwa_align . (in root)
