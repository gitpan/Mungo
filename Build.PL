use strict;
use warnings;
use Module::Build;
my $build = Module::Build->new(
	module_name => 'Mungo',
	license => 'perl',
	dist_author => 'MacGyveR <macgyver@thedumbterminal.co.uk>',
	requires => {
		"CGI::Thin::Cookies" => "",
		"HTTP::Response" => "",
		"CGI" => "",
		"Carp" => "",
		"Digest::MD5" => "",
		"File::Basename" => "",
		"Data::Dumper" => ""
	},
	build_requires => {
		"Test::More" => "",
		"HTTP::Daemon" => "",
		"HTTP::Status" => "",
		"HTTP::Response" => "",
	},
	create_makefile_pl => 'traditional'
);
$build->create_build_script;
