#myfilepath: /users/visnraje/pythontest/nsupdate/prepost.py 
import paramiko
import getpass
import csv


cr = csv.reader(open("nslist.csv","r"))
outputf = open('ns_config.txt','w')
username = raw_input('Username(.web account): ')
password = getpass.getpass('CEC Password:')

def printloop(file): 
        chk = open('loopline.txt')
        if file in chk.readlines(): return 1
        else: return 0
         
for device in cr:
        num = 0
        print device[0]
        device = device[0].strip()
        cmd = open("command.txt","r")
	ssh = paramiko.SSHClient() 
       	ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
		ssh.connect(device, username=username, password=password)
        	for line in cmd.readlines():
                	num = printloop(line)
                	stdin, stdout, stderr = ssh.exec_command(line)
                	out = stdout.read()
                	outputf.write(out)
                	if num == 1 : print "%s \n %s" %(line,out)
	except: print "error"

        finally: ssh.close()
outputf.close()
