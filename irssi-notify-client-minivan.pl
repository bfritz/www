#!/usr/bin/perl

use strict;
use warnings;
use Desktop::Notify;
use IPC::Message::Minivan;
use Encode;

my $notify_timeout = 500;
my $icon = "/usr/share/pixmaps/pidgin/protocols/scalable/irc.svg";
#my $icon = "gnome-irc.png";

# Connect to the minivan
my $van = IPC::Message::Minivan->new(host => 'localhost');
$van->subscribe("#irssi");

# Set up the notification object, then let the user know we are connected
our $notify = Desktop::Notify->new();
my $notification = $notify->create(summary => 'Minivan', body => 'Connection established', timeout => $notify_timeout, app_icon => $icon);
$notification->show();

while (1) {
	# Avoid tight loops by sleeping 5 seconds if IPC socket is disconnected
	$van->{connected} or sleep 5;

	# Ask minivan for new messages, wait 5 seconds
        # Restart the loop if we didn't get data
	if (my $cmd = $van->get(5,[])) {
		 # Is the channel #irssi
		if ($cmd->[0] eq '#irssi') {
			my $c=$cmd->[1];
			
			# Read out the message and summary/headline for the notification
			# The desktop notification requires the message to be UTF-8
			my $message = Encode::encode("utf-8",$c->{msg});
			my $summary = $c->{summary};
			
			# Show the notification
			$notification->summary($summary);
			$notification->body($message);
			$notification->show();
		}
	}
}

# We should never end up here, but if we do, close the notification object.
$notification->close();
