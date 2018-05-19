#!/usr/local/bin/python
from netaddr import IPNetwork, IPAddress
import re, sys, os, subprocess
import getpass, paramiko

if (len(sys.argv) == 3):
    pass
else:
    print "Usage: %s  Apic_name quering_subnet" % sys.argv[0]
    print "eg:  %s rtp1-fab1-apic1.cisco.com 171.70.168.154" % sys.argv[0]
    exit(1)

ip_address = IPAddress(sys.argv[2])
ip_add= "ip           :"

device = sys.argv[1]
username = getpass.getuser()
password = getpass.getpass('.web Password:')
username = username+".web"

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(device, username=username, password=password, timeout =  10)
stdin, stdout, stderr = ssh.exec_command("moquery -c l3extSubnet")

output = stdout.read()
error = stderr.read()
ssh.close()
#print output

outputf = open('moquery_output', 'w')
outputf.write(output)
outputf.close()

input=open("moquery_output", "r")
duplicate_list=[]
for line in input:
    if line in duplicate_list:
        pass
    else:
        duplicate_list.append(line)
        if ip_add in line:
            ip_subnet = IPNetwork(line.strip(ip_add))
            if ip_address in ip_subnet:
                searching_item = line.strip(ip_add)
                searching_item = searching_item.rstrip('\r\n')
                dont_consider= "0.0.0.0/0"
                if searching_item != dont_consider:
                    subprocess.call(['/bin/grep', searching_item.rstrip('\r\n'), 'moquery_output'])

os.remove("moquery_output")
