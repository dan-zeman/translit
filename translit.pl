#!/usr/bin/perl
# Převede text z cizího písma do latinky. Jde pouze o usnadnění čitelnosti, ne nutně o zachování veškeré informace.
# Copyright © 2007-2008, 2020, 2022 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use lib '/home/zeman/projekty/translit/lib';
use translit;
use Getopt::Long;
my $language;
my $scientific;
GetOptions
(
    'language=s' => \$language,
    'scientific' => \$scientific
);



translit::inicializovat_vse(\%prevod, $language, $scientific);
# han2pinyin se neinicializuje a misto prevest() se vola han2pinyin::pinyin()
while(<>)
{
    print(translit::han2pinyin::pinyin(translit::prevest(\%prevod, $_)));
}
