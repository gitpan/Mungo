package Mungo::Base;
use strict;
use warnings;
###########################################################
sub new{
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}
##########################################################
return 1;
