#!/usr/local/bin/perl

use Expect;
use strict;
use warnings;
use Term::ReadKey;

my $usage = "Usage: $0 <file containing list of ACEs>\n";

unless (scalar @ARGV == 1) {
        print STDERR $usage;
        exit 1;
}

my $hostfile = $ARGV[0];

my $fname ="_resource_usage";
open (HOSTFILE, "<$hostfile") or die "Unable to open $hostfile, $^E\n";
open (OUTPUTSIN, ">outputfile.csv") or die "Unable to open outputfile.csv, $^E\n";
open (ERROROUTPUT, ">ssherror.csv") or die "Unable to open ssherror.csv, $^E\n";

print "ACE Password: ";
ReadMode('noecho');
my $enable_password = ReadLine(0);
chomp $enable_password;
ReadMode('normal');

my $totalpbd;
my $totalcbd;
my $totalssl;
my $totalsslc;

my $pwd =`pwd`;
chomp $pwd;

foreach my $ace (<HOSTFILE>) {
        my @ace1 = split /\t/, $ace;
        print $ace1[0];
        chomp $ace1[1];
        my $context_name = $ace1[1];
        print "***** context $ace1[1] *****";
        my @configs;
        chomp $ace;
        $ace =~ s/.cisco.com//;
        my $fname ="_resource_usage";
        open (RSFILE, ">tmp1") or die "Unable to open tmp1, $^E\n";
        chomp $ace1[0];
        open (OUTPUT, ">ace$fname.csv") or die "Unable to open $ace$fname.csv, $^E\n";
        my $cmd = new Expect;
        my $command = "ssh -2 -l hussshai.web -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 $ace1[0]";

        chomp $context_name;
        print OUTPUTSIN " ##### $ace1[0] $context_name  ##### \n";
        print "\nSpawning \'$command\'\n";
        $cmd->spawn($command);

        $cmd->expect(15, 'assword:', 'ssh:');

        if ( $cmd->match eq 'assword:' ) {
                $cmd->send("$enable_password\n");
        } elsif ($cmd->match eq 'ssh:') {
                print "$ace1[0] - ssh error: ", $cmd->after, "\n";
                print ERROROUTPUT "$ace - ssh error: ", $cmd->after, "\n";
                next;
        } else {
                print "$ace1[0] - Unknown ssh error.\n";
                print ERROROUTPUT "$ace - Unknown ssh error.\n";
                next;
        }

        $cmd->expect(15, "$ace1[0]/Admin#", 'Permission denied');

        if ( $cmd->match) {
                if ($cmd->match eq 'Permission denied') {
                        print "$ace1[0] - Login failure\n";
                        print ERROROUTPUT "$ace - Login failure (Password Error)\n";
                        next;
                }
        } else {
                print "$ace1[0] - Unable to match command prompt.  Skipping ace1[0].\n";
                print ERROROUTPUT "$ace - Unable Login Device\n";
                next;
        }

        $cmd->send("terminal length 0\n");
        $cmd->expect(15, "$ace1[0]");

		
		$cmd->send("sh run | i associate-context\n");
        $cmd->expect(15, "$ace1[0]");

        push (@configs, $cmd->before);
        open (OUTPUTFILE, ">$ace1[0]") or die "Unable To Write File $ace1[0], $^E\n";
        print OUTPUTFILE @configs;
        @configs = ();
        sleep (2);
		my @contextfile = `cat $ace | grep -iw associate-context | awk '{print \$(2)}'`;
        print @contextfile;
        #my @lines = split (/\n/, $cmd->before);
        my @contexts;
		
		foreach (@contextfile) {
		$_ = $context_name;
        print $context_name;
        $context_name =~ tr/)\r\n(//d;
        if ($context_name eq 'Admin') {
        print "\n!\n";
        } elsif ($context_name eq 'sh') {
        print "\n!\n";
        } else {
        print "context $context_name";
        $cmd->send("changeto $context_name\n");
        $cmd->expect(15, "$ace1[0]/$context_name");
        sleep (1);
        $cmd->send("show resource usage \n");
        $cmd->expect(15, "$ace1[0]/$context_name");
        open (CONTEXTFL, ">$ace1[0]") or die "Unable To Write File $ace1[0], $^E\n";
        push (@configs, $cmd->before);
        print CONTEXTFL @configs;
        @configs = ();
        sleep (2);
		}
		}
        $cmd->send("exit\n");
        $cmd->expect(15, "#");sleep (1);
        my @contextfile = `cat $ace1[0] | egrep 'Context|ssl-connections rate|bandwidth|^-|Resource'`;
        print @contextfile;
        print RSFILE @contextfile;
        }
		
        open (RSFILE, "<tmp1") or die "Unable to open tmp1, $^E\n";

    foreach my $l (<RSFILE>) {
        #chomp $l;
        $l =~ tr/)\n(//d;
        if ($l =~ /Resource/) {
                print OUTPUT " ,Peak Bytes,Peak Bits,Peak Gbps,Current Bytes,Current Bits,Current Gbps,Denied";
                print OUTPUT "\n";
                print OUTPUTSIN " ,Peak Bytes,Peak Bits,Peak Gbps,Current Bytes,Current Bits,Current Gbps,Denied";
                print OUTPUTSIN "\n";
                }
        if ($l =~ /^Context/) {
                print OUTPUT "$l";
                print OUTPUTSIN "$l";
                print "$l";
                                }
        if ($l =~ /bandwidth/) {
                open (TMP2, ">tmp2");
                print TMP2 "$l";
                my $cbybandwidth = `cat tmp2| awk '{print \$(2)}'`;
                my $pbybandwidth = `cat tmp2| awk '{print \$(3)}'`;
                print $l;
                my $cbibandwidth = $cbybandwidth*8;
                my $cgbpsbandwidth = $cbibandwidth/1000000000;
                my $pbibandwidth = $pbybandwidth*8;
                my $pgbpsbandwidth = $pbibandwidth/1000000000;
                chomp $cbybandwidth;
                chomp $cbibandwidth;
                chomp $cgbpsbandwidth;
                chomp $pbybandwidth;
                chomp $pbibandwidth;
                chomp $pgbpsbandwidth;
                my $deny = `cat tmp2| awk '{print \$(6)}'`;
                chomp $deny;
                print OUTPUT "Bandwidth,$pbybandwidth,$pbibandwidth,$pgbpsbandwidth,$cbybandwidth,$cbibandwidth,$cgbpsbandwidth,$deny\n";
                print OUTPUTSIN "Bandwidth,$pbybandwidth,$pbibandwidth,$pgbpsbandwidth,$cbybandwidth,$cbibandwidth,$cgbpsbandwidth,$deny\n";
                }
        if ($l =~ /ssl-connections rate/) {
                open (TMP3, ">tmp3");
                print TMP3 "$l";
                my @ssl_connections = `cat tmp3 | awk '{print \$(3)"\t\t"\$(4)}'`;
                print $l;
                my $cssl = `cat tmp3| awk '{print \$(3)}'`;
                my $pssl = `cat tmp3| awk '{print \$(4)}'`;
                chomp $cssl;
                chomp $pssl;
                                my $ssl_deny = `cat tmp3| awk '{print \$(7)}'`;
                                chomp $ssl_deny;
                print OUTPUT "SSL-Connections rate,$pssl, , ,$cssl, , ,$ssl_deny\n";
                                print OUTPUTSIN "SSL-Connections rate,$pssl, , ,$cssl, , ,$ssl_deny\n";
                }
                }
    system ("rm $pwd\/$ace1[0]");
    open (CIN, "<ace$fname.csv") or die  "Unable to open $ace1[0]$fname.csv, $^E\n";
    foreach my $countinput (<CIN>) {
        $countinput =~ tr/)\n(//d;
        chomp $countinput;
        if ( $countinput =~ /Bandwidth/ ) {
        my @countinputb = $countinput;
        @countinputb = split (',', $countinputb[0]);
        my $pbd = $countinputb[3];
        $totalpbd = $pbd + $totalpbd;
        my $cbd = $countinputb[6];
        $totalcbd = $cbd + $totalcbd;
        }
        if ( $countinput =~ /SSL-Connections/ ) {
        my @sslconnections = $countinput;
        @sslconnections = split (',', $sslconnections[0]);
        my $sslc = $sslconnections[1];
        $totalssl = $sslc + $totalssl;
        my $sslcc = $sslconnections[4];
        $totalsslc = $sslcc + $totalsslc;
        }
        }
print OUTPUT "TOTAL : ,Peek SSL-connections: $totalssl,Peek BW: ,$totalpbd,Current SSL-connections: $totalsslc,Current BW: ,$totalcbd\n";
print OUTPUTSIN "TOTAL : ,Peek SSL-connections: $totalssl,Peek BW: ,$totalpbd,Current SSL-connections: $totalsslc,Current BW: ,$totalcbd\n";
system ("rm $pwd\/ace$fname.csv");

        }
                
                
#        open (CFGFILE, ">$ace.txt") or die "Unable to open $ace.txt, $^E\n";
#        print CFGFILE @configs;
#system ("rm $ace");