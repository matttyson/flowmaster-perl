use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
	module_name => 'Flowmaster',
	dynamic_config => 1,
	license => 'gpl',
	allow_pureperl => 0,
	requires => {
		'Module::Build' => 0.4,
	},
	extra_compiler_flags => [
		'-I/home/matt/src/flowstuff/libflowmaster',
		'-Wall',
		'-Wno-switch',
	],
	extra_linker_flags => [
		'-L/home/matt/src/flowstuff/libflowmaster',
		'-lflowmaster_static'
	],
	c_source => 'src',
	needs_compiler => 1,
	xs_files => {
		'Flowmaster.xs' => 'lib/Flowmaster.xs'
	},
	pm_files => {
		'lib/Flowmaster.pm' => 'lib/Flowmaster.pm'
	},
	dist_abstract => 'Hello',
	dist_author => 'Matt Tyson <mtyson@mtyson.id.au>',
);


$build->create_build_script;

