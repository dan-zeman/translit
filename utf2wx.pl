#!/usr/bin/perl
# Převede hindský text z UTF-8 do WX. Potřebujeme to kvůli morfologické analýze.
# Pozor! Zpětný převod bude možný pouze v případě, že vstup neobsahuje latinku, arabské číslice ani jiná indická písma než dévanágarí.
# Copyright © 2010 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use lib '/home/zeman/lib';
use translit;
use translit::brahmi;

# 0x900: Písmo devanágarí. Hodnota 2 znamená, že na výstupu chceme WX.
$maxl = translit::brahmi::inicializovat(\%prevod, 2304, 2);
while(<>)
{
    print(translit::prevest(\%prevod, $_, $maxl));
}
