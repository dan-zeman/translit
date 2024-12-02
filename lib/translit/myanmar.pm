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
    4106 => ['ṇ̃',  'nny'], # ňň?
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
    4128 => ['ḷ',  'll'],  # pronounced [l]
    4159 => ['š',  'sh']
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
    my $cislice = 4160;
    # Visarg (shay ga pauk) označuje vysoký tón, což současně obvykle znamená i dlouhou samohlásku.
    local $visarg = chr(4152);
    # Dot below označuje skřípavý tón, což obvykle znamená krátkou a velmi nízko položenou samohlásku.
    local $dotbelow = chr(4151);
    # Visarg by se měl normálně projevit na diakritice samohlásky, ale pokud mi
    # někde zbyde, udělat z něj značku druhého (vysokého) tónu. Podobně tečka
    # pod samohláskou označuje třetí (skřípavý) tón.
    $prevod->{$visarg} = '²';
    $prevod->{$dotbelow} = '³';
    # Jak virám, tak asat potlačují inherentní samohlásku předcházející souhlásky.
    # Zdá se ale, že v barmštině se častěji používá asat.
    local $viram = chr(4153);
    local $asat = chr(4154);
    $prevod->{$viram} = '';
    $prevod->{$asat} = '';
    # Anusvár signalizuje nosovost předcházející samohlásky. Je to alternativa
    # k připojení nosové souhlásky, které slouží stejnému účelu. Přepíšeme ho
    # jako COMBINING TILDE.
    local $anusvar = chr(4150);
    $prevod->{$anusvar} = chr(771);
    my @tmedialy = ('', chr(4155), chr(4156), chr(4157), chr(4158), chr(4155).chr(4157));
    my @rmedialy = ('', 'y', 'r', 'w', 'h', 'yw');
    for(my $i = 4095; $i <= 4128; $i++)
    {
        if($i == 4095)
        {
            # Uložit do tabulky samohlásky jako záložní řešení, pokud bychom je
            # někde nedokázali spojit se souhláskami.
            my $tsouhlaska = '';
            my $rsouhlaska = '';
            kombinovat_se_samohlaskami($prevod, $tsouhlaska, $rsouhlaska);
        }
        else
        {
            for(my $m = 0; $m <= $#tmedialy; $m++)
            {
                my $tsouhlaska = chr($i).$tmedialy[$m];
                my $rsouhlaska = $alt{$i}[0].$rmedialy[$m];
                # Virám a asat potlačují inherentní samohlásku.
                $prevod->{$tsouhlaska.$viram} = $rsouhlaska;
                $prevod->{$tsouhlaska.$asat} = $rsouhlaska;
                kombinovat_se_samohlaskami($prevod, $tsouhlaska, $rsouhlaska);
            }
        }
    }
    ###!!! Ještě samostatné samohlásky (na začátku slabiky). Ale správně to asi bude složitější než takhle.
    $prevod->{chr(4129)} = 'a̰';
    $prevod->{chr(4129).chr(4139)} = 'a';
    $prevod->{chr(4129).chr(4140)} = 'a';
    $prevod->{chr(4129).chr(4139).$visarg} = 'á';
    $prevod->{chr(4129).chr(4140).$visarg} = 'á';
    $prevod->{chr(4131)} = 'ḭ';
    $prevod->{chr(4132)} = 'í';
    $prevod->{chr(4133)} = 'ṵ';
    $prevod->{chr(4134)} = 'u';
    $prevod->{chr(4134).$visarg} = 'ú';
    $prevod->{chr(4135)} = 'é'; # MLC transcribes it "ei:"
    $prevod->{chr(4135).chr(4157)} = 'éw';
    $prevod->{chr(4137)} = 'áu';
    $prevod->{chr(4138)} = 'au';
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



#------------------------------------------------------------------------------
# Pro danou souhlásku (může být i prázdná) uloží do hashe převody jejích kombi-
# nací se všemi samohláskami.
#------------------------------------------------------------------------------
sub kombinovat_se_samohlaskami
{
    my $prevod = shift; # hash s převodní tabulkou
    my $tsouhlaska = shift; # znak souhlásky v cizím písmu
    my $rsouhlaska = shift; # romanizace souhlásky
    # my @samohlasky = ('á', 'a', 'i', 'ī', 'u', 'ū', 'e', 'ai', 'ī', 'o', 'e');
    # my $samohlasky = 4139;
    ###!!! Zatím vynechávám 4147–4149, což jsou zvláštní samohlásky pro monštinu.
    # Barmština má 3 tóny: low, high a creaky: [à] [á] [a̰]
    # https://en.wikipedia.org/wiki/Burmese_phonology#Tones
    # Vysoký tón je často označen visargem za slabikou. Výjimkou jsou slabiky se samohláskami -ai a -au.
    # Skřípavý (creaky) tón je často označen tečkou pod slabikou. Výjimkou jsou slabiky s inherentní samohláskou -a, dále se samohláskou -u a -i.
    #local @tony = ('¹', '²', '³', '⁴');
    # Inherentní samohláska je "a" ve skřípavém tónu.
    $prevod->{$tsouhlaska} = $rsouhlaska.'a̰';
    $prevod->{$tsouhlaska.$dotbelow.$asat} = $rsouhlaska.'a̰';
    $prevod->{$tsouhlaska.chr(4140)} = $rsouhlaska.'a';
    $prevod->{$tsouhlaska.chr(4140).$visarg} = $rsouhlaska.'á';
    $prevod->{$tsouhlaska.chr(4140).$dotbelow} = $rsouhlaska.'a̰';
    # 4139 "tall aa" je alternativa k 4140 "aa", která se používá s některými souhláskami, např. "g".
    $prevod->{$tsouhlaska.chr(4139)} = $rsouhlaska.'a';
    $prevod->{$tsouhlaska.chr(4139).$visarg} = $rsouhlaska.'á';
    $prevod->{$tsouhlaska.chr(4139).$dotbelow} = $rsouhlaska.'a̰';
    $prevod->{$tsouhlaska.chr(4141)} = $rsouhlaska.'ḭ';
    $prevod->{$tsouhlaska.chr(4142)} = $rsouhlaska.'i';
    $prevod->{$tsouhlaska.chr(4142).$visarg} = $rsouhlaska.'í';
    $prevod->{$tsouhlaska.chr(4143)} = $rsouhlaska.'ṵ';
    $prevod->{$tsouhlaska.chr(4143).$anusvar.$visarg} = $rsouhlaska.'ú'.chr(771);
    $prevod->{$tsouhlaska.chr(4144)} = $rsouhlaska.'u';
    $prevod->{$tsouhlaska.chr(4144).$visarg} = $rsouhlaska.'ú';
    $prevod->{$tsouhlaska.chr(4141).chr(4143)} = $rsouhlaska.'o';
    $prevod->{$tsouhlaska.chr(4141).chr(4143).$visarg} = $rsouhlaska.'ó';
    $prevod->{$tsouhlaska.chr(4141).chr(4143).$dotbelow} = $rsouhlaska.'o̰';
    $prevod->{$tsouhlaska.chr(4145)} = $rsouhlaska.'e';
    $prevod->{$tsouhlaska.chr(4145).$visarg} = $rsouhlaska.'é';
    $prevod->{$tsouhlaska.chr(4145).$dotbelow} = $rsouhlaska.'ḛ';
    $prevod->{$tsouhlaska.chr(4122).$asat} = $rsouhlaska.'ai';
    $prevod->{$tsouhlaska.chr(4146)} = $rsouhlaska.'ái';
    $prevod->{$tsouhlaska.chr(4146).$dotbelow} = $rsouhlaska.'a̰i';
    $prevod->{$tsouhlaska.chr(4145).chr(4140)} = $rsouhlaska.'áu';
    $prevod->{$tsouhlaska.chr(4145).chr(4140).$asat} = $rsouhlaska.'au';
    $prevod->{$tsouhlaska.chr(4145).chr(4140).$dotbelow} = $rsouhlaska.'a̰u';
    # Nosová samohláska je v barmštině zachycena jako samohláska + nosová souhláska; až po ní může následovat visarg.
    # (Nosová samohláska může být také zachycena pomocí anusváru, ale ten zatím řešíme jinak.)
    my @tnosovky = (chr(4100), chr(4105), chr(4106), chr(4111), chr(4116), chr(4121));
    my @rnosovky = ('ṅ', 'ñ', 'ṇ̃', 'ṇ', 'n', 'm');
    for(my $n = 0; $n <= $#tnosovky; $n++)
    {
        $prevod->{$tsouhlaska.$tnosovky[$n].$asat.$visarg} = $rsouhlaska.'á'.$rnosovky[$n];
        $prevod->{$tsouhlaska.$tnosovky[$n].$asat.$dotbelow} = $rsouhlaska.'a̰'.$rnosovky[$n];
        $prevod->{$tsouhlaska.$tnosovky[$n].$dotbelow.$asat} = $rsouhlaska.'a̰'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4140).$tnosovky[$n].$asat.$visarg} = $rsouhlaska.'á'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4139).$tnosovky[$n].$asat.$visarg} = $rsouhlaska.'á'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4139).$tnosovky[$n].$asat.$dotbelow} = $rsouhlaska.'a̰'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4141).$tnosovky[$n].$asat.$visarg} = $rsouhlaska.'í'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4143).$tnosovky[$n].$asat.$visarg} = $rsouhlaska.'ú'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4145).$tnosovky[$n].$asat.$visarg} = $rsouhlaska.'é'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4145).$tnosovky[$n].$asat.$dotbelow} = $rsouhlaska.'ḛ'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4145).chr(4140).$tnosovky[$n].$asat.$visarg} = $rsouhlaska.'áu'.$rnosovky[$n];
        $prevod->{$tsouhlaska.chr(4145).chr(4140).$tnosovky[$n].$asat.$dotbelow} = $rsouhlaska.'a̰u'.$rnosovky[$n];
    }
}



1;
