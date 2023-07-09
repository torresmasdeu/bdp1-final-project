##################ON THE SERVER##################

cat /etc/yum.repos.d/epel.repo                      #enable the epel repository as done for condor, you should see have this file

yum install httpd                                    #Install Apache

sed -i 's/^/#&/g' /etc/httpd/conf.d/welcome.conf    #Disable Apache's default welcome page

sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/httpd/conf/httpd.conf #Prevent the Apache web server from displaying files within the web directory

systemctl start httpd.service                       #Start the service 

httpd -M | grep dav

#You should see as output something like
#   dav_module (shared)
#   dav_fs_module (shared)
#   dav_lock_module (shared)

mkdir /var/www/html/webdav
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

#you need to create a user account, to access the WebDAV server (e.g. bdp1_project), and then input your desired password. 
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

#####

setenforce 0                                        #disable selinux if enabled

systemctl restart httpd.service

yum install cadaver                                 #to be able to connect to your WebDav server
cadaver http://<private-server-ip>/webdav/
          username: <your_username>
          password: <your_password>

##################ON THE CLIENT##################

yum install cadaver
cadaver http://<public-server-ip>/webdav/
          username: <your_username>
          password: <your_password>


#################WEBDAV COMMANDS#################
mkdir <dirname>                                     #create said directory

cd <dirname>                                        #move into said directory

ls <dirname>                                        #list contents of said directory

put <path/filename>                                 #upload said file to WebDav

get <filename>                                      #download said file to current directory (outside WebDav)

exit                                                #to exit webdav prompt
