#!/usr/local/bin/python
import os, sys, csv
from netaddr import *


input=open(sys.argv[1], "r")
output=open("outputfile.csv", "w")
for subnet in input:
        dhcppxe = "null"
        dhcpservers = "null"
        #dhcpscope = []

        subnet = subnet.replace("\n","")
        #print subnet
        ip = IPNetwork('%s' %subnet)

        amoutput = os.popen('/ecs/bin/whichnet %s' % subnet)
        amout= amoutput.read()
        amout = amout.split(" ")
        dhcpscope = amout[2]
        #print dhcpscope
        dhcpscope = dhcpscope.replace("\n","").replace(" ", "").replace(":", "-")

        #gwloc = os.popen('host %s' %ip[2])i
        #gw = gwloc.read()
        #words = gw.split(" ")
        #print words[4]
        words = dhcpscope.split("-")
        #print words
        sitename= ''.join(c for c in words[0] if not c.isdigit())
        #print sitename
        sitename = sitename.lower()
        site = sitename
        if sitename in ('alln', 'aln'):
                        site = "aln"
        if sitename in ('blr', 'bgl', 'bglnxtra'):
                        site = "blr"
        if sitename in ('rcdn', 'rch'):
                        site = "rch"
        if sitename in ('boxborough', 'box', 'bxb'):
                        site = "bxb"
        if sitename in ('hkidc', 'hki', 'hkg', 'shn'):
                        site = "hkg"
        if sitename in ('stld', 'syd', 'tyoidc', 'tyo'):
                        site = "syd"
        if sitename in ('sngdc', 'sng', 'sin'):
                        site = "sin"
        if sitename in ('aero', 'aer', 'jrsm', 'jsr', 'gpk', 'mow', 'ntn'):
                        site = "aer"
        if sitename in ('sjck', 'sjc', 'mtv'):
                        site = "sjc"
        dhcpserverslist = ['dhcp-aer1-1-l.cisco.com', 'dhcp-aln1-1-l.cisco.com', 'dhcp-ams1-1-l.cisco.com', 'dhcp-blr1-1-l.cisco.com', 'dhcp-bxb1-1-l.cisco.com', 'dhcp-hkg1-1-l.cisco.com', 'dhcp-mtv1-1-l.cisco.com', 'dhcp-rch1-1-l.cisco.com', 'dhcp-rtp5-1-l.cisco.com', 'dhcp-sin1-1-l.cisco.com', 'dhcp-sjc1-1-l.cisco.com', 'dhcp-syd1-1-l.cisco.com', 'dhcp-tyo1-1-l.cisco.com']
        dhcpservers = filter(lambda x:site in x, dhcpserverslist)

        sitename = site
        dhcpservers =  ",".join(dhcpservers)
        if sitename in ('rtp'):
                        dhcppxe = "PXE-datacenter-rtp"
        if sitename in ('blr', 'bgl', 'hkg', 'sin', 'sng', 'syd', 'tyo'):
                        dhcppxe = "PXE-datacenter-bgl"
        if sitename in ('rcdn', 'alln', 'rch', 'aln'):
                        dhcppxe = "PXE-datacenter-rcdn"
        if sitename in ('aer', 'ams'):
                        dhcppxe = "PXE-datacenter-ams"
        if sitename in ('sjc', 'mtv', 'bxb'):
                        dhcppxe = "PXE-datacenter-sjc"

        if dhcpservers in ('null'):
                site = site.replace("\n","")
                print "%s dhcpservers not found need to do manually site : %s" % (subnet, site)
                output.write("%s dhcpservers not found, Need to do manually site : ,%s\n" % (subnet, site))

        else:
                print "eman-am -f=ra -R=\"  : \" -sn=%s  -P=%s  -DS=\"%s\"  -N=%s-scope -DR=%s   %s" %(subnet, dhcppxe, dhcpservers, dhcpscope, ip[1], site)
                output.write("eman-am -f=ra -R=\"  : \" -sn=%s  -P=%s  -DS=\"%s\"  -N=%s-scope -DR=%s,%s\n" %(subnet, dhcppxe, dhcpservers, dhcpscope, ip[1], site))
