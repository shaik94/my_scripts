#!/usr/local/bin/perl

use Expect;
use strict;
use warnings;
use Term::ReadKey;
use Crypt::CBC;
use MIME::Base64;

my $login_name= `whoami`;
chomp $login_name;
print "Username: $login_name.web\n";
my $ip = $ARGV[0];
chomp $ip;
ReadMode('normal');
print ".Web Password: ";
ReadMode('noecho');
my $cec_password = ReadLine(0);
chomp $cec_password;
ReadMode('normal');

open (OUTPUTFILE, ">>outputfile.csv") or die "Unable To Write File Output, $^E\n";

my $subnet=`/ecs/bin/whichnet $ip|awk '{print \$(2)}'`;
my $amdisc=`/ecs/bin/whichnet $ip|awk '{print \$(3)\$(4)}'`;
chomp $subnet;
print ("\n***ipaddress/Host $ip- Subnet $subnet******* AM-Description - $amdisc\n");

my @ips = `/ecs/bin/subnet-ips-assigned -s $subnet | egrep -i "gw.-|ace.-|slb."`;
my @gw;
my @vlan;
foreach ($ips[0]){
@gw = split (' ', $_);
print "\n##################################***** $gw[1] *****##################################\n";
@gw = split ('-v', $gw[1]);
@vlan = split ('gw1-', $_);
@vlan = split ('.cisco.com', $vlan[1]);
@vlan = split ('-', $vlan[0]);
}
my $gw1 = "$gw[0]";
my $svi = "$vlan[0]";

print "$gw1\n";
print "$svi\n";

print "\n#######################################***** $gw1-$svi *****#######################################\n";

my @script;
my $cmd = new Expect;
my $ssh = "ssh -2 -l $login_name.web -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 $gw1";
print "\n ***** \'$ssh\' ***** \n";
$cmd->spawn($ssh);
$cmd->expect(15, 'assword:', 'ssh:');
if ( $cmd->match eq 'assword:' ) {
$cmd->send("$cec_password\n");
} else {
print OUTPUTFILE "$ip, ! ***** $gw1 SSH Error (Check Device Name) ***** \n";
print "! ***** $gw1 SSH Error (Check Device Name) ***** \n";
exit;
}
$cmd->expect(15, '#', '>', 'assword:');
if ( $cmd->match eq '#' ) {
print "! ***** NX-OS Device *****\n";
$cmd->send("ter le 0\n");
$cmd->expect(15, "#");
$cmd->send("sh run int $svi\n");
$cmd->expect(15, "#");
push (@script, $cmd->before);
$cmd->send("exit\n");
$cmd->expect(15, "#");
open (OUTPUT, ">output") or die "Unable To Write File Output, $^E\n";
print OUTPUT @script;
close OUTPUT;
my @foutput = `cat output |awk '/access-group/{print \$(3)}'`;
my @acldir = `cat output |awk '/access-group/{print \$(4)}'`;
my @vrf = `cat output |awk '/member/{print \$(3)}'`;
print "\n##############################################***** NX-OS Device *****###################################################\n";
print "$gw1 $svi @vrf\n";
if (@foutput){
chomp @foutput;
print "$foutput[0] $acldir[0]";
print OUTPUTFILE "$ip, $foutput[0] $acldir[0]";
if ($foutput[1]){
print "$foutput[1] $acldir[1]";
print OUTPUTFILE "$ip, $foutput[1] $acldir[1]";
}
}       else {
print "***** No ACL'S Found *****\n";
print OUTPUTFILE "$ip, ***** No ACL'S Found *****\n";
}
system ("rm output");
print "\n#########################################################################################################################\n";
} elsif ($cmd->match eq '>') {
                print "! ***** IOS Device $gw1 $svi *****\n";
                my $enable_password = "y3TaGA1n";
                chomp $enable_password;
                ReadMode('normal');
                $cmd->send("enable\n");
                $cmd->expect(15, 'assword:');
                $cmd->send("$enable_password\n");
                $cmd->expect(15, '#', '>');
                if ( $cmd->match eq '#' ) {
                @script = ();
                $cmd->send("ter le 0\n");
                $cmd->expect(15, "#");
                $cmd->send("sh run int $svi\n");
                $cmd->expect(15, "#");
                push (@script, $cmd->before);
                $cmd->send("exit\n");
                $cmd->expect(15, "#");
                open (OUTPUT, ">output") or die "Unable To Write File Output, $^E\n";
                print OUTPUT @script;
                close OUTPUT;
                my @foutput = `cat output |awk '/access-group/{print \$(3)}'`;
                my @acldir = `cat output |awk '/access-group/{print \$(4)}'`;
                my @vrf = `cat output |awk '/member/{print \$(3)}'`;
                print "\n############################################***** IOS Device *****#######################################################\n";
                print "$gw1 $svi @vrf\n";
                if (@foutput){
                chomp @foutput;
                print "$foutput[0] $acldir[0]";
                print OUTPUTFILE "$ip, $foutput[0] $acldir[0]";
                if ($foutput[1]){
                print "$foutput[1] $acldir[1]";
                print OUTPUTFILE "$ip, $foutput[1] $acldir[1]";
                }
                }       else {
                print "***** No ACL'S Found *****\n";
                print OUTPUTFILE "$ip, ***** No ACL'S Found *****\n";
                }
                system ("rm output");
                print "\n#########################################################################################################################\n";
} elsif ($cmd->match eq '>') {
        print "\n############################################***** IOS Device *****#######################################################\n";
        print "! ***** $ip $gw1 Can't Go Into Enable Mode (Wrong Enable Password) *****\n";
        print OUTPUTFILE "$ip, ! ***** $gw1 Can't Go Into Enable Mode (Wrong Enable Password) *****\n";
        $cmd->send("exit\n");
        $cmd->expect(15, ">");
        print "\n#########################################################################################################################\n";
}
} elsif ($cmd->match eq 'assword:') {
        print "\n#########################################################################################################################\n";
        print "! ***** $gw1 Login failure (Wrong CEC Password) *****\n";
        print OUTPUTFILE "$ip, ! ***** $gw1 Login failure (Wrong CEC Password) *****\n";
        print "\n#########################################################################################################################\n";
}
