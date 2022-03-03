#!/usr/bin/perl
# Funkce pro přípravu transliterace z cyrilice do latinky.
# Copyright © 2013 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::cyril;
use utf8;



#------------------------------------------------------------------------------
# Uloží do hashe přepisy znaků.
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    # Volitelně kód zdrojového jazyka (výchozí je ruština, ale např. z bulharštiny chceme některá písmena přepsat odlišně).
    my $jazyk = shift;
    # Má se do latinky přidávat nečeská diakritika, aby se neztrácela informace?
    my $bezztrat = 1;
    my $alt = 1; # český přepis pro putty
    my %cyril =
    (
        # ruština
        1040 => 'A',
        1041 => 'B',
        1042 => 'V',
        1043 => 'G',
        1044 => 'D',
        1045 => 'E',
        1025 => 'Ë',
        1046 => 'Ž',
        1047 => 'Z',
        1048 => 'I',
        1049 => 'J',
        1050 => 'K',
        1051 => 'L',
        1052 => 'M',
        1053 => 'N',
        1054 => 'O',
        1055 => 'P',
        1056 => 'R',
        1057 => 'S',
        1058 => 'T',
        1059 => 'U',
        1060 => 'F',
        1061 => 'H',
        1062 => 'C',
        1063 => 'Č',
        1064 => 'Š',
        1065 => 'ŠČ',
        1066 => "''",
        1067 => 'Y',
        1068 => "'",
        1069 => 'È',
        1070 => 'JU',
        1071 => 'JA',
        1072 => 'a',
        1073 => 'b',
        1074 => 'v',
        1075 => 'g',
        1076 => 'd',
        1077 => 'e',
        1105 => 'ë',
        1078 => 'ž',
        1079 => 'z',
        1080 => 'i',
        1081 => 'j',
        1082 => 'k',
        1083 => 'l',
        1084 => 'm',
        1085 => 'n',
        1086 => 'o',
        1087 => 'p',
        1088 => 'r',
        1089 => 's',
        1090 => 't',
        1091 => 'u',
        1092 => 'f',
        1093 => 'h',
        1094 => 'c',
        1095 => 'č',
        1096 => 'š',
        1097 => 'šč',
        1098 => "''",
        1099 => 'y',
        1100 => "'",
        1101 => 'è',
        1102 => 'ju',
        1103 => 'ja',
        # ukrajinština
        1028 => 'JE',
        1030 => 'I',
        1031 => 'JI', # Ï?
        1168 => 'G',
        1108 => 'je',
        1110 => 'i',
        1111 => 'ji', # ï?
        1169 => 'g',
        # běloruština
        1038 => 'W',
        1118 => 'w',
        # srbština
        1026 => 'Đ',
        1032 => 'J',
        1033 => 'LJ',
        1034 => 'NJ',
        1035 => 'Ć',
        1039 => 'DŽ',
        1106 => 'đ',
        1112 => 'j',
        1113 => 'lj',
        1114 => 'nj',
        1115 => 'ć',
        1119 => 'dž',
        # makedonština
        1027 => 'Ď',
        1029 => 'DZ',
        1036 => 'Ť',
        1107 => 'ď',
        1109 => 'dz',
        1116 => 'ť',
        # staroslověnština
        1122 => 'Ě',  # YAT: Ѣ
        1123 => 'ě',  # YAT: ѣ
        1124 => 'JE', # IOTIFIED E: Ѥ
        1125 => 'je', # IOTIFIED E: ѥ
        1126 => 'Ę',  # LITTLE YUS: Ѧ
        1127 => 'ę',  # LITTLE YUS: ѧ
        1128 => 'JĘ', # IOTIFIED LITTLE YUS: Ѩ
        1129 => 'ję', # IOTIFIED LITTLE YUS: ѩ
        1130 => 'Ǫ',  # BIG YUS: Ѫ
        1131 => 'ǫ',  # BIG YUS: ѫ
        1132 => 'JǪ', # IOTIFIED BIG YUS: Ѭ
        1133 => 'jǫ', # IOTIFIED BIG YUS: ѭ
        1144 => 'U',  # UK: Ѹ
        1145 => 'u',  # UK: ѹ
        42566 => 'I', # IOTA: Ꙇ
        42567 => 'i', # IOTA: ꙇ
        42570 => 'U', # MONOGRAPH UK: Ꙋ
        42571 => 'u', # MONOGRAPH UK: ꙋ
        42576 => 'Y', # YERU WITH BACK YER: Ꙑ
        42577 => 'y', # YERU WITH BACK YER: ꙑ
        # mongolština a turkické jazyky
        1256 => 'Ö',
        1257 => 'ö',
        1198 => 'Ü',
        1199 => 'ü',
    );
    # Odchylky pro některé zdrojové jazyky.
    if($jazyk eq 'be') # běloruština
    {
        # Změna g --> h.
        $cyril{1043} = 'H';
        $cyril{1075} = 'h';
        $cyril{1061} = 'CH'; # X?
        $cyril{1093} = 'ch'; # x?
    }
    elsif($jazyk eq 'uk') # ukrajinština
    {
        # Změna g --> h.
        $cyril{1043} = 'H';
        $cyril{1075} = 'h';
        $cyril{1061} = 'CH'; # X?
        $cyril{1093} = 'ch'; # x?
        # Posun tvrdého y.
        $cyril{1048} = 'Y';
        $cyril{1080} = 'y';
        # Apostrof místo tvrdého znaku.
        $cyril{ord("'")} = "''";
    }
    elsif($jazyk eq 'bg') # bulharština
    {
        # Tvrdý znak funguje jako šva, tradičně se přepisuje odpovídajícím rumunským písmenem.
        $cyril{1066} = 'Ă';
        $cyril{1098} = 'ă';
        # Místo "šč" se v bulharštině čte "št".
        $cyril{1065} = 'ŠT';
        $cyril{1097} = 'št';
    }
    elsif($jazyk eq 'cu') # staroslověnština
    {
        $cyril{1061} = 'CH'; # X?
        $cyril{1093} = 'ch'; # x?
        # Měkký i tvrdý znak jsou tzv. jery a zřejmě odpovídají velmi krátkým samohláskám. Někdy se v přepisu do latinky nechávají v původním tvaru, někdy se přepisují pomocí samohlásek a diakritiky:
        $cyril{1066} = 'Ŭ';
        $cyril{1098} = 'ŭ';
        $cyril{1068} = 'Ĭ';
        $cyril{1100} = 'ĭ';
        # Místo "šč" se ve staroslověnštině čte "št".
        $cyril{1065} = 'ŠT';
        $cyril{1097} = 'št';
    }
    foreach my $kod (keys(%cyril))
    {
        $prevod->{chr($kod)} = $cyril{$kod};
    }
    return $prevod;
}



1;
