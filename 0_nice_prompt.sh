ssh -i "<key_name>.pem" ec2-user@ec2-<AWS_node_public_IP>.compute-1.amazonaws.com                #connect to instance

################IN THE USER################
vi .bashrc                                                                                       #paste the following line at the end of the file

PS1="\[\033[01;32m\]\u@<prompt_name>\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

################IN THE ROOT################
sudo su -
vi .bashrc                                                                                       #paste the following line at the end of the file

PS1="\[\033[01;32m\]\u@<prompt_name>\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

exit                                                                                             #exit root

exit                                                                                             #close connection to ssh

#connection has to be closed and re-initiated to save the changes done to .bashrc
