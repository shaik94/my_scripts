#!/usr/local/bin/python
from module import *
import sys, os, getopt, subprocess

argv= (sys.argv[1:])

hostname = ''
username= getpass.getuser()

try:
    opts, args = getopt.getopt(argv,"help:u:h:f:",["uname=","hname=","fname="])
except getopt.GetoptError:
    print './script_arg.py -u <username> -h <hostname>'
    print '                or  ' 
    print './script_arg.py -u <username> -f <filename>'
    sys.exit(2)
for opt, arg in opts:
    if opt == '-help':
        print 'script_arg.py -u <username> -h <hostname>'
        sys.exit()
    elif opt in ("-u", "--uname"):
        username = arg
        user  = username
    elif opt in ("-h", "--hname"):
        hostname = arg
        hostfilelist = [hostname]
    elif opt in ("-f", "--fname"):
        hfile = arg
        hnfile = open(hfile, "r")
        hostfilelist = hnfile.readlines()
fOut = open("outfile.csv", 'a')
ferror = open("error.txt", 'a')

username = username.replace("\n","")

print "Enter Password for %s :" %username
creds = get_credentials(username)
print "Enter Enable Password:"
enablepass = getpass.getpass()

creds= creds
for hostname in hostfilelist:
    try:
        host = hostname
        host = host.replace("\n", "").replace("\r", "")

        print "***** %s *****" %host
        fOut.write("\n***** %s *****\n" %host)
        
        command = "show lb vserver -summary | grep -c ' '\n"
        OUT_TABLE = sshrunP(command, host,creds=creds)
        print ("Count: %s" %command)
        print OUT_TABLE
        fOut.write("%s" %command)
        fOut.write(OUT_TABLE)
             
    except:
        ferror.write("\n*****  Login Failure on %s *****\n" %host)
        pass

fOut.close()
ferror.close()
