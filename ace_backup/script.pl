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

print "Username: ";
ReadMode('normal');
my $username = ReadLine(0);
chomp $username;
print "Password: ";
ReadMode('noecho');
my $enable_password = ReadLine(0);
chomp $enable_password;
ReadMode('normal');

my $run = "_RUN";

foreach my $ace (<HOSTFILE>) {
        my @ace1 = split /\t/, $ace;
        print $ace1[0];
        chomp $ace1[1];
        open (OUTPUTFILE, ">$ace1[0]_$ace1[1]") or die "Unable To Write File $ace, $^E\n";
        open (OUTPUTFILERUN, ">$ace1[0]_$ace1[1]_$run") or die "Unable To Write File $ace$run, $^E\n";
        my $context_name = $ace1[1];
        print "***** context $ace1[1] *****";
        my @configs;
        chomp $ace;
        $ace =~ s/.cisco.com//;

        chomp $ace1[0];
        my $cmd = new Expect;
        my $command = "ssh -2 -l $username -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 $ace1[0]";

        print "\nSpawning \'$command\'\n";
        $cmd->spawn($command);

        $cmd->expect(15, 'assword:', 'ssh:');

        if ( $cmd->match eq 'assword:' ) {
                $cmd->send("$enable_password\n");
        } elsif ($cmd->match eq 'ssh:') {
                print "$ace1[0] - ssh error: ", $cmd->after, "\n";
                                print ERROR "$ace - ssh error: ", $cmd->after, "\n";
                next;
        } else {
                print "$ace1[0] - Unknown ssh error.\n";
                                print ERROR "$ace - Unknown ssh error.\n";
                next;
        }

        $cmd->expect(15, "$ace1[0]/Admin#", 'Permission denied');

        if ( $cmd->match) {
                if ($cmd->match eq 'Permission denied') {
                        print "$ace1[0] - Login failure\n";
                        print ERROR "$ace - Login failure\n";
                        next;
                }
        } else {
                print "$ace1[0] - Unable to match command prompt.  Skipping ace1[0].\n";
                                print ERROR "$ace - Unable to match command prompt.  Skipping ace.\n";
                next;
        }

        $cmd->send("terminal length 0\n");
        $cmd->expect(15, "$ace1[0]");

        print $context_name;
        $context_name =~ tr/)\r\n(//d;
        if ($context_name eq 'Admin') {
        print "\n!\n";
        } elsif ($context_name eq 'sh') {
        print "\n!\n";
        } else {
        
        $cmd->send("changeto $context_name\n");
        $cmd->expect(15, "$ace1[0]/$context_name");

        $cmd->send("terminal length 0\n");
        $cmd->expect(15, "$ace1[0]/$context_name");

        $cmd->send("show run\n");
        $cmd->expect(15, "$ace1[0]/$context_name/");
        push (@configs, $cmd->before);
        print OUTPUTFILERUN @configs;
        sleep (1);
        @configs = ();

        my @cmdfile = `cat cmd_file`;

        foreach (@cmdfile) {
        $_ =~ tr/)\r\n(//d;

        $cmd->send("$_\n");
        $cmd->expect(15, "$ace1[0]/$context_name");
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
