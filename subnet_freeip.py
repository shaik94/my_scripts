#!/usr/local/bin/python

import sys
import subprocess
import socket
import netaddr
def reconvertip(a):
        convert_list = []
        for item in a :
                convert_list.append(str(netaddr.IPAddress(item)))
        return convert_list
output = subprocess.check_output("/ecs/bin/subnet-ips-avail -s "+sys.argv[1], shell=True)
output = output.splitlines()
output = output[13:]
output = output[:-1]
ip_num_list = []
flag =0
ip_ordered = []
ip_addr = output
for item in ip_addr :
        ip_num_list.append(int(netaddr.IPAddress(item)))
for item in ip_num_list[:-1]:
        i = ip_num_list.index(item)

        if item + 1 != ip_num_list[i+1]:
                flag =1
                convert_list = reconvertip(ip_ordered)
                if len(convert_list) > 1:
                        print convert_list[0]+":"+convert_list[-1]
                        print int(netaddr.IPAddress(convert_list[-1])) - int(netaddr.IPAddress(convert_list[0])) + 1
                ip_ordered = []
        else :
                ip_ordered.append(item)
                ip_ordered.append(item+1)
ip_ordered.append(ip_num_list[-1])
convert_list =  reconvertip(ip_ordered)
if len(convert_list) > 1:
                        print convert_list[0]+":"+convert_list[-1]
                        print int(netaddr.IPAddress(convert_list[-1])) - int(netaddr.IPAddress(convert_list[0])) + 1
