#!/usr/bin/perl -w

use XML::Simple;
use Data::Dumper;
use LWP::Simple;
use strict;
use utf8;

binmode(STDOUT,':utf8');


my $xml = get('http://api.antizapret.info/all.php?type=xml') || die 'Unable to get page';

my $ref = XMLin($xml,
        keyattr    => ['content'],
        ForceArray => [ 'content']
);

foreach my $element (@{$ref->{content}}){
	my $raw_url = $element->{url};

	my @urls = split(', ', $raw_url);

	foreach my $url (@urls) {
		$url =~ s/\s+$//g;
		$url =~ s/^http:\/\/|^https:\/\///g;
		$url =~ s/\&amp\;/\&/g;
		print($url."\n");
	}
	
}
