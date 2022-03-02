#!/usr/bin/perl
# Transliterates Urdu text to Latin script. Differs from translit.pl in that it leaves ambiguous vowels for human postprocessing.
# Copyright © 2010 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use lib '/home/zeman/lib';
use translit;
use translit::urdund;



# 0x600: Arabic script modified for Urdu.
translit::urdund::inicializovat(\%prevod);
while(<>)
{
    print(translit::urdund::prevest($_));
}
