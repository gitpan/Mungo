#response base object for plugins
package Mungo::Response::Base;

=pod

=head1 NAME

Response Base - Base object for view plugins

=head1 SYNOPSIS

use myResponse;
my $response = myResponse->new($mungo);

package myResponse;
use base ("Mungo::Response::Base");

=head1 DESCRIPTION

This object should not be used directly, a new class should be created which inherits this one istead.

All response plugins should override at least the display() method.

The module Mungo::Response will load the specified respomse plugin on script startup.

=head1 METHODS

=over 4

=cut

use strict;
use warnings;
use Carp;
use base ("HTTP::Response");
#########################################################
sub new{
	my($class, $mungo) = @_;
	my $self = $class->SUPER::new(200, "OK");	#we dont care about the code or msg as they get removed later
	$self->{'_mungo'} = $mungo;	#so we can access the mungo object FIXME
	$self->{'_error'} = undef;
	$self->{'_displayedHeader'} = 0;	#flag set on first output
	bless $self, $class;
	return $self;
}
#########################################################
sub setError{
	my($self, $error) = @_;
	$self->{'_error'} = $error;
	return 1;
}
#########################################################
sub getError{
	my $self = shift;
	return $self->{'_error'};
}
#########################################################
sub getMungo{
	my $self = shift;
	return $self->{'_mungo'};
}
#########################################################
sub display{
	confess("display() not overridden");
}
#########################################################
# private methods
#########################################################
sub _setDisplayedHeader{
	my $self = shift;
	$self->{'_displayedHeader'} = 1;
	return 1;
}
#########################################################
sub _getDisplayedHeader{
	my $self = shift;
	return $self->{'_displayedHeader'};
}
###########################################################

=pod

=back

=cut

#########################################################
return 1;