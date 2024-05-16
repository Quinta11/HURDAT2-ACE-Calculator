#!/usr/bin/perl
use strict;
use warnings;

################################################################################

# Variables pertaining to file I/O
my $filename = "./hurdat2-natl-latest.txt"; # File to read
my $encoding = ":encoding(UTF-8)";          # UTF-8 encoding for reading file
my $handle   = undef;                       # Assigned value on successful open for future referencing

# Variables to be used in the program
my @validTypes    = ("TS", "SS", "HU");                 # Valid storm classifications
my @validTimes    = ("0000", "0600", "1200", "1800");   # Valid fix times
my $substringYear = "2005";                             # Year to check for ACE total
my $ACE           = 0;                                  # Accumulated Cyclone Energy

################################################################################

# Open file for reading
open($handle, "< $encoding", $filename)
    || die "$0: can't open $filename for reading: $!";

# Read all lines from file
my @lines = readline($handle);

for my $line (@lines) {
    my @elements = split(',', $line);

    ### CHECK ACE TOTAL FOR SPECIFIED YEAR
    # If statement runs if substring is found at the beginning of the first element of each array line
    if(rindex($elements[0], $substringYear, 0) != -1){
        # Check if the fix time and classification type are valid for calculation
        if((grep{$elements[1] =~ /$_/} @validTimes) and (grep {$elements[3] =~ /$_/} @validTypes)) {
            $ACE += (($elements[6] * $elements[6])/10000);
        }
    }

    ### CHECK ACE TOTAL FOR SPECIFIED STORM
    # To do...
}

# Print ACE total for specified year
print "$ACE\n";

# Close file
close($handle)
    || die "$0: can't close $filename: $!";

