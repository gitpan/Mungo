#response object
package Mungo::Response::SimpleTemplate;
use strict;
use warnings;
use base ("Mungo::Response::Base");
our $templateLoc = "/var/httpd/lowercall/cgi-shl/data";	#where the templates are stored
#########################################################
sub new{
	my($class, $mungo) = @_;
	my $self = $class->SUPER::new($mungo);
	$self->{'_template'} = undef;	
	$self->{'_templateVars'} = {};
	bless $self, $class;
	return $self;
}
#########################################################
sub setTemplate{
	my($self, $template) = @_;
	$self->{'_template'} = $template;
	return 1;
}
#########################################################
sub getTemplate{
	my $self = shift;
	return $self->{'_template'};
}
#########################################################
sub display{	#this sub will display the page headers if needed
	my $self = shift;
	my $output;
	if(!$self->getTemplate()){	#if no template has been set in the action sub then we set a default
		my $tName = $self->_getTemplateNameForAction();
		$self->setTemplate($tName);	#set the template automatically
	}
	if(!$self->getError() && !$self->header("Location") && !$self->getTemplate()){	#we must have a template set if we dont have an error or a redirect
		$self->setError("No template defined");
	}
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
sub setTemplateVar{
	my($self, $name, $value) = @_;
	$self->{'_templateVars'}->{$name} = $value;
	return 1;
}
#########################################################
sub getTemplateVar{
	my($self, $name) = @_;
	return $self->{'_templateVars'}->{$name};
}
#########################################################
# private methods
########################################################
sub _getContent{
	my $self = shift;
	my $content;
	if(!$self->getError()){
		$content = $self->_parseFile($self->getTemplate());
	}
	else{
		$self->setTemplateVar('message', $self->getError());
		$content = $self->_parseFile("genericerror");
	}
	return $content;
}
##################################################################################
sub _readFile{
	my($self, $file) = @_;
	my $content;
	if(open(CONT, "<$file")){
		while(my $line = <CONT>){
			$content .= $line
		}
		close(CONT);;
	}
	else{
		$self->setError("Cant open file: $file: $!");
	}
	return $content;
}
##################################################################################
sub _parseFile{	#this returns the contents of a page
	my($self, $page) = @_;
	my $contents = $self->_readFile($templateLoc . '/' . $page . ".html");
	if($contents){
		$contents =~ s/\[% INCLUDE ([a-z\-\/]+); %\]/$self->_parseFile('includes\/' . $1)/eg;	#include any component files first
		$contents =~ s/<!--self-->/$ENV{'SCRIPT_NAME'}/g;
		$contents =~ s/<!--(\w+)-->/$self->_getHash($1)/eg;
		return $contents;
	}
	return undef;
}
###########################################################
sub _getTemplateNameForAction{
	my $self = shift;
	my $mungo = $self->getMungo();
	my $action = $mungo->getAction();
	my $script = $mungo->_getScriptName();
	$script =~ s/\.[^\.]+$//;	#remove the file extension
	$action =~ s/ /_/g;	#remoave spaces in action if any
	my $name = $script . "-" . $action;
	return $name;
}
#########################################################
return 1;