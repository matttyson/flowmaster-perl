package Flowmaster;

use strict;
use warnings;

our $VERSION = '0.1';
require XSLoader;
XSLoader::load('Flowmaster', $VERSION);

sub new {
	my ($class) = @_;

	my $fm = fm_create();

	return bless { fm => $fm }, $class;
}

sub connect {
	my ($self, $port) = @_;

	return fm_connect($self->{fm}, $port);
}

sub disconnect {
	my ($self) = @_;

	fm_disconnect($self->{fm});
}

sub ping {
	my ($self) = @_;

	return fm_ping($self->{fm});
}

sub is_connected {
	my ($self) = @_;

	return fm_isconnected($self->{fm});
}

sub set_fan_speed {
	my ($self, $speed) = @_;

	return fm_set_fan_speed($self->{fm}, $speed);
}

sub set_pump_speed {
	my ($self, $speed) = @_;

	return fm_set_pump_speed($self->{fm}, $speed);
}

sub update_status {
	my ($self) = @_;

	fm_update_status($self->{fm});
}

sub fan_duty_cycle {
	my ($self) = @_;

	return fm_fan_duty_cycle($self->{fm});
}

sub pump_duty_cycle {
	my ($self) = @_;

	return fm_pump_duty_cycle($self->{fm});
}

sub ambient_temp {
	my ($self) = @_;

	return fm_ambient_temp($self->{fm});
}

sub coolant_temp {
	my ($self) = @_;

	return fm_coolant_temp($self->{fm});
}

sub fan_rpm {
	my ($self) = @_;

	return fm_fan_rpm($self->{fm});
}

sub pump_rpm {
	my ($self) = @_;

	return fm_pump_rpm($self->{fm});
}

sub get_fan_profile {
	my ($self) = @_;

	my @profile;

	my $rc = fm_get_fan_profile($self->{fm}, \@profile);

	return ($rc, \@profile);
}

sub set_fan_profile {
	my ($self, $profile) = @_;

	die "not an arrayref" unless ref $profile eq 'ARRAY';
	die "requres 65 elements" unless scalar(@$profile) == 65;

	return fm_set_fan_profile($self->{fm}, $profile);
}

sub update_firmware {
	my ($self, $filepath, $callback, $data) = @_;

	unless(-e $filepath) {
		die "Firmware file not found!";
	}

	if(defined($callback)){
		flash_validate_and_program($self->{fm}, $filepath, $callback, $data);
	}
	else {
		flash_validate_and_program_nocb($self->{fm}, $filepath);
	}
}

sub autoregulate {
	my ($self, $state) = @_;

	return fm_autoregulate($self->{fm}, $state);
}

sub DESTROY {
	my ($self) = @_;

	fm_destroy($self->{fm});
}

1;

__END__

=head1 NAME

Flowmaster

=cut
