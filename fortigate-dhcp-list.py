#!/usr/bin/python

from sys import argv
import paramiko
import csv
import re

site = argv[1]
ip = argv[2]

#Get user/pass from .creds file
with open("/project_path/dhcp/.creds") as file:
	data = file.readlines()

for i in data:
    if i.find("router") == 0:
	data = i

user = data.split(',')[0].split('=')[1]
pwd = data.split(',')[1].replace('\n','')
###


##Connect to router and run command to see dhcp lease list
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(ip,username=user,password=pwd)
stdin, stdout, stderr=ssh.exec_command("execute dhcp lease-list")
dhcplist = stdout.readlines()
ssh.close()

#Clean up data and write to screen 
for line in dhcplist:
    data = line.replace('\t',',')[2:].replace('\n','').replace(",,",',')
    data2=re.sub("\s\s\s+",',',data)
    if unicode(data)[:2].isnumeric():
	result = site + "," + data2
        print(result)
