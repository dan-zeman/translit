#!/usr/bin/perl
# Functions to prepare and use transliteration tables.
# Copyright © 2008, 2022 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package translit;
use utf8;
use translit::armen;
use translit::greek;
use translit::cyril;
use translit::syriac;
use translit::arab;
use translit::urdu;
use translit::uyghur;
use translit::brahmi;
use translit::tibetan;
use translit::mkhedruli;
use translit::hebrew;
use translit::ethiopic;
use translit::thai;
use translit::khmer;
use translit::hangeul;
use translit::han2pinyin;



#------------------------------------------------------------------------------
# Initialize transliteration from any known script to Latin.
#------------------------------------------------------------------------------
sub inicializovat_vse
{
    my $prevod = shift; # reference to the hash where the transliteration table should be stored
    my $language = shift; # language code may trigger different transliteration for some scripts (optional parameter)
    my $scientific = shift; # prefer scientific transliteration if there are multiple options
    # 0x500: Armenian
    translit::armen::inicializovat($prevod);
    translit::greek::inicializovat($prevod);
    translit::cyril::inicializovat($prevod, $language);
    translit::syriac::inicializovat($prevod);
    # 0x600: Arabic
    # The Arabic romanizations for Urdu and Uyghur are in conflict; the preferred language should be read the last,
    # to overwrite any previous definition of conflicting characters.
    if($language eq 'ug')
    {
        translit::arab::inicializovat($prevod);
        translit::urdu::inicializovat($prevod);
        translit::uyghur::inicializovat($prevod);
    }
    elsif($language eq 'ur')
    {
        translit::arab::inicializovat($prevod);
        translit::uyghur::inicializovat($prevod);
        translit::urdu::inicializovat($prevod);
    }
    else
    {
        translit::uyghur::inicializovat($prevod);
        translit::urdu::inicializovat($prevod);
        translit::arab::inicializovat($prevod);
    }
    # 0x900: Devanagari (Hindi and other languages)
    translit::brahmi::inicializovat($prevod, 2304, $scientific);
    # 0x980: Bengali and Assamese
    translit::brahmi::inicializovat($prevod, 2432, $scientific);
    # 0xA00: Gurmukhi (Punjabi)
    translit::brahmi::inicializovat($prevod, 2560, $scientific);
    # 0xA80: Gujarati
    translit::brahmi::inicializovat($prevod, 2688, $scientific);
    # 0xB00: Oriya
    translit::brahmi::inicializovat($prevod, 2816, $scientific);
    # 0xB80: Tamil
    translit::brahmi::inicializovat($prevod, 2944, $scientific);
    # 0xC00: Telugu
    translit::brahmi::inicializovat($prevod, 3072, $scientific);
    # 0xC80: Kannada
    translit::brahmi::inicializovat($prevod, 3200, $scientific);
    # 0xD00: Malayalam
    translit::brahmi::inicializovat($prevod, 3328, $scientific);
    # 0x10A0: Mkhedruli (Georgian)
    translit::mkhedruli::inicializovat($prevod);
    # 0x1200: Ethiopic (Amharic and other languages)
    translit::ethiopic::inicializovat($prevod);
    translit::tibetan::inicializovat($prevod);
    translit::hebrew::inicializovat($prevod);
    # 0xE00: Thai
    translit::thai::inicializovat($prevod);
    # 0x1780: Khmer
    translit::khmer::inicializovat($prevod);
    # Korean Hangeul
    translit::hangeul::inicializovat($prevod);
    # Note: There is currently no initialization for Chinese (Han) characters.
    # Instead of prevest(), one then has to call han2pinyin::pinyin().
    # Figure out and return the maximum length of an input sequence.
    my $maxl = 1; map {$maxl = max($maxl, length($_))} (keys(%{$prevod}));
    return $maxl;
}



#------------------------------------------------------------------------------
# Returns maximum of two values.
#------------------------------------------------------------------------------
sub max
{
    my $a = shift;
    my $b = shift;
    return $a>=$b ? $a : $b;
}



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
