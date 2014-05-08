#!/usr/bin/perl -w

use XML::Simple;
use Data::Dumper;
use LWP::Simple;
use DateTime;
use DateTime::TimeZone;
use DateTime::Format::XSD;
use strict;
use utf8;

binmode(STDOUT,':utf8');

my $pin = '111111';
my $dn = 'ProviderDN';

my $dt = DateTime->now();
$dt->set_time_zone( 'Europe/Moscow' );

my $dat = DateTime::Format::XSD->format_datetime($dt);

my %request = (
		"requestTime" => $dat,
		"operatorName" => "Operator",
		"inn" => "INN",
		"ogrn" => "ORGN",
		"email" => "EMAIL",
);

open my $fh, '>:encoding(windows-1251)', './request.xml' || die "open(request.xml): $!";

my $xs = new XML::Simple(
	NoAttr => 1,
	RootName => "request",
	XMLDecl => '<?xml version="1.0" encoding="windows-1251"?>',
	OutputFile => $fh,
);
my $xml = $xs->XMLout(\%request);

system('/opt/cprocsp/bin/amd64/cryptcp -signf ./request.xml -cert -pin '. $pin	.' -dn ' . $dn .' -nochain -norev');

#print $xml;

#print("TIME: " . $dat . "\n");
