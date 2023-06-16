## 1. Build a cloud computing infrastructure 
Give a proper name to the istances (master-worker)
Select the Red Hat distribution RHEL-7.9 or another open source Linux distribution; we decided to use the RHEL-7.9_HVM-20221027-x86_64-0-Hourly2-GP2 version, published on the 2022-10-27. 

t2-large for all

new key pair (BDP1_project). just for masters. for workers, select this one

site 1: us-east 1a
site 2: us-east 1c

(create for master, select existing for workers)
site1 sec group: site1-security
site2 sec group: site2-security

Inbound security groups rules: 
remove default (open to all) and restricted to the current IP address:
```Security group rule 1 (TCP, 22, <your_IP>/32, SSH for my IP address)```

configure storage: 30 gp2 (for site2. site1 default)
all other things default. create instances

connect to instance
open .bashrc

paste 
```
PS1="\[\033[01;32m\]\u@<prompt_name>\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
```

to have nicer bash prompt
