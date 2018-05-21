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

print "ACE Password: ";
ReadMode('noecho');
my $enable_password = ReadLine(0);
chomp $enable_password;
ReadMode('normal');

foreach my $ace (<HOSTFILE>) {

        my @configs;
        chomp $ace;
        $ace =~ s/.cisco.com//;

        my $cmd = new Expect;
        my $command = "ssh -2 -l hussshai.web -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 $ace";

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
        #my @lines = split (/\n/, $cmd->before);
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
                $cmd->send("show  resource usage\n");
                $cmd->expect(15, "$ace/$_");

                sleep (1);
                push (@configs, "\n***** $_ *****\n");
                push (@configs, $cmd->before);
        }
        }
                $cmd->send("exit\n");
                $cmd->expect(15, "#");
        open (CFGFILE, ">$ace.txt") or die "Unable to open $ace.txt, $^E\n";
        print CFGFILE @configs;
system ("rm $ace");
}