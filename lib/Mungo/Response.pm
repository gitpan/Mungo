#factory response object
package Mungo::Response;
use strict;
use warnings;
use Carp;
#########################################################
sub new{
	my($class, $mungo, $plugin) = @_;
	if($plugin){
		eval "use $plugin;";	#should do this a better way
		if(!$@){	#plugin loaded ok
			my $self = $plugin->new($mungo);
			return $self;			
		}
		else{
			confess("Plugin load problem: $@");
		}
	}
	else{
		confess("No plugin given");
	}
	return undef;
}
#########################################################
return 1;
