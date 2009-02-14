#response object
package Mungo::Response::Raw;

=pod

=head1 NAME

Response Raw - Raw text view plugin

=head1 SYNOPSIS

my $response = $mungo->getResponse();
$response->setContent("Hello World");

=head1 DESCRIPTION

This view plugin allows you to simply append content to the resulting web page.

Content is displayed at the end of the page request.

=head1 METHODS

=over 4

=cut

use strict;
use warnings;
use base ("Mungo::Response::Base");
#########################################################
sub new{
	my($class, $mungo) = @_;
	my $self = $class->SUPER::new($mungo);
	$self->{'_outputContent'} = "";	
	bless $self, $class;
	return $self;
}
#########################################################

=item setContent()

	$response->setContent("Hello World");

Append a scalar string to the current web page content. If an undefined value is passed any
currently defined content will be removed.

=cut

#########################################################
sub setContent{
	my($self, $content) = @_;
	if($content){
		$self->{'_outputContent'} .= $content;	
	}
	else{	#clear the current content
		$self->{'_outputContent'} = "";
	}
	return 1;
}
#########################################################
sub display{	#this sub will display the page headers if needed
	my $self = shift;
	my $output;
	if($self->_getDisplayedHeader()){	#just display more content
		$output = $self->_getContent();	#get the contents of the template
	}
	else{	#first output so display any headers
		if(!$self->header("Content-type")){	#set default content type
			$self->header("Content-type" => "text/html");
		}
		if(!$self->header("Location")){	#if we dont have a redirect
			my $content = $self->_getContent();	#get the contents of the template
			$self->content($content);
		}
		$output = $self->as_string();
		$output =~ s/^200 OK\n//i;	#remove code and message as cgi does not have control over these
	}
	print $output;
	
	$self->_setDisplayedHeader();	#we wont display the header again
	return 1;
}
#########################################################
# private methods
########################################################
sub _getContent{
	my $self = shift;
	if($self->getError()){
		return "Error: " . $self->getError();
	}
	else{
		return $self->{'_outputContent'};	
	}
}
###########################################################

=pod

=back

=cut

##################################################################################
return 1;