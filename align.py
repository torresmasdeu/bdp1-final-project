#!/usr/bin/python
import sys,os
from timeit import default_timer as timer

start_time = timer()
dbpath = "/project_data/BDP1_2023/hg19/"
dbname = "hg19bwaidx"

queryname = sys.argv[-1]

out_name = queryname[:-3]

md5file = out_name+'.md5'


command = "./bwa aln -t 1 " + dbpath + dbname + " " + queryname + " > " + out_name + ".sai"
print("launching command: " , command)
os.system(command)

command = "./bwa samse -n 10 " + dbpath + dbname + " " + out_name + ".sai " + queryname + " > " + out_name + ".sam"
print("launching command: " , command)
os.system(command)

print("Creating md5sums")
os.system("md5sum " + out_name + ".sai " + " > " + md5file)
os.system("md5sum " + out_name + ".sam " + " >> " + md5file)

print("gzipping out text file")
command = "gzip " + out_name + ".sam"
print("launching command: " , command)
os.system(command)

run_time=timer()-start_time
print("The program took %f seconds to run" %run_time)

print("exiting")

exit(0)
