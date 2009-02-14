use strict;
use warnings;
use Test::More;
plan(tests => 4);
use lib qw(../lib lib);
use Mungo;

#setup our cgi environment
$ENV{'SCRIPT_NAME'} = "test.cgi";
$ENV{'SERVER_NAME'} = "www.test.com";
$ENV{'HTTP_HOST'} = "www.test.com";
$ENV{'HTTP_REFERER'} = "http://" . $ENV{'HTTP_HOST'};

my $options = {
	'responsePlugin' => 'Mungo::Response::Raw'
};

my $m = Mungo->new($options);
#1
isa_ok($m, "Mungo");

#2
my $response = $m->getResponse();
isa_ok($response, "Mungo::Response::Raw");

#3
my $session = $m->getSession();
isa_ok($session, "Mungo::Session");

#4
my $request = $m->getRequest();
isa_ok($request, "Mungo::Request");
