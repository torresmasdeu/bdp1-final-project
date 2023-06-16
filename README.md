## 1. Build a cloud computing infrastructure 
We want to create two geographically distributed computing sites, composed by at least 2 nodes each: one master and at least one worker. To do that, click on the "Launch instance" button in the instance page of EC2 AWS. From this page, create the VMs.

Give a proper name to the istances (master site1 - worker site1 - master site2 - worker site2)

Select the Red Hat distribution RHEL-7.9 or another open source Linux distribution; we decided to use the RHEL-7.9_HVM-20221027-x86_64-0-Hourly2-GP2 version, published on the 2022-10-27. 

Select a tipe of instance for each node: we selected t2-large (2 CPU, 8 GB RAM) for all.

Create a new key pair (e.g BDP1_project). You will do this just once and save the .pem document. When you create a second instance you have to select this pair of keys. 

To simulate the geographical sepration, select two differend subnets in the netwrok settings. For example, we selected:
site 1: us-east 1a
site 2: us-east 1c

You have to create a security group for each site (create it for master, select existing for workers)
site1 sec group: site1-security
site2 sec group: site2-security

Modify inbound security groups rules so that only you can access the sites: 
remove default (open to all, 0.0.0.0/0) and restricted to the current IP address:
```Security group rule 1 (TCP, 22, <your_IP>/32, SSH for my IP address)```

You can select different size storage, default being 10 gb. We selected 30 gp2 for site2, site1 default)

all other things default. create instances

### OPTIONAL

connect to instance
open .bashrc

paste 
```
PS1="\[\033[01;32m\]\u@<prompt_name>\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
```
to have nicer bash prompt
