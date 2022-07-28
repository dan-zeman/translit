#!/usr/bin/perl
# Functions to prepare and use transliteration tables.
# Copyright © 2008, 2022 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package translit;
use utf8;



#------------------------------------------------------------------------------
# Debugging: print the transliteration table.
#------------------------------------------------------------------------------
sub vypsat
{
    my $prevod = shift; # reference to the hash with the transliteration table
    binmode(STDOUT, ':utf8');
    foreach my $klic (sort(keys(%{$prevod})))
    {
        print("$klic\t$prevod->{$klic}\n");
    }
}



#------------------------------------------------------------------------------
# Converts a string from one script or encoding to another. Before calling this
# function, we have to initialize the transliteration table (hash) in the
# respective module. This function does not restrict the length of the substring
# whose transliteration can be defined in the hash, but it does not scan the
# hash to figure out the maximal length (it would not be efficient; this
# function may be called separately for each word, million times in a row).
# Instead, one may to figure out the maximal length beforehand and give it to
# the function as a parameter. Without the parameter, the function will use a
# default value.
#------------------------------------------------------------------------------
sub prevest
{
    my $prevod = shift; # reference to the hash with the transliteration table
    my $retezec = shift;
    my $maxl = shift; # maximum possible length of the source substring
    $maxl = 5 unless($maxl); # default maximum length
    my $vysledek;
    my @chars = split(//, $retezec);
    my $l = scalar(@chars);
    for(my $i = 0; $i<=$#chars; $i++)
    {
        $maxl = $l-$i if($i+$maxl>$l);
        for(my $j = $maxl; $j>0; $j--)
        {
            my $usek = join('', @chars[$i..($i+$j-1)]);
            if(exists($prevod->{$usek}))
            {
                $vysledek .= $prevod->{$usek};
                $i += $j-1;
                last;
            }
            # If no transliteration is available for the current character, copy the character to the output.
            elsif($j==1)
            {
                $vysledek .= $usek;
            }
        }
    }
    return $vysledek;
}



1;
