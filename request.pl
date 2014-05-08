#!/usr/bin/perl -w

use DateTime;
use DateTime::Format::XSD;
use SOAP::Lite;
use MIME::Base64;
use Text::Template;
use strict;
use utf8;

binmode(STDOUT,':utf8');

sub TemplateRequest(){

	# I must use templates because it is important to use correct sequense
	# in XML parameters. Why do we need to use XML? Fuck... see later...

	my $template = Text::Template->new(TYPE=>'FILE', SOURCE=>'./request.tmpl');

	my $dt = DateTime->now();
	$dt->set_time_zone( 'Europe/Moscow' );

	my $dat = $dt->strftime('%Y-%m-%dT%H:%M:%S.%3N+04:00');

	my $param = {
		"email" => "mail\@superisp.net",
		"ogrn" => "ogrn_number",
		"inn" => "inn_number",
		"operatorName" => "ООО SuperISP",
		"requestTime" => $dat,
	};

	my $text = $template->fill_in(HASH => $param);

	# Yes in an era of utf8, russians KGB programmers (or school programmers)
	# still use WIN-1251. Great!
	open XML, '>:encoding(windows-1251)', './request.xml' || die "open(request.xml): $!";
		print XML $text;
	close XML;
}

sub SignRequest(){
	my $pin = "111111";
	my $dn = "superisp"
	system('/opt/cprocsp/bin/amd64/cryptcp -signf ./request.xml -cert -pin '. $ping .' -dn '. $dn .' -nochain -norev');
}

sub SoapRequest(){
	my ($req, $sgn);
	my $service_url = 'http://vigruzki.rkn.gov.ru/services/OperatorRequest/?wsdl';

	my $soap = SOAP::Lite->service($service_url);

	open REQ,'< ./request.xml';
		$req.=$_ while <REQ>;
	close REQ;

	open SGN,'< ./request.xml.sgn';
		$sgn.=$_ while <SGN>;
	close SGN;

	# Docs said that i should use Base64, but in really no! WTF!?
	my @r = $soap->sendRequest($req, $sgn);
	
	print "Res: $r[0]\n";
	print "Descr: $r[1]\n";
	print "Code: $r[2]\n";

	if ($r[0] eq 'true'){
		return $r[2];
	}

	return 'error';
}

sub SoapGet(){
	my $code = $_[0];

	my $service_url = 'http://vigruzki.rkn.gov.ru/services/OperatorRequest/?wsdl';

	my $soap = SOAP::Lite->service($service_url);

	my @r = $soap->getResult($code);
	
	#print "GetRes: $r[0]\n";
	#print "GetDescr: $r[1]\n";


	if ($r[0] eq 'true'){
		open ZIP, '> ./register.zip' || die "open(register.zip):	$!";
			print ZIP decode_base64($r[$#r]); # ZIP is cool... in array
		close ZIP;
		return 'ok';
	}

	return 'error';
}



&TemplateRequest();

&SignRequest();

my $code = &SoapRequest();

if ($code ne 'error'){
	print "OK... Wait for $code\n";
	for (my $i:=1; $i<600; $i++){
		# In a waiting for an answer from stupid system
		my $res = &SoapGet($code);
		if($res eq 'ok'){
			print "\nOK: $i\n";
			last;
		}else{
			print STDERR ".";
		}
		sleep 1;
	}
}
