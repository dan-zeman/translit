#!/usr/bin/env perl
# In a CoNLL-U file, transliterates the sentence text, word forms and lemmas.
# Copyright © 2021 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use translit;
use translit::armen;
use translit::greek;
use translit::cyril;
use translit::urdu;
use translit::uyghur;
use translit::brahmi;
use translit::tibetan;
use translit::mkhedruli;
use translit::hebrew;
use translit::ethiopic;
use translit::khmer;
use translit::hangeul;
use translit::han2pinyin;

# Initialize the transliteration tables.
my $scientific = 1;
# 0x500: Arménské písmo.
translit::armen::inicializovat(\%prevod);
translit::greek::inicializovat(\%prevod);
translit::cyril::inicializovat(\%prevod);
# 0x600: Arabské písmo pro urdštinu.
translit::urdu::inicializovat(\%prevod);
translit::uyghur::inicializovat(\%prevod);
# 0x900: Písmo devanágarí.
translit::brahmi::inicializovat(\%prevod, 2304, $scientific);
# 0x980: Bengálské písmo.
translit::brahmi::inicializovat(\%prevod, 2432, $scientific);
# 0xA00: Písmo gurmukhí (paňdžábské).
translit::brahmi::inicializovat(\%prevod, 2560, $scientific);
# 0xA80: Gudžarátské písmo.
translit::brahmi::inicializovat(\%prevod, 2688, $scientific);
# 0xB00: Urijské písmo.
translit::brahmi::inicializovat(\%prevod, 2816, $scientific);
# 0xB80: Tamilské písmo.
translit::brahmi::inicializovat(\%prevod, 2944, $scientific);
# 0xC00: Telugské písmo.
translit::brahmi::inicializovat(\%prevod, 3072, $scientific);
# 0xC80: Kannadské písmo.
translit::brahmi::inicializovat(\%prevod, 3200, $scientific);
# 0xD00: Malajálamské písmo.
translit::brahmi::inicializovat(\%prevod, 3328, $scientific);
# 0x10A0: Gruzínské písmo.
translit::mkhedruli::inicializovat(\%prevod);
# 0x1200: Etiopské písmo.
translit::ethiopic::inicializovat(\%prevod);
translit::tibetan::inicializovat(\%prevod);
translit::hebrew::inicializovat(\%prevod);
# 0x1780: Khmerské písmo.
translit::khmer::inicializovat(\%prevod);
# Korejské písmo Hangeul.
translit::hangeul::inicializovat(\%prevod);
# han2pinyin se neinicializuje a misto prevest() se vola han2pinyin::pinyin()
sub transliterate
{
    my $text = shift;
    return translit::han2pinyin::pinyin(translit::prevest(\%prevod, $text));
}

# Read CoNLL-U from STDIN.
# Write enhanced CoNLL-U to STDOUT.
while(<>)
{
    s/\r?\n$//;
    if(m/^\#\s*text\s*=\s*(.+)$/)
    {
        my $text = $1;
        my $translit = transliterate($text);
        $_ .= "\n\# translit = $translit";
    }
    elsif(m/^\#\s*translit\s*=/)
    {
        # If there was any previous transliteration in the file, discard it.
        $_ = '';
        next;
    }
    elsif(m/^\d/)
    {
        my @f = split(/\t/, $_);
        my @misc = ();
        if($f[9] ne '_')
        {
            @misc = split(/\|/, $f[9]);
        }
        # If there was any previous transliteration in MISC, discard it.
        @misc = grep {!m/^L?Translit=/} (@misc);
        if($f[1] ne '_')
        {
            push(@misc, 'Translit='.transliterate($f[1]));
        }
        if($f[2] ne '_')
        {
            push(@misc, 'LTranslit='.transliterate($f[2]));
        }
        if(scalar(@misc) > 0)
        {
            $f[9] = join('|', @misc);
        }
        else
        {
            $f[9] = '_'
        }
        $_ = join("\t", @f);
    }
    $_ .= "\n";
    print;
}
