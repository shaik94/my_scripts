#!/usr/local/bin/perl

use Expect;
use strict;
use warnings;
use Term::ReadKey;
use MIME::Lite;

my $usage = "Usage: $0 <file containing list of ACEs>\n";

unless (scalar @ARGV == 1) {
        print STDERR $usage;
        exit 1;
}
my $login_name= `whoami`;
my $hostfile = $ARGV[0];
chomp $login_name;
my $pwd =`pwd`;
chomp $pwd;

open (HOSTFILE, "<$hostfile") or die "Unable to open $hostfile, $^E\n";

print "ACE Password: ";
ReadMode('noecho');
my $enable_password = ReadLine(0);
chomp $enable_password;
ReadMode('normal');

my $fname = "_vip_status";
my $acetype ="L3OA";

foreach my $ace (<HOSTFILE>) {

        my @configs;
        my @configsl3oa;
        my @confiigs;
        chomp $ace;
        $ace =~ s/.cisco.com//;

        my $cmd = new Expect;
        my $command = "ssh -2 -l $login_name.web -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 $ace";

        print "\nSpawning \'$command\'\n";
        $cmd->spawn($command);

        $cmd->expect(15, 'assword:', 'ssh:');

        if ( $cmd->match eq 'assword:' ) {
                $cmd->send("$enable_password\n");
        } elsif ($cmd->match eq 'ssh:') {
                print "$ace - ssh error: ", $cmd->after, "\n";
                next;
        } else {
                print "$ace - Unknown ssh error.\n";
                next;
        }

        $cmd->expect(15, "$ace/Admin#", 'Permission denied');

        if ( $cmd->match) {
                if ($cmd->match eq 'Permission denied') {
                        print "$ace - Login failure\n";
                        next;
                }
        } else {
                print "$ace - Unable to match command prompt.  Skipping ace.\n";
                next;
        }

        $cmd->send("terminal length 0\n");
        $cmd->expect(15, "$ace");

        $cmd->send("sh run | i associate-context\n");
        $cmd->expect(15, "$ace");

        push (@configs, $cmd->before);
        open (OUTPUTFILE, ">$ace") or die "Unable To Write File $ace, $^E\n";
        print OUTPUTFILE @configs;
        @configs = ();
        sleep (2);

        my @contextfile = `cat $ace | grep -iw associate-context | awk '{print \$(2)}'`;
        print @contextfile;
        my @contexts;
        
        foreach (@contextfile) {
                $_ =~ tr/)\r\n(//d;
                if ($_ eq 'Admin') {
                print "\n!\n";
                } elsif ($_ eq 'sh') {
                print "\n!\n";
                } else {
                $cmd->send("changeto $_\n");
                $cmd->expect(15, "$ace/$_");
                sleep (1);
                push (@confiigs, $cmd->before);
                $cmd->send("show arp | i RSERVER\n");
                $cmd->expect(15, "$ace/$_");
                sleep (1);
                push (@configs, "\n***** $_ *****\n");
                push (@configs, $cmd->before);
                $cmd->send("show service-policy summary  | i SRVC\n");
                $cmd->expect(15, "$ace/$_");
                sleep (1);
                push (@configsl3oa, "\n***** $_ *****\n");
                push (@configsl3oa, $cmd->before);
        }
        }
        $cmd->send("exit\n");
        $cmd->expect(15, "#");
        open (CFGFILE, ">$ace.l2br") or die "Unable to open $ace$acetype.txt, $^E\n";
        print CFGFILE @configs;
        open (CFGFILEL3OA, ">$ace.l3oa") or die "Unable to open $ace$acetype.txt, $^E\n";
        print CFGFILEL3OA @configsl3oa;

open (CFGFILE, "<$ace.l2br") ;
open (CFGFILEL3OA, "<$ace.l3oa") ;
open (VTMP, ">$ace$fname.csv");
print VTMP "Context Name,IP Address,DNS Lookup,Type, , ,Vlan,Change Alias,Duty Pager,Priority\n";

foreach my $line (<CFGFILE>){
        my $contextname;
        my $ncontextname;
        $line =~ tr/)\n(//d;
        chomp $line;
        $ncontextname = `cat vtmp1 | awk '{print \$(2)}'`;
        if ($line =~ /L2BR/ || $line =~ /L3OA/) {
        open (VTMP1, ">vtmp1");
        print VTMP1 "$line";
        $contextname = "$ncontextname";
        chomp $contextname;
        }
        if ($line =~ m/SERVER/ && $line !~ m/bvi/) {
        $line =~ tr/)\n(//d;
        chomp $ncontextname;
        print "$ncontextname\n";
        open (VTMP2, ">vtmp2");
        print VTMP2 "$line";
        my $vip= `cat vtmp2 | awk '{print \$(1)}'`;
        chomp $vip;
        if ($vip =~ m/^.\d/ && $vip !~ /^\s*$/){
        my @lookup =`host $vip`;
        my @nlookup = split (' ', $lookup[0]);
        print "$vip \t $nlookup[4]\n";
        print VTMP2 "$vip \t $nlookup[4]\n";
        $nlookup[4]=~ s/.cisco.com./.cisco.com/;
        my @out=`eman-cli host show $nlookup[4]`;
        chomp $line;
        chomp $ncontextname;
        my @nl = split /\s+/,$line;
        print VTMP "$ncontextname,$nl[0],$nlookup[4],RSERVER, , ,$nl[2],";
        if (@out > 5){
        open (VTMP4, ">vtmp4");
        print VTMP4 @out;
        my @chgalias=`cat vtmp4 | egrep -i 'Contact' | awk '{print \$(4)}'`;
        my @duty=`cat vtmp4 | egrep -i 'Duty Pager' | awk '{print \$(4)}'`;
        my @priority=`cat vtmp4 | egrep -i 'Host Monitor :|Priority'`;
        chomp @chgalias;
        chomp @duty;
        chomp @priority;
        print VTMP "$chgalias[0]  \t  $chgalias[1]  \t  $chgalias[2]  \t  $chgalias[3]  \t  $chgalias[4]  \t  $chgalias[5]  \t  $chgalias[6]  \t  $chgalias[7]  \t  $chgalias[8]  \t  $chgalias[9]  \t  $chgalias[10],$duty[0]  \t  $duty[1]  \t  $duty[2]  \t  $duty[3]  \t  $duty[4]  \t  $duty[5]  \t  $duty[6]  \t  $duty[7]  \t  $duty[8]  \t  $duty[9]  \t  $duty[10],$priority[0]  \t  $priority[1]  \t  $priority[2]  \t  $priority[3]  \t  $priority[4]  \t  $priority[5]  \t  $priority[6]  \t  $priority[7]  \t  $priority[8]  \t  $priority[9]  \t  $priority[10]\n";
        @out = ();
        } else {
        print VTMP " NOT FOUND IN EMAN\n";
        }
        }
    }
}
print VTMP "\n\nContext Name,VIP,DNS Lookup,Type,Portocol-Port No,Vlan No,VIP Status,Change Alias,Duty Pager,Priority\n";
foreach my $line (<CFGFILEL3OA>){
        my $contextname;
        $line =~ tr/)\n(//d;
        chomp $line;
        my $ncontextname = `cat vtmp1 | awk '{print \$(2)}'`;
        if ($line =~ /L2BR/ || $line =~ /L3OA/) {
        open (VTMP1, ">vtmp1");
        print VTMP1 "$line";
        my $contextname = "$ncontextname";
        chomp $contextname;
        }
        if ($line =~ m/OUT-SRVC/ || $line =~ m/IN-SRVC/ && $line !~ /^\s*$/ && $line !~ /^# sh /) {
        chomp $ncontextname;
        print "$ncontextname\n";
        open (VTMP2, ">vtmp2");
        print VTMP2 "$line";
        my $vip= `cat vtmp2 | awk '{print \$(2)}'`;
        chomp $vip;
        if ($vip =~ m/^.\d/ && $vip !~ /^\s*$/){
        my @lookup =`host $vip`;
        my @nlookup = split (' ', $lookup[0]);
        print "$vip \t $nlookup[4]\n";
        print VTMP2 "$vip \t $nlookup[4]\n";
        $nlookup[4]=~ s/.cisco.com./.cisco.com/;
        my @out=`eman-cli host show $nlookup[4]`;
        chomp $line;
        chomp $ncontextname;
        my @nl = split /\s+/,$line;
        print VTMP "$ncontextname,$nl[1],$nlookup[4],VIP,$nl[2] $nl[4],$nl[5],$nl[6],";
        if (@out > 5){
        open (VTMP4, ">vtmp4");
        print VTMP4 @out;
        my @chgalias=`cat vtmp4 | egrep -i 'Contact' | awk '{print \$(4)}'`;
        my @duty=`cat vtmp4 | egrep -i 'Duty Pager' | awk '{print \$(4)}'`;
        my @priority=`cat vtmp4 | egrep -i 'Host Monitor :|Priority'`;
        chomp @chgalias;
        chomp @duty;
        chomp @priority;
        print VTMP "$chgalias[0]  \t  $chgalias[1]  \t  $chgalias[2]  \t  $chgalias[3]  \t  $chgalias[4]  \t  $chgalias[5]  \t  $chgalias[6]  \t  $chgalias[7]  \t  $chgalias[8]  \t  $chgalias[9]  \t  $chgalias[10],$duty[0]  \t  $duty[1]  \t  $duty[2]  \t  $duty[3]  \t  $duty[4]  \t  $duty[5]  \t  $duty[6]  \t  $duty[7]  \t  $duty[8]  \t  $duty[9]  \t  $duty[10],$priority[0]  \t  $priority[1]  \t  $priority[2]  \t  $priority[3]  \t  $priority[4]  \t  $priority[5]  \t  $priority[6]  \t  $priority[7]  \t  $priority[8]  \t  $priority[9]  \t  $priority[10]\n";
        @out = ();
        } else {
        print VTMP " NOT FOUND IN EMAN\n";
        }
        }
    }
}
                my @sender= `whoami`;
                my $msg = MIME::Lite->new(
                    From    => "@sender",
                    To      => "@sender",
                    Cc      => "@sender",
                    Subject => "$ace Eman Contact Details",
                    Type    => 'multipart/mixed',
                );

                $msg->attach(
                    Type     => 'TEXT',
                    Data     => "Here's the Eman Contact Details for $ace",
                );

                $msg->attach(
                    Path     => "./$ace$fname.csv",
                );
                $msg->send;
system ("rm $pwd\/$ace");
system ("rm $pwd\/$ace$fname.csv");
system ("rm $pwd\/$ace.l2br");
system ("rm $pwd\/$ace.l3oa");
}
system ("rm $pwd\/vtmp4");
system ("rm $pwd\/vtmp2");
system ("rm $pwd\/vtmp1");
