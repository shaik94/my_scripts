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
open (HOSTFILE, "<$hostfile") or die "Unable to open $hostfile, $^E\n";
open (ERROROUTPUT, ">ssherror.csv") or die "Unable to open ssherror.csv, $^E\n";
open (OUTPUT, ">outputfile.csv") or die "Unable to open outputfile.csv, $^E\n";

print ".web Password: ";
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
        $ace =~ tr/)\n(//d;
        my @configs;
        chomp $ace;

        my $slogin = "0";
        $ace =~ s/.cisco.com//;

        my $fname ="_resource_usage";
        my $peerace;
        open (FTDETAILS, ">ftdetails") or die "Unable To Write File ftdetails, $^E\n";
        open (PEERIP, ">peerip") or die "Unable To Write File peerip, $^E\n";
        open (SECCON, ">scon") or die "Unable To Write File scon, $^E\n";
        open (RSFILE, ">tmp1") or die "Unable to open tmp1, $^E\n";
        open (SRSFILE, ">stmp1") or die "Unable to open stmp1, $^E\n";

        my $cmd = new Expect;
        my $command = "ssh -2 -l $login_name.web -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 $ace";

        print "\nSpawning \'$command\'\n";
        $cmd->spawn($command);

        $cmd->expect(15, 'assword:', 'ssh:');

        if ( $cmd->match eq 'assword:' ) {
                $cmd->send("$enable_password\n");
        } elsif ($cmd->match eq 'ssh:') {
                print "$ace - ssh error: ", $cmd->after, "\n";
                print ERROROUTPUT "$ace - ssh error: ", $cmd->after, "\n";
                next;
        } else {
                print "$ace - Unknown ssh error.\n";
                print ERROROUTPUT "$ace - Unknown ssh error.\n";
                next;
        }

        $cmd->expect(15, "$ace/Admin#", 'Permission denied');

        if ( $cmd->match) {
                if ($cmd->match eq 'Permission denied') {
                        print "$ace - Login failure (Password Error)\n";
                        print ERROROUTPUT "$ace - Login failure (Password Error)\n";
                        next;
                }
        } else {
                print "$ace - Unable Login Device\n";
                print ERROROUTPUT "$ace - Unable Login Device\n";
                next;
        }

        $cmd->send("terminal length 0\n");
        $cmd->expect(15, "$ace");
        $cmd->send("show ft group detail\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print FTDETAILS @configs;
        @configs = ();
        my @ftdetail = `cat ftdetails | egrep '^Context Name|^My State'`;
        open (FTDETAIL2, ">ftdetails2") or die "Unable To Write File ftdetails2, $^E\n";
        print FTDETAIL2 @ftdetail;
        $cmd->send('show running interface  | i "peer ip address"');
        $cmd->send("\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print PEERIP @configs;
        @configs = ();
        my @peerip= `cat peerip | awk '{print \$(4)}'`;
        chomp @peerip;
        foreach (@peerip) {
        if ($_ =~ m/^.\d/ && $_ !~ /^\s*$/){
        my @lookup =`host $_`;
        my @nlookup = split (' ', $lookup[0]);
        $nlookup[4]=~ s/.cisco.com./.cisco.com/;
        $peerace = "$nlookup[4]";
        print "***** $peerace *****\n";
        }
        }
        $cmd->send("show resource usage \n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        open (CONTEXTFL, ">$ace") or die "Unable To Write File $ace, $^E\n";
        print CONTEXTFL @configs;
        @configs = ();
        sleep (2);

        $cmd->send("exit\n");
        $cmd->expect(15, "#");
        my @contextfile = `cat $ace | egrep 'Context|ssl-connections rate|bandwidth|^-|Resource'`;
        print @contextfile;
        print RSFILE @contextfile;

        my @conname;
        open (FTDETAIL2, "<ftdetails2") or die "Unable To Open File ftdetails2, $^E\n";
        foreach my $line (<FTDETAIL2>) {
        if ($line =~ /Context Name/ && $line !~ /Admin/) {
        @conname = "$line";
        }
        if ($line =~ /My State/ && $line =~ /HOT/ && $line !~ /ACTIVE/) {
        print SECCON @conname;
        $slogin = "1";
        }
        }
        my @scontext =`cat scon | awk '{print \$(4)}'`;
        if ($slogin =~ /1/) {
        my $cmd2 = new Expect;
        my  @sconfigs;
        my @scontextfile;

        $peerace =~ s/.cisco.com//;

        my $scommand = "ssh -2 -l admin -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 $peerace ";
        print "\nSpawning \'$scommand\'\n";
        $cmd2->spawn($scommand);

        $cmd2->expect(15, 'assword:', 'ssh:');

        if ($cmd2->match eq 'assword:' ) {
            $cmd2->send("$enable_password\n");
        } elsif ($cmd2->match eq 'ssh:') {
            print "$peerace - ssh error: ", $cmd2->after, "\n";
            print ERROROUTPUT "$peerace - ssh error: ", $cmd2->after, "\n";
            next;
        } else {
            print "$peerace - Unknown ssh error.\n";
            print ERROROUTPUT "$peerace - Unknown ssh error.\n";
            next;
        }

        $cmd2->expect(15, "$peerace/Admin#", 'Permission denied');

        if ( $cmd2->match) {
         if ($cmd2->match eq 'Permission denied') {
            print "$peerace - Login failure (Password Error)\n";
            next;
         }
        } else {
            print "$peerace - Unable Login Device\n";
            next;
        }

        $cmd2->send("terminal length 0\n");
        $cmd2->expect(15, "$peerace");

        foreach my $scon (@scontext) {
        $scon =~ tr/)\r\n(//d;
        chomp $scon;

        $cmd2->send("changeto $scon\n");
        $cmd2->expect(15, "$peerace");
        $cmd2->send("show resource usage \n");
        $cmd2->expect(15, "$peerace");
        push (@sconfigs, $cmd2->before);
        open (CONTEXTFL2, ">$peerace") or die "Unable To Write File $peerace , $^E\n";
        print CONTEXTFL2 @sconfigs;
        @sconfigs = ();
        sleep (2);
        print RSFILE "\n$scon\n";

        @scontextfile = `cat $peerace  | egrep 'Context|ssl-connections rate|bandwidth|^-|Resource'`;
        print @scontextfile;
        print SRSFILE @scontextfile;
        }
        $cmd2->send("exit\n");
        $cmd2->expect(15, "#");

        system ("rm $pwd\/$peerace");
}
open (SRSFILE, "<stmp1") or die "Unable to open stmp1, $^E\n";
open (RSFILE, "<tmp1") or die "Unable to open tmp1, $^E\n";

foreach my $l (<RSFILE>) {
        #chomp $l;
        $l =~ tr/)\n(//d;
        if ($l =~ /Resource/) {
                print OUTPUT "\n########## ACE DEVICE $ace ##########\n";
                print OUTPUT " ,Peak Bytes,Peak Bits,Peak Gbps,Current Bytes,Current Bits,Current Gbps,Denied";
                print OUTPUT "\n";
                }
        if ($l =~ /^Context/) {
                print OUTPUT "$l";
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
                }
                }
                system ("rm $pwd\/$ace");

foreach my $l (<SRSFILE>) {
        chomp $l;
        #$l =~ tr/)\n(//d;
        if ($l =~ /Resource/) {
                print OUTPUT "\n########## CONTEXTS ACTIVE ON PEER DEVICE $peerace ##########\n";
                print OUTPUT " ,Peak Bytes,Peak Bits,Peak Gbps,Current Bytes,Current Bits,Current Gbps,Denied";
                print OUTPUT "\n";
                }
        if ($l =~ /^Context/) {
                print OUTPUT "$l";
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
                }
       }
open (CIN, "<$ace$fname.csv") or die  "Unable to open $ace$fname.csv, $^E\n";
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
}
my @sender= `whoami`;
my $msg = MIME::Lite->new(
    From    => "@sender",
    To      => "@sender",
    Cc      => "@sender",
    Subject => "ACE Resource Usage Output",
    Type    => 'multipart/mixed',
);

$msg->attach(
    Type     => 'TEXT',
    Data     => "Here's the Resource Usage Output File for ACE",
);

$msg->attach(
    Path     => "./outputfile.csv",
);
$msg->send;
system ("rm $pwd\/outputfile.csv");

system ("rm $pwd\/tmp3");
system ("rm $pwd\/tmp2");
system ("rm $pwd\/tmp1");
system ("rm $pwd\/ftdetails");
system ("rm $pwd\/ftdetails2");
system ("rm $pwd\/peerip");
system ("rm $pwd\/scon");
system ("rm $pwd\/stmp1");
