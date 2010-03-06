#!/usr/bin/perl

# The IRC icon is from here: http://aurls.info/4o

use strict;
use warnings;
use IPC::Message::Minivan;
use Encode;
use Growl::GNTP;
use Data::Dumper;


if ($#ARGV != 0) {
    print "Usage: irssi-notify-growl.pl <port number>\n";
    exit;
}

my $port = $ARGV[0];

my $van = IPC::Message::Minivan->new(host => 'localhost');
$van->subscribe("#irssi");

my $growl = Growl::GNTP->new(
        AppName => "Irssi",
        PeerHost => "localhost",
        PeerPort => $port,
        Password => "",
        AppIcon => "http://dl.dropbox.com/u/262048/www.nowhere.dk/files/irc.png"
);

$growl->register([
        { Name => "irssi", },
]);

$growl->notify(
                Event => "irssi",
                Title => "Minivan",
                Message => "Connection established"
);

        
while (1) {
	if (my $cmd = $van->get(5,[])) {
		if ($cmd->[0] eq '#irssi') {
			my $c=$cmd->[1];

			my $message = $c->{msg};
			my $summary = $c->{summary};
                        
                        $growl->notify(
                                        Event => "irssi",
                                        Title => $summary,
                                        Message => $message,
                        );

		}
	}
}

