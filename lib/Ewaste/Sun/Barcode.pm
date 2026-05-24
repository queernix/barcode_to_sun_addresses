package Ewaste::Sun::Barcode;

use strict;
use warnings;
use 5.005;
use Carp;

use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

$VERSION = "0.1";

require Exporter;
@ISA = qw( Exporter );

@EXPORT = qw( parse_sun_barcode );
@EXPORT_OK = qw( sun_machine_types );
%EXPORT_TAGS = ( ALL => [qw( parse_sun_barcode sun_machine_types )] );

=head1 NAME

Ewaste::Sun::Barcode - Provides subroutines for parsing Sun IDPROM Barcodes

=head1 SYNOPSIS

Convert an Old Sun NVRAM/IDPROM Barcode: 

	use Ewaste::Sun::Barcode;
	my %parsed_values = parse_sun_barcode(
		machine_type => <machine type>,
		barcode      => <barcode>
	);

The C<parse_sun_barcode> sub returns a hash with the following keys:

	mac_address   # string
	serial_number # integer
	hostid	      # string

=head1 DESCRIPTION

This is a module which provides a subroutine to parse the barcodes from the NVRAM
chips on old Sun machines.  It can optionally export a list of machine type codes
which is mostly useful for building GUIs.

=head2 Functions

This module exports a single function, C<parse_sun_barcode>, which requires two
parameters to be given:

=over

=item C<machine_type>
the numeric machine type. See L</"Machine Types"> below.

=item C<barcode>
the 4 character string printed on the barcode label which is typically affixed
to the NVRAM/TOD clock chip on the motherboard.

=back

=head2 Machine Types

    Code      |  Machine Description
 -------------+-----------------------------
     01       |  2/1x0
     02       |  2/50
     11       |  3/160
     12       |  3/50
     13       |  3/2x0
     14       |  3/110
     17       |  3/60
     18       |  3/e
     21       |  4/2x0
     22       |  4/1x0
     23       |  4/3x0
     24       |  4/4x0
     31       |  386i/150 or 386i/250
     41       |  3/4x0
     42       |  3/80
     51       |  SPARCstation 1   (4/60)
     52       |  SPARCstation IPC (4/40)
     53       |  SPARCstation 1+  (4/65)
     54       |  SPARCstation SLC (4/20)
     55       |  SPARCstation 2   (4/75)
     56       |  SPARCstation ELC (4/25)
     57       |  SPARCstation IPX (4/50)
     61       |  4/e
     71       |  4/6x0   (670)
     72       |  SPARCstation 10,20
     80       |  SPARCclassic, LX, SPARC 5, SPARC 4, SS1000, Voyager, and Ultras
     83       |  Later workstations

=cut

my %sun_machine_types = (
	"2/1x0" => "01",
	"2/50" => "02",
	"3/160" => "11",
	"3/50" => "12",
	"3/2x0" => "13",
	"3/110" => "14",
	"3/60" => "17",
	"3/e" => "18",
	"4/2x0" => "21",
	"4/1x0" => "22",
	"4/3x0" => "23",
	"4/4x0" => "24",
	"386i/150 or 386i/250" => "31",
	"3/4x0" => "41",
	"3/80" => "42",
	"SPARCstation 1   (4/60)" => "51",
	"SPARCstation IPC (4/40)" => "52",
	"SPARCstation 1+  (4/65)" => "53",
	"SPARCstation SLC (4/20)" => "54",
	"SPARCstation 2   (4/75)" => "55",
	"SPARCstation ELC (4/25)" => "56",
	"SPARCstation IPX (4/50)" => "57",
	"4/e" => "61",
	"4/6x0   (670)" => "71",
	"SPARCstation 10,20" => "72",
	"SPARCclassic, LX, SPARC 5, SPARC 4, SS1000, Voyager, and Ultras" => "80",
	"Later workstations" => "83"
);

sub parse_sun_barcode {
	use POSIX qw( strtol );
	my %p = @_;

	unless (defined $p{machine_type} && grep(/$p{machine_type}/, values %sun_machine_types)) {
		croak "Error: Invalid Machine Type " . $p{machine_type};
	}
	unless (defined $p{barcode} && length $p{barcode} == 4) {
		croak "Error: barcode must be provided and must be a string of length 4";
	}

	my $machine_type = oct("0x" . $p{machine_type} . "000000");
	my $barcode = strtol($p{barcode}, 36);
	my $mac_tmp = $barcode - 0x82DC0;
	my %idprom_data = (
		serial_number => $barcode - 0xAA8C0,
	);
	$idprom_data{hostid} = $machine_type + $idprom_data{serial_number};

	my @mac_addr = ( 8, 0, 20 ); #we will use this to build the mac before it becomes a string
	push @mac_addr, (substr(sprintf("%06X", $mac_tmp), -6, 2));
	push @mac_addr, (substr(sprintf("%06X", $mac_tmp), -4, 2));
	push @mac_addr, (substr(sprintf("%06X", $mac_tmp), -2));

	$idprom_data{mac_address} = join ':', @mac_addr;

	return %idprom_data;
}


