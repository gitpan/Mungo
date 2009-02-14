#!/usr/bin/perl
use strict;
use warnings;
use lib qw(lib ../lib ../../lib);
use Mungo;
my $options = {
	'response' => 'Mungo::Response::Raw'
};
my $m = Mungo->new($options);
my $actions = {
	"default" => \&hello
};
$m->setActions($actions);
$m->run();	#do this thing!
###########################################
sub hello{
	my $m = shift;
	my $response = $m->getResponse();
	$response->setContent("Hello World");
	return 1;
}