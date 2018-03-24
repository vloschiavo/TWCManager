#!/usr/bin/perl

use strict;
use warnings;
use JSON;

# Commandline arguments
my ($powerwall_mode, $reservePercent) = @ARGV;

sub usage {
	print "\nIncorrect usage. Please specify Powerwall IP, backup mode, reserve percentage.\nExample: ./script 11.12.13.14 self_consumption 20\n"; 
}

if (not defined $powerwall_mode) { # check for string == this or == that
	usage();
	die "Need a valid mode: either backup or self_consumption\n";
}

if (not defined $reservePercent) { # check for number between 0-100
	usage();
	die "Need a valid reserve percentage between 0 - 100.\n";
}


# Variables - put in settings file!
my $powerwallIP = "11.12.13.14";
my $powerwallGatewayPassword = ""; #This should be an S+ the serial number on your gateway

# Constants:
my $statsURL = "http://$powerwallIP/api/meters/aggregates";
my $socURL = "http://$powerwallIP/api/system_status/soe";
my $gridPowerStatus = "http://192.168.1.74/api/system_status/grid_status";  

#my $data = `curl -s -m 4 $statsURL`;
#my $thing = decode_json($data); 
#my $power = $thing->{site}{instant_power};
#$power=abs($power);
#print "\nPower $power\n\n";

# set powerwall backup reserve percent 

# try running command with old token from file
# if not successful (401 Unsuccessful), then get new token
	#authenticate to powerwall
	#my $data = `curl -s -m 4 -X POST -H "Content-Type: application/json" -d '{"username":"","password":"$powerwallGatewayPassword","force_sm_off":false}' "$powerwallIP/api/login/Basic"`;
	#$thing = decode_json($data);
	#my $token = $thing->{token};
	#print "\nToken: $token\n";
	#save token to file here.
	#Getting a token disables the powerwall so we need to enable the powerwall (This is for firmware version 1.15.0)
	#`curl -s -m 4 "http://$powerwallIP/api/sitemaster/run"`;

# Testing
my $token = "";

# The setting for Reserve percent in the UI is off by 4%.  So setting it to 20 in the API results in a 16% in the UI.
# Do some checks here for 100, 0, or in between 
# $reservePercent += 4; # approx.
#
# 24 = 20
# 34 = 31
#

# Set reserve to x%
`curl -s --header "Authorization: Bearer $token" -X POST -d '{"mode":"$powerwall_mode","backup_reserve_percent":$reservePercent}' "http://$powerwallIP/api/operation"`;

# Commit setting to make it active
`curl -s --header "Authorization: Bearer $token" -X GET "http://$powerwallIP/api/config/completed"`;

