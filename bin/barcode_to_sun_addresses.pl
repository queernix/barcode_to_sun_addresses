#!/usr/bin/perl

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

use warnings qw(all);
use strict;
use 5.005;

use Getopt::Long;
use Pod::Usage;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Ewaste::Sun::Barcode;

=pod 

=head1 SYNOPSIS

    barcode_to_sun_addresses.pl --machine_type=machine_type --barcode=barcode

=head1 DESCRIPTION

Converts from a 4-character barcode on an older Sun IDPROM chip into 
a serial #, hostid, and ethernet address. You need to know the Sun 'machine type':

Machine type

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

e.g. if you were going to run this for a SPARCstation 1 with a barcode of 'JET2', you'd use:

    barcode_to_sun_addresses.pl --machine_type=51 --barcode=JET2

=cut

# declare variables for options
my $help = 0;
my $machine_type;
my $barcode;

# Deal with the command line arguments
GetOptions(
    'help|h!'         => \$help,
    'machine_type|m=s' => \$machine_type,
    'barcode|b=s'      => \$barcode
) or pod2usage(-verbose => 1, -exitval => 1, -output => \*STDERR);

pod2usage(-verbose => 2) if $help;

pod2usage(-verbose => 1, -exitval => 1, -output => \*STDERR) unless ($machine_type && $barcode);

my %idprom_data = parse_sun_barcode (
	machine_type => $machine_type,
	barcode      => $barcode
) or die "failed to parse barcode...";

# Print our variables
print "IDPROM Barcode was: $barcode\n";
print "Serial # in hex is: " . sprintf("%X", $idprom_data{serial_number}) . "\n";
print "Serial # in decimal is: $idprom_data{serial_number}\n";
print "Ethernet MAC address is: $idprom_data{mac_address}\n";
print "Host ID is: " . sprintf("%X", $idprom_data{hostid}) . "\n";
