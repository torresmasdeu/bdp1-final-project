sudo su -                                                                      #become root

##############INSTALL DOCKER on a RHEL7.6 VM##############

yum install vim wget                                                           #install vim and wget

vim /etc/yum.repos.d/docker-ce.repo                                            #edit the docker-ce-repo file:

##########################################################
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
##########################################################

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm    #install the epel repo

yum localinstall epel-release-latest-7.noarch.rpm

yum install yum-utils device-mapper-persistent-data lvm2                       #install dependencies
yum install container-selinux -y


yum install docker-ce docker-ce-cli containerd.io -y                           #install docker

systemctl status docker                                                        #start docker
systemctl start docker
systemctl status docker
systemctl enable docker

usermod -g docker ${USER}                                                      #to access docker from ec2-user

exit                                                                           #go back to user

##########CREATE A DOCKERIMAGE FROM A DOCKERFILE##########
mkdir docker                                                                   #make a dir where the image will be stored
cd docker/                                                                     #move into the dir
vim Dockerfile                                                                 #edit the Dockerfile that will make the image

docker build -t <image_name> .                                                 #build the image

docker login                                                                   #login to dockerhub to be able to push the image

docker images                                                                  #retreive the tag of your image 

docker tag <image_tag> <dockerhub_username>/<image_name>:<image_name>
docker push <dockerhub_username>/<image_name>:<image_name>                     #push the image created from the Dockerfile to DockerHub

#################SET UP DOCKER FOR CONDOR#################
sudo su -                                                                      #become root
usermod -aG docker condor                                                      #add HTCondor to the Docker group so that it can manage containers

vim /etc/condor/condor_config                                                  #edit the condor config file to include Docker volumes:
##########################################################
DOCKER_VOLUMES = BDP1_DATA                                                     #name of the docker volume that HTCondor creates
DOCKER_VOLUME_DIR_BDP1_DATA = /project_data                                    #host path where HTCondor stores the Docker volume
DOCKER_MOUNT_VOLUMES = BDP1_DATA                                               #Docker volume that HT_CONDOR mounts
##########################################################

systemctl restart condor                                                       #reset condor
systemctl enable condor

condor_status -af HasDocker                                                    #check that all nodes have Docker enabled for condor. IMPORTANT: install Docker and set it up for HTCondor use in all nodes
