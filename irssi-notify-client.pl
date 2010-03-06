#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Desktop::Notify;

my $last = 0;
my $loops = 0;
my $notify_timeout = 2000;
my $icon = "/usr/share/pixmaps/pidgin/protocols/scalable/irc.svg";
#my $icon = "gnome-irc.png";

sub mysql_connect {
	my $db_user = "irssi";
	my $db_pass = "Skamfjabber";
	my $db_host = "127.0.0.1:13306";
	my $db_name = "irssi";
	my $dsn = "dbi:mysql:dbname=$db_name;host=$db_host";
	my $dbh = DBI->connect($dsn, $db_user, $db_pass) or die "DB connect failed";

	return($dbh);
}

while (1) {
	my $dbh = mysql_connect();

	if ($last == 0) {
		my $sth_state = $dbh->prepare("SELECT MAX(id) FROM notify");
		$sth_state->execute() or die "Unable execute query: $dbh->err, $dbh->errstr\n";
		$last = ($sth_state->fetchrow_array)[0];
		$sth_state->finish();
	}

	my $sth = $dbh->prepare("SELECT id,time,summary,message FROM notify WHERE id > ? ORDER BY id ASC LIMIT 0,10");
	$sth->execute($last) or die "Unable execute query:$dbh->err, $dbh->errstr\n";

	if ($sth->rows > 0) {
		my $notify = Desktop::Notify->new();
		my $notification = $notify->create(timeout => $notify_timeout, app_icon => $icon);
		while (my $ref = $sth->fetchrow_hashref()) {
		
			my $id = $ref->{'id'};
			my $summary = $ref->{'summary'};
			my $message = $ref->{'message'};
			
			$notification->summary($summary);
			$notification->body($message);
			$notification->show();

			$last = $id;
			sleep 1;

		}
		$notification->close();
	}

	$sth->finish();
	
	# Clean up once in a while. This is not really essential so we simply 
	# do it once every 1000 iterations
	$loops++;
	if ($loops > 1000) {
		my $sth_cleanup = $dbh->prepare("DELETE FROM notify WHERE id < ?");
		$sth_cleanup->execute($last);
		$sth_cleanup->finish();
	}

	$dbh->disconnect;

	sleep 5;
}
