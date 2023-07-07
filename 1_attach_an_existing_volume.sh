###########TO MOUNT THE VOLUME INTO THE NODE###########
sudo su -                                 #move to root
mkdir /project_data                       #create directory where to mount the volume
fdisk -l                                  #list the disk partitions and retrieve volume path
mount -t ext4 /dev/xvdf1 /project_data/   #mount volume path to directory path
##############TO MAKE THE MOUNT PERMANENT##############
vi /etc/fstab                             #add this line at the end of the fstab file: /dev/xvdf1	/project_data	ext4 defaults 0 0
mount -a                                  #mount all the filesystem listed in the fstab file
