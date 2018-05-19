#!/usr/local/bin/perl

use Expect;
use strict;
use warnings;
use MIME::Lite;

my $usage = "Usage: $0 <file containing list of Subnets>\n";

unless (scalar @ARGV == 1) {
        print STDERR $usage;
        exit 1;
}

my $inputfile = $ARGV[0];

open (INTFILE, "<$inputfile") or die "Unable to open $inputfile, $^E\n";

open (OUTFILE, ">outputfile.txt") or die "Unable to open outputfile.txt, $^E\n";

foreach my $subnet (<INTFILE>) {

chomp  $subnet;
my $amdisc=`/ecs/bin/whichnet $subnet|awk '{print \$(3)\$(4)}'`;
my $subnetip=`/ecs/bin/whichnet $subnet|awk '{print \$(2)}'`;
my @out= `/ecs/bin/subnet-ips-assigned -s $subnetip | awk '{print \$(2)}' | egrep -v 'assigned' | sed -e 's/.cisco.com.*//g'`;

print @out;
chomp $amdisc;
print OUTFILE "##### $subnet ##### AM-Description - $amdisc\n";
print OUTFILE @out;
}

my @sender= `whoami`;
my $msg = MIME::Lite->new(
    From    => "@sender",
    To      => "@sender",
    Cc      => "@sender",
    Subject => "Hosts in Given Subnets",
    Type    => 'multipart/mixed',
);

$msg->attach(
    Type     => 'TEXT',
    Data      => "Hosts In Given Subnets ",
);

$msg->attach(
    Path     => "./outputfile.txt",
);
$msg->send;
