#!/usr/bin/env perl
# In a CoNLL-U file, transliterates the sentence text, word forms and lemmas.
# Copyright © 2021 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use lib '/home/zeman/projekty/translit/lib';
use translit;
use translit::han2pinyin;
use Getopt::Long;

my $language;
my $scientific = 1;
GetOptions
(
    'language=s' => \$language,
    'scientific' => \$scientific
);

# Initialize the transliteration tables.
my $maxl = translit::inicializovat_vse(\%prevod, $language, $scientific);
# han2pinyin se neinicializuje a misto prevest() se vola han2pinyin::pinyin()
sub transliterate
{
    my $text = shift;
    return translit::han2pinyin::pinyin(translit::prevest(\%prevod, $text, $maxl));
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
