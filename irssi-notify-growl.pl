#!/usr/bin/perl

# The IRC icon is from here: http://aurls.info/4o

use strict;
use warnings;
use IPC::Message::Minivan;
use Encode;
use Growl::GNTP;


if ($#ARGV != 0) {
    print "Usage: irssi-notify-growl.pl <port number>\n";
    exit;
}

my $port = $ARGV[0];

# Connect to the minivan and subscribe to the #irssi channel
my $van = IPC::Message::Minivan->new(host => 'localhost');
$van->subscribe("#irssi");

# Setup the Growl object
my $growl = Growl::GNTP->new(
        AppName => "Irssi",
        PeerHost => "localhost",
        PeerPort => $port,
        Password => "",
        AppIcon => "http://dl.dropbox.com/u/262048/www.nowhere.dk/files/irc.png"
);

# Register our application
$growl->register([
        { Name => "irssi", },
]);

# In case the connection is up, notify the user that we are up and running.
$growl->notify(
                Event => "irssi",
                Title => "Minivan",
                Message => "Connection established"
);

        
while (1) {
	# Ask minivan for new messages, wait 5 seconds
	# Restart the loop if we didn't get data
	if (my $cmd = $van->get(5,[])) {
		# Is the channel #irssi
		if ($cmd->[0] eq '#irssi') {
			my $c=$cmd->[1];

			# Read out the message and summary/headline for the notification
			my $message = $c->{msg};
			my $summary = $c->{summary};
                        
			# Notify Growl
                        $growl->notify(
                                        Event => "irssi",
                                        Title => $summary,
                                        Message => $message,
                        );

		}
	}
}

