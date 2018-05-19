#!/usr/bin/python

import sys
import paramiko
import os
import getpass

if (len(sys.argv) == 3):
    pass
else:
    print "Usage: %s  Netscaler_Name Vserver_IP_Address" % sys.argv[0]
    print "eg:  %s aer01-ucs-dcm01n-slb1 173.38.202.107" % sys.argv[0]
    exit(1)

device = sys.argv[1]
device = device.strip()
ip = sys.argv[2]
ip = ip.strip()

username = raw_input('.Web Username: ')
password = getpass.getpass('.Web Password:')

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(device, username=username, password=password, timeout =  10)
stdin, stdout, stderr = ssh.exec_command("show run")

output = stdout.read()
error = stderr.read()
ssh.close()

outputf = open('ns_config.txt', 'w')
outputf.write(output)
outputf.close()


def nsip(ip):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if ip in line and line.find("add ns ip")!= -1 and line.find("add ns ip %s " %ip)!=-1:
            print ("\n%s " %line)
            lbvser = ip
            vip(lbvser)
            cs(lbvser)

def vip(lbvser):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if lbvser in line and line.find("add lb vserver ")!=-1 and line.find("%s " %lbvser)!=-1:
            print ("\n%s " %line)
            line =line.split()
            vserver = line[3]
            vs(vserver)
            print "==============================================================================================================================="

def vs(vserver):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if vserver in line and line.find("bind lb vserver ")!=-1 and line.find("bind lb vserver %s " %vserver)!=-1 and line.find(" -policyName ")!=-1:
            print (line)
            line =line.split()
            policymap= line[5]
            pm(policymap)
#        if vserver in line and line.find("set ssl vserver ")!=-1 and line.find("%s " %vserver)!=-1:
#            print (line)
#            line =line.split()
#            vssls = line[3]
            #vssl(vssls)
        elif vserver in line and line.find("bind lb vserver ")!=-1 and line.find("bind lb vserver %s " %vserver)!=-1 and line.find(" -policyName ")==-1:
            print (line)
            line =line.split()
            servicegroup= line[4]
            sg(servicegroup)

def vssl(vssls):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        line5 = line
        if vssls in line and line.find("bind ssl vserver ")!=-1 and line.find("%s " %vssls)!=-1 and line.find(" -certkeyName ")!=-1:
            line =line.split()
            sslname= line[5]
            ssln(sslname)
        if vssls in line5 and line5.find("bind ssl vserver ")!=-1 and line5.find("%s " %vssls)!=-1:
            print (line5)

def ssln(sslname):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if sslname in line and line.find("add ssl certKey ")!=-1 and line.find("%s " %sslname)!=-1:
            print (line)

def pm(policymap):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if policymap in line and line.find("add ")!=-1 and line.find(" policy ")!=-1:
            print (line)
            line =line.split()
            policyact= line[5]
            pa(policyact)

def pa(policyact):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if policyact in line and line.find("add ")!=-1 and line.find(" action ")!=-1:
            print (line)

def sg(servicegroup):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if servicegroup in line and line.find("add serviceGroup ")!=-1 and line.find("add serviceGroup %s " %servicegroup)!=-1:
            print (line)
        if servicegroup in line and line.find("-monitorName ")!=-1 and line.find("%s " %servicegroup)!=-1:
            print (line)
            line =line.split()
            monitor= line[4]
            mon(monitor)
        elif servicegroup in line and line.find("add serviceGroup ")==-1 and line.find("-monitorName ")==-1 and line.find("bind lb vserver ")==-1 and line.find("%s " %servicegroup)!=-1:
            print (line)
            line =line.split()
            rserver= line[3]
            rs(rserver)

def rs(rserver):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if rserver in line and line.find("add server ")!=-1 and line.find("add server %s " %rserver)!=-1:
            print (line)

def mon(monitor):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if monitor in line and line.find("add lb monitor ")!=-1 and line.find("add lb monitor %s " %monitor)!=-1:
            print (line)

def cs(lbvser):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if lbvser in line and line.find("add cs vserver ")!=-1 and line.find("%s " %lbvser)!=-1:
            print ("\n%s " %line)
            line =line.split()
            csserver = line[3]
            csvser(csserver)
            print "==============================================================================================================================="

def csvser(csserver):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if csserver in line and line.find("bind cs vserver ")!=-1 and line.find("-policyName ")!=-1  and line.find("bind cs vserver %s " %csserver)!=-1:
            line =line.split()
            cspol = line[5]
            cpol(cspol)
            tlbvser = line[7]
            tlbvs(tlbvser)
        elif csserver in line and line.find("bind cs vserver ")!=-1 and line.find("%s " %csserver)!=-1:
            print (line)
            line =line.split()
            tlbvser2 = line[5]
            tlbvs(tlbvser2)

def cpol(cspol):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if cspol in line and line.find("add cs policy ")!=-1 and  line.find("add cs policy %s " %cspol)!=-1:
            print ("\n%s " %line)
        elif cspol in line and line.find("bind cs vserver ")!=-1 and line.find("%s " %cspol)!=-1:
            print (line)
            
def tlbvs(tlbvser):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if tlbvser in line and line.find("add lb vserver ")!=-1 and line.find("add lb vserver %s " %tlbvser)!=-1:
            print ("\n%s " %line)
            if tlbvser in line and line.find(" -netProfile ")!=-1 and line.find("add lb vserver %s " %tlbvser)!=-1:
                templine = line.split("-netProfile",1) [1]
                templine = templine.split()
                natnam = templine[0]
                natn(natnam)
            line =line.split()
            vserver = line[3]
            vs(vserver)

def natn(natnam):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if line.find("add netProfile %s " %natnam)!=-1:
            print (line)
            line =line.split()
            natpro = line[4]
            natp(natpro)

def natp(natpro):
    for line in open("ns_config.txt",'r'):
        line = line.strip()
        if line.find("add ns ip %s " %natpro)!=-1:
            print (line)

nsip(ip)
os.remove("ns_config.txt")
