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
open (HOSTFILE, "<$hostfile") or die "Unable to open $hostfile, $^E\n";
open (ERROR, ">ssherror") or die "Unable to open ssherror, $^E\n";

print "ACE Password: ";
ReadMode('noecho');
my $enable_password = ReadLine(0);
chomp $enable_password;
ReadMode('normal');

my $run = "_RUN";
my $srvc = "_SRVC";
my $np = "_NP";
system ("mkdir backup");

foreach my $ace (<HOSTFILE>) {

        my @configs;
        chomp $ace;
        $ace =~ s/.cisco.com//;

        my $cmd = new Expect;
        my $command = "ssh -2 -l admin -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 $ace";

        print "\nSpawning \'$command\'\n";
        $cmd->spawn($command);

        $cmd->expect(15, 'assword:', 'ssh:');

        if ( $cmd->match eq 'assword:' ) {
                $cmd->send("$enable_password\n");
        } elsif ($cmd->match eq 'ssh:') {
                print "$ace - ssh error: ", $cmd->after, "\n";
                                print ERROR "$ace - ssh error: ", $cmd->after, "\n";
                next;
        } else {
                print "$ace - Unknown ssh error.\n";
                                print ERROR "$ace - Unknown ssh error.\n";
                next;
        }

        $cmd->expect(15, "$ace/Admin#", 'Permission denied');

        if ( $cmd->match) {
                if ($cmd->match eq 'Permission denied') {
                        print "$ace - Login failure\n";
                                                print ERROR "$ace - Login failure\n";
                        next;
                }
        } else {
                print "$ace - Unable to match command prompt.  Skipping ace.\n";
                                print ERROR "$ace - Unable to match command prompt.  Skipping ace.\n";
                next;
        }

        $cmd->send("terminal length 0\n");
        $cmd->expect(15, "$ace");

        $cmd->send("sh run | i associate-context\n");
        $cmd->expect(15, "$ace");

        push (@configs, $cmd->before);
        open (OUTPUTFILE, ">backup/$ace") or die "Unable To Write File $ace, $^E\n";
        open (OUTPUTFILERUN, ">backup/$ace$run") or die "Unable To Write File $ace$run, $^E\n";
        open (OUTPUTFILESRVC, ">backup/$ace$srvc") or die "Unable To Write File $ace$srvc, $^E\n";
        open (OUTPUTFILENP, ">backup/$ace$np") or die "Unable To Write File $ace$np, $^E\n";
        print OUTPUTFILE @configs;
        @configs = ();
        sleep (2);

        my @contextfile = `cat backup/$ace | grep -iw associate-context | awk '{print \$(2)}'`;
        print @contextfile;
        my @contexts;
        
        foreach (@contextfile) {
        $_ =~ tr/)\r\n(//d;
        if ($_ eq 'Admin') {
        
        $cmd->send("show np 1 interface icmlookup | include 127.1.2.128\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILENP @configs;
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show np 2 interface icmlookup | include 127.1.2.128\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILENP @configs;
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show np 3 interface icmlookup | include 127.1.2.128\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILENP @configs;
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show np 4 interface icmlookup | include 127.1.2.128\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILENP @configs;
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show ft group  detail\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show run\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILERUN @configs;
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        print "\n!\n";
        } elsif ($_ eq 'sh') {
        print "\n!\n";
        } else {
        
        $cmd->send("changeto $_\n");
        $cmd->expect(15, "$ace/$_");

        $cmd->send("terminal length 0\n");
        $cmd->expect(15, "$ace");

        $cmd->send("show run\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILERUN @configs;
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show probe detail\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show serverfarm detail\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show rserver detail\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show crypto files\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show service-policy summary\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILESRVC @configs;
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show service-policy detail\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show logg\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        $cmd->send("show arp\n");
        $cmd->expect(15, "$ace");
        push (@configs, $cmd->before);
        print OUTPUTFILE @configs;
        sleep (1);
        @configs = ();

        }
        }
        $cmd->send("exit\n");
        $cmd->expect(15, "#");
}
print "\n################################################################################\n";
system ("cat ssherror");
