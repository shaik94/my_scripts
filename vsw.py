#!/usr/local/bin/python

import paramiko
import sys
import getpass
import os
import smtplib
import base64

dfind= sys.argv[1]
bashCommand = "eman-cli_auto host find %s >inputfile" %dfind
os.system(bashCommand)
bashCommand = "cat inputfile"
os.system(bashCommand)

f = os.popen('whoami')
user= f.read()
user = user.replace("\n","")
passw = getpass.getpass()

input=open("inputfile", "r")
file=open("outfile.csv",'w')
readfile=open("outfile.csv", "r")
for line in input:
        hostname= line
        hostname= hostname.replace("\n","")
        hostname= hostname.replace(".cisco.com","")
        print hostname
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname, port=22, username=user, password=passw)
        stdin, stdout, stderr = ssh.exec_command('show version   | egrep "kickstart:|system:"')
        output = stdout.readlines()
        #print ''.join(output)
        ssh.close()
        file.write("\n***** %s *****\n" %hostname)
        file.write(''.join(output))
file.close()
printline=readfile.read()
print (printline)
readfile.close()

filename = "outfile.csv"

# Read a file and encode it into base64 format
fo = open(filename, "rb")
filecontent = fo.read()
encodedcontent = base64.b64encode(filecontent)  # base64

sender = '%s@cisco.com' %user
reciever = '%s@cisco.com' %user

marker = "AUNIQUEMARKER"

body ="""
Check The Attachement.
"""
# Define the main headers.
part1 = """From: From Person <%s@cisco.com> 
To: To Person <%s@cisco.com>
Subject: %s VSW Version Output Attachement
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=%s
--%s
""" % (user, user, dfind, marker, marker)

# Define the message action
part2 = """Content-Type: text/plain
Content-Transfer-Encoding:8bit

%s
--%s
""" % (body,marker)

# Define the attachment section
part3 = """Content-Type: multipart/mixed; name=\"%s\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename=%s

%s
--%s--
""" %(filename, filename, encodedcontent, marker)
message = part1 + part2 + part3

try:
   smtpObj = smtplib.SMTP('localhost')
   smtpObj.sendmail(sender, reciever, message)
   print "Successfully sent email"
except Exception:
   print "Error: unable to send email"
