#!/usr/bin/perl
# Převede čínské znaky z UTF-8 na pinyin.
# (c) 2007 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use han2pinyin;

# Číst vstup, čínské znaky převádět, zbytek nechat.
while(<>)
{
    if(m/<f>(.*?)</)
    {
        my $han = $1;
        my $pinyin = "$han ".han2pinyin::pinyin($han);
        s/$han/$pinyin/;
    }
    print;
}
