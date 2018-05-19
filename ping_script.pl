#!/usr/local/bin/perl

use Expect;
use strict;
use warnings;
use Term::ReadKey;
use MIME::Lite;

if ((scalar @ARGV) < 1 ) {
        die "Usage: ./fnet.pl <Network-ip-address>\n";
}

my $ip = $ARGV[0];

my @addrs = `host $ip`;
print @addrs;

my $subnet=`/ecs/bin/whichnet $ip|awk '{print \$(2)}'`;
my $amdisc=`/ecs/bin/whichnet $ip|awk '{print \$(3)\$(4)}'`;
chomp $subnet;
print ("\n***ipaddress/Host $ip- Subnet $subnet******* AM-Description - $amdisc\n");

my @ips = `/ecs/bin/subnet-ips-assigned -s $subnet`;

open (OUTPUT, ">output.csv");
print OUTPUT "IP-ADDRESS, PING STATUS, HOSTNAME";

foreach my $ip (@ips){
print $ip;
$ip =~ tr/)\r\n(//d;

my $ipnew = (split(/ /, $ip))[0];
my $lookup = `host $ipnew`;
my $hostname = (split(/ /, $lookup))[4];

my $retval=system("ping -c 4 $ipnew");
if ($retval==0) {
    print "It Pings\n";
    print OUTPUT "$ipnew, PING SUCCESS, $hostname";
} else {
    print "Ping Failed\n";
    print OUTPUT "$ipnew, PING FAILED, $hostname";
}
}
                my @sender= `whoami`;
                my $msg = MIME::Lite->new(
                    From    => "@sender",
                    To      => "@sender",
                    Cc      => "@sender",
                    Subject => "$subnet Ping Status Report",
                    Type    => 'multipart/mixed',
                );

                $msg->attach(
                    Type     => 'TEXT',
                    Data     => "Here's the Ping Status Report for  $subnet ",
                );

                $msg->attach(
                    Path     => "./output.csv",
                );
                $msg->send;
