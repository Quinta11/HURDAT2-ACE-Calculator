#!/usr/bin/perl
use strict;
use warnings;

################################################################################

# Variables pertaining to file I/O
my $encoding = ":encoding(UTF-8)";                  # UTF-8 encoding for reading file
my $filename = undef;                               # File to read
my $handle   = undef;                               # Assigned value on successful open for future referencing

# Variables to be used as constants
my @validTypes  = ("TS", "SS", "HU");               # Valid storm classifications
my @validTimes  = ("0000", "0600", "1200", "1800"); # Valid fix times

# Variables to be adjusted by the user
my $basin         = undef;                          # Basin to read HURDAT2 data from
my $substringYear = undef;                          # Year to check for ACE total

# Variables to hold acquired values
my @lines = undef;                                  # Array to hold all lines from file
my $ACE = 0;                                        # Accumulated Cyclone Energy

################################################################################

# Initial print statements (not looped)
print "Thank you for using my HURDAT2 ACE calculator!\n";
print "Current functionalities include:\n- Calculating the ACE for a certain year\n";
print "Current basins supports:\n- North Atlantic (NATL)\n- Eastern Pacific (EPAC)\n\n";

# Home, runs indefinitely until user exits program
while(1) {
    # Select basin
    print "Please select the basin to read data from (NATL | EPAC): ";
    $basin = uc(userInput());
    if    ($basin eq "NATL") {$filename = "./hurdat2-natl-latest.txt";}
    elsif ($basin eq "EPAC") {$filename = "./hurdat2-epac-latest.txt";}
    else {
        print "Invalid basin selected. Please try again.\n";
        next;
    }

    # Select year
    print "Please select the year you wish to calculate the ACE total for: ";
    $substringYear = userInput();
    if ($substringYear !~ /^\d{4}$/) {
        print "Invalid year selected. Please try again.\n";
        redo;
    }

    @lines = readFile($filename, $encoding, $handle);   # Read HURDAT2 text file by calling subroutine

    for my $line (@lines) {
        my @elements = split(',', $line);

        ### CHECK ACE TOTAL FOR SPECIFIED YEAR
        # If statement runs if substring is found at the beginning of the first element of each array line
        if(rindex($elements[0], $substringYear, 0) != -1){
            # Check if the fix time and classification type are valid for calculation
            if((grep{$elements[1] =~ /$_/} @validTimes) and (grep {$elements[3] =~ /$_/} @validTypes)) {
                $ACE += calculateACE($elements[6]); # Call subroutine to calculate ACE
            }
        }

        ### CHECK ACE TOTAL FOR SPECIFIED STORM
        # To do...
    }

    # Print ACE total for specified year
    print "$ACE\n";
    $ACE = 0;
}

################################################################################

# Subroutine to read file
sub readFile {
    my $filename = shift;
    my $encoding = shift;
    my $handle   = shift;

    open($handle, "< $encoding", $filename)                 # Open file
        || die "$0: can't open $filename for reading: $!";

    my @lines = readline($handle);                          # Copy file contents to array

    close($handle)                                          # Close file
        || die "$0: can't close $filename: $!";

    return @lines;
}

# Subroutine to get user input
sub userInput {
    chomp(my $userInput = <STDIN>); # Read input from user

    if ($userInput eq "exit") {exit;}     # Exit the program if user inputs "exit"

    return $userInput;
}

# Subroutine to calculate ACE
sub calculateACE {
    my $windSpeed = shift;                      # Shift uses firstmost argument passed to subroutine (ie. elements[6])

    return (($windSpeed * $windSpeed)/10000);
}

