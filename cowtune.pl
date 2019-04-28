#!/usr/bin/env perl
#
# cowtune is a portmanteau of cowsay and fortune.
# This tiny server invokes cowsay with the output 
# of fortune to generate amusing sketches for the clients.
#
# By Txor.
#

use strict;
use warnings;
use utf8;
use Socket;
use IO::Socket;
use Sys::Syslog qw(:standard :macros);

# Configuration
my $default_port = 6969;
my $fortune = "/usr/games/fortune";
my $cowsay = "/usr/games/cowsay";
my $cows_dir = "/usr/share/cowsay/cows";
my $unix2dos = "/usr/bin/unix2dos";

my $port = shift;
defined($port) or $port = $default_port;

-x $fortune or die "fortune needed!\n";
my $cmd = $fortune;
$cmd = $cmd . " | " . $cowsay if -x $cowsay;
$cmd = $cmd . " -f \$(find $cows_dir -type f | shuf | head -n1)" if -d $cows_dir;
$cmd = $cmd . " | " . $unix2dos if -x $unix2dos;

my $server = new IO::Socket::INET(Proto => 'tcp',
		LocalPort => $port,
		Listen => 3,
		ReuseAddr => 1);
$server or die "Unable to create server socket: $!";

openlog("cowtune", "pid", LOG_USER);
syslog("INFO", "Initalitation done with PORT: $port and CMD: $cmd");
setlogmask( LOG_UPTO(LOG_DEBUG) );
closelog();

while (my $client = $server->accept()) {
	$client->autoflush(1);
	my $hostname = $client->peerhost();

	openlog("cowtune", "pid", LOG_USER);
	syslog("INFO", "Sending cowtune to $hostname");
	setlogmask( LOG_UPTO(LOG_DEBUG) );
	closelog();

	print $client `$cmd`;

	close $client;
}
