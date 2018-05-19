#!/usr/local/bin/python

import os,sys
clone_host=  raw_input("Enter Clone host Name:")
out = os.system("rm -f clone-host-temp2")
clone_host=clone_host.replace("\n","")
out = os.system("eman-cli host template --host=%s > clone-host-temp" %clone_host)

while "true" :
    replace_with = raw_input("\nEnter Target host Name:")
    replace_with=replace_with.replace("\n","")
    if replace_with == "":
         cmd1 = raw_input("\nTarget Host list is completed type 'yes/no':")
         if cmd1 == "yes":
             print "\n******************** Adding below Hosts to Eman ********************\n"
             out = os.system("cat clone-host-temp2 | grep 'add HOST :'")
             cmd2 = raw_input("\nIf Above hosts are correct type 'yes' to add them to eman 'yes/no':")
             if cmd2 == "yes":
                 print "Added to Eman"
                 #out = os.system("eman-cli host batch --file=clone-host-temp2 --noprobe")
                 exit(1)
             if cmd2 == "no":
                 print "\n******************** Restart again ********************"
                 out = os.system("rm clone-host-temp2")
                 continue
         else:
             continue
    if ".cisco.com" in replace_with:
        out = os.system("cat clone-host-temp | sed 's/nop/add/'| sed 's/%s/%s/' >> clone-host-temp2" %(clone_host, replace_with))
    else:
        print "\n\nEnter correct Target host name ex: sso.cisco.com"
#eman-cli host batch --file=clone-host-temp2 --noprobe
