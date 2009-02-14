#request object
package Mungo::Request;
use strict;
use warnings;
use CGI;
use Carp;
##########################################
sub new{
	my $class = shift;
	my $self = {};
	$self->{'_parameters'} = {};	
	bless $self, $class;
	$self->_setParameters();
	return $self;
}
##########################################
sub getParameters{	#get POST or GET data
	my $self = shift;
	return $self->{'_parameters'};
}
##########################################
sub validate{	#checks %form againist the hash rules
	my($self, $rules) = @_;
	my %params = %{$self->getParameters()};
	my @errors;	#fields that have a problem
	my $result = 0;
	if($rules){
		foreach my $key (keys %{$rules}){	#check each field
			if(!$params{$key} || $params{$key} !~ m/$rules->{$key}->{'rule'}/){	#found an error
				push(@errors, $rules->{$key}->{'friendly'});
			}
		}
		if($#errors == -1){	#no errors
			$result = 1;
		}
	}
	else{
		confess("No rules to validate form");
	}
	return($result, \@errors);
}
#########################################
sub _setParameters{
	my $self = shift;
	my $cgi = CGI::new();   #create a new cgi object
	foreach my $param ($cgi->param()){
      my $value = $cgi->param($param);
      $self->{'_parameters'}->{$param} = $value;  #save
   }
	return 1;
}
##########################################
return 1;