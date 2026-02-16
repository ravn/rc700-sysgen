#!/usr/bin/perl
use strict;
use warnings;

my %by_addr;
my @order;

while (<>) {
    chomp;

    # Expand tabs to spaces
    #s/\t/    /g;

    # Skip pure comments or blank lines
    next if /^\s*$/;
    next if /^\s*;/;

    # Example line:
    # 110:   98+7  001A  1A         LD A,(DE)        ; Get source
    #
    # Capture:
    #   $1 = address (hex)
    #   $2 = instruction text
    if ( /^\s*\d+:[ \d+-]*\t([0-9A-F]{4})...........(.*)$/i ) {
    	#print "$_\n";
        my ($addr, $inst) = (uc($1), $2);

        # Remove trailing comments
        #$inst =~ s/;.*$//;

        # Normalize
        $inst =~ s/,/./g;
        $inst =~ s/\s+/ /g;
        $inst =~ s/^\s+|\s+$//g;

        # Track first appearance order
        if (!exists $by_addr{$addr}) {
            push @order, $addr;
        }

        # Combine multiple instructions at same address
        push @{ $by_addr{$addr} }, $inst;
    }
}

# Output for MAME comadd style
for my $addr (@order) {
    my $joined = join(" ! ", @{ $by_addr{$addr} });
    print "comadd $addr,$joined\n";
}
