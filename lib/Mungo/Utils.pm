package Mungo::Utils;
use strict;
use warnings;
use File::Basename;
use Carp;
##########################################################
sub _getScriptName{	#returns the basename of the running script
	my $scriptName = $ENV{'SCRIPT_NAME'};
	if($scriptName){
		return basename($scriptName);
	}
	else {
		confess("Cant find scriptname, are you running a CGI");
	}
	return undef;
}
#################################################
return 1;
