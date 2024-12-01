#!/usr/bin/perl
# Funkce pro přípravu transliterace z barmského písma do latinky.
# Copyright © 2024 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::myanmar;
use utf8;



# https://en.wikipedia.org/wiki/Mon%E2%80%93Burmese_script
# https://en.wikipedia.org/wiki/MLC_Transcription_System



#------------------------------------------------------------------------------
# Pro některé hlásky máme několik alternativních přepisů.
# Vysvětlivky:
# - bezztrátový = Přepis se snaží odlišit zdrojové znaky tak, aby bylo možné
#   rekonstruovat původní pravopis. K tomu používáme diakritická znaménka.
# - bez diakritiky, spřežky, výslovnost podle angličtiny
# Alternativní přepisy jsou uvedené v tomto pořadí (index do pole):
# 0 ... bezztrátový
# 1 ... ???
# Klíčem k hashi je decimální kód thajského znaku v Unicode.
#------------------------------------------------------------------------------
%alt =
(
    4096 => ['k',  'k'],
    4097 => ['kʰ', 'kh'],
    4098 => ['g',  'g'],
    4099 => ['gʰ', 'gh'],
    4100 => ['ṅ',  'ng'],  # ŋ
    4101 => ['c',  'c'],   # pronounced [s], not [č]
    4102 => ['cʰ', 'ch'],  # pronounced [sʰ], not [čh]
    4103 => ['j',  'j'],   # pronounced [z], not [dž]
    4104 => ['jʰ', 'jh'],  # pronounced [z]
    4105 => ['ñ',  'ny'],  # ň, ɲ
    4106 => ['ññ', 'nny'], # ňň?
    4107 => ['ṭ',  'tt'],
    4108 => ['ṭʰ', 'tth'],
    4109 => ['ḍ',  'dd'],
    4110 => ['ḍʰ', 'ddh'],
    4111 => ['ṇ',  'nn'],
    4112 => ['t',  't'],
    4113 => ['tʰ', 'th'],
    4114 => ['d',  'd'],
    4115 => ['dʰ', 'dh'],
    4116 => ['n',  'n'],
    4117 => ['p',  'p'],
    4118 => ['pʰ', 'ph'],
    4119 => ['b',  'b'],
    4120 => ['bʰ', 'bh'],
    4121 => ['m',  'm'],
    4122 => ['y',  'y'],   # j
    4123 => ['r',  'r'],
    4124 => ['l',  'l'],
    4125 => ['w',  'w'],
    4126 => ['s',  's'],   # pronounced [θ] or [ɾ̪]
    4127 => ['h',  'h'],
    4128 => ['ḷ',  'll']   # pronounced [l]
);



# Samohlásky a slabiky:
# Znak pro souhlásku má v sobě inherentní samohlásku.



#------------------------------------------------------------------------------
# Uloží do globálního hashe přepisy souhlásek a slabik.
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    # Má se do latinky přidávat nečeská diakritika, aby se neztrácela informace?
    my $bezztrat = 1;
    # Kód začátku segmentu s barmským písmem.
    my $pocatek = 4096;
    my $souhlasky = 4096;
    my $samohlasky = 4139;
    my $cislice = 4160;
    my @samohlasky = ('á', 'a', 'i', 'ī', 'u', 'ū', 'e', 'ai', 'ī', 'o', 'e');
    # Visarg (shay ga pauk) označuje vysoký tón, což současně obvykle znamená i dlouhou samohlásku.
    my $visarg = chr(4152);
    # Dot below označuje skřípavý tón, což obvykle znamená krátkou a velmi nízko položenou samohlásku.
    my $dotbelow = chr(4151);
    # Jak virám, tak asat potlačují inherentní samohlásku předcházející souhlásky.
    # Zdá se ale, že v barmštině se častěji používá asat.
    my $viram = chr(4153);
    my $asat = chr(4154);
    # Uložit do tabulky samohlásky jako záložní řešení, pokud bychom je někde
    # nedokázali spojit se souhláskami.
    for(my $j = 0; $j <= $#samohlasky; $j++)
    {
        $prevod->{chr($samohlasky+$j)} = $samohlasky[$j];
    }
    # Visarg by se měl normálně projevit na diakritice samohlásky, ale pokud mi
    # někde zbyde, udělat z něj značku druhého (vysokého) tónu.
    $prevod->{$visarg} = '²';
    $prevod->{$dotbelow} = '³';
    # Uložit do tabulky samostatné souhlásky.
    for(my $i = 4096; $i <= 4128; $i++)
    {
        my $tsouhlaska = chr($i);
        my $rsouhlaska = $alt{$i}[0];
        # Virám a asat potlačují inherentní samohlásku.
        $prevod->{$tsouhlaska.$viram} = $rsouhlaska;
        $prevod->{$tsouhlaska.$asat} = $rsouhlaska;
        # Inherentní samohláska je "a" ve skřípavém tónu.
        $prevod->{$tsouhlaska} = $rsouhlaska.'a̰';
        $prevod->{$tsouhlaska.chr(4140)} = $rsouhlaska.'a';
        $prevod->{$tsouhlaska.chr(4140).$visarg} = $rsouhlaska.'á';
        # 4139 "tall aa" je alternativa k 4140 "aa", která se používá s některými souhláskami, např. "g".
        $prevod->{$tsouhlaska.chr(4139)} = $rsouhlaska.'a';
        $prevod->{$tsouhlaska.chr(4139).$visarg} = $rsouhlaska.'á';
        # Nosová samohláska je v barmštině zachycena jako samohláska + n; až po něm může následovat visarg.
        $prevod->{$tsouhlaska.chr(4140).chr(4116).$asat.$visarg} = $rsouhlaska.'án';
        $prevod->{$tsouhlaska.chr(4139).chr(4116).$asat.$visarg} = $rsouhlaska.'án';
        $prevod->{$tsouhlaska.chr(4141)} = $rsouhlaska.'i';
        $prevod->{$tsouhlaska.chr(4141).chr(4116).$asat.$visarg} = $rsouhlaska.'ín';
        $prevod->{$tsouhlaska.chr(4142)} = $rsouhlaska.'i';
        $prevod->{$tsouhlaska.chr(4142).$visarg} = $rsouhlaska.'í';
        $prevod->{$tsouhlaska.chr(4143)} = $rsouhlaska.'u';
        $prevod->{$tsouhlaska.chr(4143).chr(4116).$asat.$visarg} = $rsouhlaska.'ún';
        $prevod->{$tsouhlaska.chr(4144)} = $rsouhlaska.'u';
        $prevod->{$tsouhlaska.chr(4144).$visarg} = $rsouhlaska.'ú';
        $prevod->{$tsouhlaska.chr(4145)} = $rsouhlaska.'e';
        $prevod->{$tsouhlaska.chr(4145).$visarg} = $rsouhlaska.'é';
        $prevod->{$tsouhlaska.chr(4145).chr(4116).$asat.$visarg} = $rsouhlaska.'én';
        $prevod->{$tsouhlaska.chr(4145).$dotbelow} = $rsouhlaska.'ḛ';
        $prevod->{$tsouhlaska.chr(4145).chr(4116).$asat.$dotbelow} = $rsouhlaska.'ḛn';
        $prevod->{$tsouhlaska.chr(4146)} = $rsouhlaska.'ái';
        $prevod->{$tsouhlaska.chr(4146).$dotbelow} = $rsouhlaska.'a̰i';
        # Přidat slabiky začínající touto souhláskou.
        for(my $j = 0; $j <= $#samohlasky; $j++)
        {
            $prevod->{$tsouhlaska.chr($samohlasky+$j)} = $rsouhlaska.$samohlasky[$j];
            # Barmština má 3 tóny: low, high a creaky: [à] [á] [a̰]
            # https://en.wikipedia.org/wiki/Burmese_phonology#Tones
            # Vysoký tón je často označen visargem za slabikou. Výjimkou jsou slabiky se samohláskami -ai a -au.
            # Skřípavý (creaky) tón je často označen tečkou pod slabikou. Výjimkou jsou slabiky s inherentní samohláskou -a, dále se samohláskou -u a -i.
            #local @tony = ('¹', '²', '³', '⁴');
        }
    }
    # Číslice.
    for(my $i = 0; $i<=9; $i++)
    {
        my $src = chr($cislice+$i);
        $prevod->{$src} = $i;
    }
    # Interpunkce a další znaky.
    $prevod->{chr(4170)} = '.'; # little section
    $prevod->{chr(4171)} = ':'; # section
}



1;
