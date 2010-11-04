package WWW::Hermes::Detail;
use strict;
#use warnings;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/hermescheck/;
our $VERSION = '0.1';
use LWP::Simple;
use LWP::UserAgent;

sub hermescheck {
	my $paketnummer = shift;
	my $language = shift || 'de';

	my @newdata;
	my $firstdata1 = get('https://www.myhermes.de/wps/portal/PRIPS_DEU/SENDUNGSSTATUS');
	my($nextpostlink) = ($firstdata1 =~ /<form name="[^"]*_AuftragSucheForm" method="post" action="([^"]*)">/);

	my %post;
	$post{'auftragsNummer'} = $paketnummer;
	$post{'quittungsNummer'} = '';
	my $ua = LWP::UserAgent->new;
	my $response = $ua->post('https://www.myhermes.de'.$nextpostlink, \%post );
	my $data = $response->content;
	$data =~ s/[\n\r]//g;

	my($detail) = ($data =~ /<div id="formBox" class="sendungsstatus">\s*(.*?)<div class="submit" >/);
	my($detail2) = ($detail =~ /<br>\s*<div id="sisyTabelle">(.*?)<\/table>/);
	while($detail2 =~ /<tr>(.*?)<\/tr>/ig){
		my $detailone = $1;

		my($datum,$zeit,$daten) = ($detailone =~ /<td class="content">\s*([^<]*)\s*<\/td>\s*<td class="content">\s*([^<]*)\s*<\/td>\s*<td class="content">\s*([^<]*)\s*<\/td>/);
		$datum =~ s/\s\s*/ /g;
		$zeit =~ s/\s\s*/ /g;
		$daten =~ s/\s\s*/ /g;
		my %details;
		$details{'datum'} = $datum . " " . $zeit;
		$details{'daten'} = $daten;
		push(@newdata,\%details)
	}
	my($to,$paketnumber,$pickupdate,$deliverydate,$laststatus) = ($detail =~ /<td class="content">\s*([^<]*)\s*<\/td>\s*<td class="content">\s*([^<]*)\s*<\/td>\s*<td class="content">\s*([^<]*)\s*<\/td>\s*<td class="content">\s*([^<]*)\s*<\/td>\s*<td class="content">\s*([^<]*)\s*<\/td>/i);

	return(\@newdata,({
		'shipnumber' => $paketnumber,
		'to' => $to,
		'pickupdate' => $pickupdate,
		'deliverydate' => $deliverydate,
		'laststatus' => $laststatus,
		})
	);
}


=pod

=head1 NAME

WWW::Hermes::Detail - Perl module for the Hermes online tracking service with details.

=head1 SYNOPSIS

	use WWW::Hermes::Detail;
	my($newdata,$other) = hermescheck('paketnumber','de');#de for text in german

	foreach my $key (keys %$other){# shipnumber, to, pickupdate, deliverydate, laststatus
		print $key . ": " . ${$other}{$key} . "\n";
	}
	print "\nDetails:\n";

	foreach my $key (@{$newdata}){
		#foreach my $key2 (keys %{$key}){#datum, daten
		#	print ${$key}{$key2};
		#	print "\t";
		#}

		print ${$key}{datum};
		print "\t";
		print ${$key}{daten};
		print "\n";
	}

=head1 DESCRIPTION

WWW::Hermes::Detail - Perl module for the Hermes online tracking service with details.

=head1 AUTHOR

    Stefan Gipper <stefanos@cpan.org>, http://www.coder-world.de/

=head1 COPYRIGHT

	WWW::Hermes::Detail is Copyright (c) 2010 Stefan Gipper
	All rights reserved.

	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO



=cut
