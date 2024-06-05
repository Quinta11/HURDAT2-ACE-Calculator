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
my $basin           = undef;                        # Basin to read HURDAT2 data from
my $substringYear   = undef;                        # Year to check for ACE total
my $calculateOption = undef;                        # Holds user input for calculation option
my $iterations      = undef;                        # Holds user input for number of iterations

# Variables to hold acquired values
my @lines       = undef;                            # Array to hold all lines from file
my $stormFlag   = 0;                                # Flag to check if storm name is valid
my $ACE         = 0;                                # Accumulated Cyclone Energy

################################################################################

# Initial print statements (not looped)
print "Thank you for using my HURDAT2 ACE calculator! To terminate the program, type \"exit\" at any given point.\n\n";
print "Current functionalities include:\n- Calculating the seasonal ACE in a given year\n- Calculating the ACE for a selected tropical cyclone\n";
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

    # Select calculation option (either full season or a specific storm)
    print "Please choose either the full season or a specific storm (FULL | [STORM NAME]): ";
    $calculateOption = uc(userInput());

    @lines = readFile($filename, $encoding, $handle);   # Read HURDAT2 text file by calling subroutine

    for my $line (@lines) {
        my @elements = split(',', $line);

        ### CHECK ACE TOTAL FOR SPECIFIED YEAR
        if($calculateOption eq "FULL") {
            # If statement runs if substring is found at the beginning of the first element of each array line
            if(rindex($elements[0], $substringYear, 0) != -1){
                # Check if the fix time and classification type are valid for calculation
                if((grep{$elements[1] =~ /$_/} @validTimes) and (grep {$elements[3] =~ /$_/} @validTypes)) {
                    $ACE += calculateACE($elements[6]); # Call subroutine to calculate ACE
                }
            }
        }

        ### CHECK ACE TOTAL FOR SPECIFIED STORM
        else {
            # If statement runs if substring is found at the beginning of the first element of each array line
            if(grep(/$substringYear/, $elements[0])){
                # Scan chosen season until storm is found, then set flags and determine how many times to loop
                if((trimString($elements[1]) eq $calculateOption) and ($stormFlag == 0)) {
                    $iterations = $elements[2];
                    $stormFlag = 1;
                    print "\nStorm selected: $calculateOption $substringYear";
                }

                # Check if the fix time and classification type are valid for calculation
                if((grep{$elements[1] =~ /$_/} @validTimes) and (grep {$elements[3] =~ /$_/} @validTypes) and ($stormFlag == 1)) {
                    $ACE += calculateACE($elements[6]); # Call subroutine to calculate ACE
                }

                # Update loops remaining before storm data is fully read; when 0, exits the parent for loop
                if($stormFlag == 1) {
                    $iterations--;
                    if($iterations == 0) {
                        last;
                    }
                }
            }
        }
    }

    # Print ACE total for specified year
    print "\nCalculated ACE: $ACE\n\n";

    # Reset variables for next iteration
    $ACE = 0;
    $basin = undef;
    $substringYear = undef;
    $calculateOption = undef;
    $iterations = undef;
    $stormFlag = 0;
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

# Subroutine to trim unnecessary whitespace (such as storm names from HURDAT files)
sub trimString {
    my $string = shift;
    $string =~ s/^\s*(.*?)\s*$/$1/;
    return $string;
}

