#!/usr/local/bin/perl

if ((scalar @ARGV) < 1 ) {
        die "Usage: ./ipavail.pl <Network-ip-address>\n";
}

my $ip = $ARGV[0];

my @addrs = `host $ip`;
print @addrs;


my $subnet=`/ecs/bin/whichnet $ip|awk '{print \$(2)}'`;
my $amdisc=`/ecs/bin/whichnet $ip|awk '{print \$(3)\$(4)}'`;
chomp $subnet;
print ("\n***ipaddress/Host $ip- Subnet $subnet******* AM-Description - $amdisc\n");

my @ips = `/ecs/bin/subnet-ips-avail -s $subnet`;

print @ips;
