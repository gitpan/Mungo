#Session functions
#mt	20070113	cookies should now expire
package Mungo::Session;
use strict;
use warnings;
use Digest::MD5;
use Data::Dumper;
use CGI::Thin::Cookies;
use base qw(Mungo::Base Mungo::Log);
our $prefix = "MG";
##############################################################################################################################
sub new{	#constructor
	my $class = shift;
	my $self = $class->SUPER::new();
	$self->{'id'} = undef;
	$self->{'error'} = "";
	$self->{'vars'} = {};
	__PACKAGE__->_expire();	#remove old sessions
	return $self;
}
#########################################################################################################################
sub validate{	#runs the defined sub to see if this sesion is validate
	my $self = shift;
	if($self->getVar('remoteIp')){
		if($self->getVar('remoteIp') eq $ENV{'REMOTE_ADDR'}){
			if($self->getVar('scriptPath') && $self->getVar('scriptPath') eq $ENV{'SCRIPT_NAME'}){
				#print STDERR "$0: Session ip " . $self->getVar('remoteIp') . " = " . $ENV{'REMOTE_ADDR'} . "\n"; 
				#print STDERR "$0: Session path " . $self->getVar('scriptPath') . " = " . $ENV{'SCRIPT_NAME'} . "\n"; 
				return 1;
			}
			else{
				$self->log("Session " . $self->getVar('scriptPath') . " <> " . $ENV{'SCRIPT_NAME'});
			}
		}
		else{
			$self->log("Session " . $self->getVar('remoteIp') . " <> " . $ENV{'REMOTE_ADDR'});
		}
	}
	else{
		$self->log("Session has no remote IP");
	}
	return 0;
}
##########################################################################################################################
sub setVar{	#stores a variable in the session
	my($self, $name, $value) = @_;
	$self->_storeVar($name, $value);
	$self->_write();
	return 1;
}
##########################################################################################################################
sub getVar{	#gets a stored variable from the session
	my($self, $name) = @_;
	if(defined($self->{'vars'}->{$name})){return $self->{'vars'}->{$name};}
	else{return undef;}
}
###########################################################################################################################
sub setError{
	my($self, $error) = @_;
	$self->{'error'} = $error;	#save the error
	return 1;
}
###########################################################################################################################
sub getError{	#returns the last error
	my $self = shift;
	return $self->{'error'};
}
###########################################################################################################################
sub setId{
	my($self, $id) = @_;
	$self->{'id'} = $id;	#save the id
	return 1;
}
###########################################################################################################################
sub getId{	#returns the session id
	my $self = shift;
	return $self->{'id'};
}
##############################################################################################################
sub create{	#creates a server-side cookie for the session
	my($self, $hash_p, $response) = @_;
	my $result = 0;
	my $sessionId = time() * $$;	#time in seconds * process id
	my $ctx = Digest::MD5->new;
	$ctx->add($sessionId);
	$sessionId = $self->_getPrefix() . $ctx->hexdigest;
	if(open(SSIDE, ">/tmp/$sessionId")){
		close(SSIDE);
		$self->setId($sessionId);	#remember the session id
		#set some initial values
		$self->setVar('remoteIp', $ENV{'REMOTE_ADDR'});
		$self->setVar('scriptPath', $ENV{'SCRIPT_NAME'});
		$result = 1;
		if($response){
			my $cookie = &Set_Cookie(NAME => 'SESSION', VALUE => $sessionId, EXPIRE => 0);
			if($cookie =~ m/^([^ ]+): (.+)$/){
				$response->header($1 => $2);
			}
			else{
				$self->setError("Invalid cookie line: $cookie");
			}
		}
		else{	#old method if it is still used
			print &Set_Cookie(NAME => 'SESSION', VALUE => $sessionId, EXPIRE => 0);
		}
	}
	else{$self->setError("Cant create session: $!");}
	return $result;
}
##############################################################################################################
sub read{	#read an existing session
	my $self = shift;
	my $result = 0;
	my $sessionId = $self->_getCookie("SESSION");	#get the session id from the browser
	if(defined($sessionId)){	#got a sessionid of some sort
		my $prefix = $self->_getPrefix();
		if($sessionId =~ m/^$prefix[a-f0-9]+$/){	#filename valid
			if(open(SSIDE, "</tmp/$sessionId")){	#try to open the session file
				my $contents = "";
				while(<SSIDE>){	#read each line of the file
					$contents .= $_;
				}
				close(SSIDE);
				my $VAR1;	#the session contents var
				{
					eval $contents;
				}
				$self->{'vars'} = $VAR1;
				$result = 1;
				$self->setId($sessionId);	#remember the session id
			}
			else{$self->setError("Cant open session file: $!");}
		}
		else{$self->setError("Session ID invalid: $sessionId");}
	}
	return $result;
}
###########################################################################################
sub delete{	#remove a session
	my($self, $response) = @_;
	my $result = 0;
	my $sessionId = $self->getId();
	my $prefix = $self->_getPrefix();
	if($sessionId =~ m/^$prefix[a-f0-9]+$/){	#id valid
		if(unlink('/tmp/' . $sessionId)){
			if($response){
				my $cookie = &Set_Cookie(NAME => 'SESSION', EXPIRE => 'delete');
				if($cookie =~ m/^([^ ]+): (.+)$/){
					$response->header($1 => $2);
				}
				else{
					$self->setError("Invalid cookie line: $cookie");
				}
			}
			else{
				print &Set_Cookie(NAME => 'SESSION', EXPIRE => 'delete');
			}
			#print "Set-Cookie: SESSION=; expires Mon, 09-Dec-2002 13:46:00 GMT\n";
			$self = undef;	#destroy this object
			$result = 1;
		}
		else{
			$self->setError("Could not delete session");
		}
	}
	else{$self->setError("Session ID invalid: $sessionId");}
	return $result;
}
###############################################################################################################
#private class method
###############################################################################################################
sub _expire{	#remove old session files
	my $self = shift;
	if(opendir(COOKIES, "/tmp")){
		my @sessions = readdir(COOKIES);
		foreach(@sessions){	#check each of the cookies
			my $prefix = $self->_getPrefix();
			if($_ =~ m/^($prefix[a-f0-9]+)$/){	#found a cookie file
				my @stat = stat("/tmp/$1");
				if($stat[9] < (time - 86400)){unlink "/tmp/$1";}	#cookie is more than a day old, so remove it
			}
		}
		closedir(COOKIES);
	}
}
############################################################################################################
#private methods
###########################################################################################
sub _write{	#writes a server-side cookie for the session
	my $self = shift;
	my $prefix = $self->_getPrefix();
	if($self->getId() =~ m/^($prefix[a-f0-9]+)$/){	#filename valid
		if(open(SSIDE, ">/tmp/$1")){
			$Data::Dumper::Freezer = 'freeze';
			$Data::Dumper::Toaster = 'toast';
			$Data::Dumper::Indent = 0;	#turn off formatting
			my $dump = Dumper $self->{'vars'};
			print SSIDE $dump;
			close(SSIDE);
		}
		else{$self->setError("Cant write session: $!");}
	}
	else{$self->setError('Session ID invalid');}
	if($self->getError()){return 0;}
	else{return 1;}
}
############################################################################################################
sub _getCookie{	#returns the value of a cookie
	my $self = shift;
	my $name = shift;
	my $value = undef;
	if(exists($ENV{'HTTP_COOKIE'})){	#we have some kind of cookie
		my @pairs = split(/; /, $ENV{'HTTP_COOKIE'});	#this cookie might contain multiple name value pairs
		foreach(@pairs){
			my($n, $v) = split(/=/, $_, 2);
			if($n eq $name){$value = $v;}
		}
	}
	return $value;
}
##########################################################################################################################
sub _storeVar{	#stores a variable in the session
	my($self, $name, $value) = @_;
	if(!$value){	#remove the var
		if($self->{'vars'}){	
			my %vars = %{$self->{'vars'}};
			delete $vars{$name};
			$self->{'vars'} = \%vars;
		}
	}
	else{	#update/create a var
		$self->{'vars'}->{$name} = $value;	#store for later
	}
	return 1;
}
#####################################################################################################################
sub _getPrefix{	#this should be a config option
	return $prefix;
}
#####################################################################################################################
return 1;
END {}
