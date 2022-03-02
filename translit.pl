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
use translit::armen;
use translit::greek;
use translit::cyril;
use translit::syriac;
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
use Getopt::Long;
my $language;
my $scientific;
GetOptions
(
    'language=s' => \$language,
    'scientific' => \$scientific
);



# 0x500: Arménské písmo.
translit::armen::inicializovat(\%prevod);
translit::greek::inicializovat(\%prevod);
translit::cyril::inicializovat(\%prevod, $language);
translit::syriac::inicializovat(\%prevod);
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
while(<>)
{
    print(translit::han2pinyin::pinyin(translit::prevest(\%prevod, $_)));
}
