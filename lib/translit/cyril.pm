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
        1037 => 'Ì',
        1107 => 'ď',
        1109 => 'dz',
        1116 => 'ť',
        1117 => 'ì',  # CYRILLIC SMALL LETTER I WITH GRAVE is not considered a separate letter in Bulgarian/Macedonian and is only used to disambiguate the pronoun ѝ “her” (dative) from the conjunction и “and”.
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
        # staroslověnská kombinační písmena jako horní index
        11744 => 'b', # 2DE0: COMBINING CYRILLIC LETTER BE
        11745 => 'v',
        11746 => 'g',
        11747 => 'd',
        11748 => 'ž',
        11749 => 'z',
        11750 => 'k',
        11751 => 'l',
        11752 => 'm',
        11753 => 'n',
        11754 => 'o',
        11755 => 'p',
        11756 => 'r',
        11757 => 's',
        11758 => 't',
        11759 => 'ch',
        11760 => 'c',
        11761 => 'č',
        11762 => 'š',
        11763 => 'št',
        11764 => 'f',
        11765 => 'st',
        11766 => 'a',
        11767 => 'e',
        11768 => 'ć', # 2DF8: COMBINING CYRILLIC LETTER DJERV
        11769 => 'u',
        11770 => 'ě',
        11771 => 'ju',
        11772 => 'ja',
        11773 => 'ę',
        11774 => 'ǫ',
        11775 => 'jǫ',
        42612 => 'je', # A674: COMBINING CYRILLIC LETTER UKRAINIAN IE
        42613 => 'i',
        42614 => 'ji',
        42615 => 'u',
        42616 => 'ŭ',
        42617 => 'y',
        42618 => 'ĭ',
        42619 => 'ô',
        42654 => 'f', # A69E: COMBINING CYRILLIC LETTER EF
        42655 => 'je',
        # mongolština a turkické jazyky
        1256 => 'Ö',
        1257 => 'ö',
        1198 => 'Ü',
        1199 => 'ü',
        # uralské jazyky
        1223 => 'Ŋ', # 04C7: CYRILLIC CAPITAL LETTER EN WITH HOOK (used in Nenets)
        1224 => 'ŋ', # 04C8: CYRILLIC SMALL LETTER EN WITH HOOK (used in Nenets)
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
    elsif($jazyk eq 'yrk') # něnečtina
    {
        # The modifier letters should not be replaced by default but the Nenets
        # scheme assumes they represent the glottal stop. Note that people
        # sometimes mis-type them as 8217 (U+2019) RIGHT SINGLE QUOTATION MARK
        # and 8221 (U+201D) RIGHT DOUBLE QUOTATION MARK, respectively. We do
        # not transcribe those characters here because they could be real punctuation.
        # The letter ⟨ˮ⟩ marks a "plain" glottal stop, while ⟨ʼ⟩ marks a glottal stop derived from a word-final n.
        # Ruské názvy: "zvonkoj taser", "gluhoj taser".
        # Jiné transkripce: ʼ = h (nasalizable glottal stop), ˮ = q (non-nasalizable glottal stop). But both are pronounced 'ʔ'.
        $cyril{700} = 'ʔ'; #'ʔ¹'; # 02BC: MODIFIER LETTER APOSTROPHE (used in Nenets)
        $cyril{750} = 'ʡ'; #'ʔ²'; # 02EE: MODIFIER LETTER DOUBLE APOSTROPHE (used in Nenets)
        $cyril{1042} = 'W'; # V
        $cyril{1074} = 'w'; # v
        $cyril{1061} = 'X'; # CH
        $cyril{1093} = 'x'; # ch
        $cyril{1067} = 'I'; # Y
        $cyril{1099} = 'i'; # y
        # Soft sign
        $cyril{1068} = 'J²';
        $cyril{1100} = 'j²';
        # Hard sign
        $cyril{1066} = '"';
        $cyril{1098} = '"';
        # The following seem to be alternatives for the standard "EN WITH HOOK".
        $cyril{1187} = 'ŋ'; # ң 04A3 CYRILLIC SMALL LETTER EN WITH DESCENDER
        $cyril{1226} = 'ŋ'; # ӊ 04CA CYRILLIC SMALL LETTER EN WITH TAIL
        # Hard e.
        $cyril{1069} = 'Æ'; # 'È',
        $cyril{1101} = 'æ'; # 044D CYRILLIC SMALL LETTER E (in Russian we transcribe it as 'è')
        # If we want transcription instead of transliteration, we need to account
        # for different ways of marking palatalized consonants. But we will do
        # it below, directly in the $prevod hash.
    }
    foreach my $kod (keys(%cyril))
    {
        $prevod->{chr($kod)} = $cyril{$kod};
    }
    if($jazyk eq 'yrk') # Nenets: Additional rules to move from transliteration to transcription.
    {
        # We already have simple rewrite rules that will be used when the consonant is not palatalized.
        # Here we will add palatalized transcriptions when the consonant is followed by a palatalizing vowel.
        my %palatalized =
        (
            'б' => 'b́',
            'д' => 'ď',
            'з' => 'ź',
            'л' => 'ľ',
            'м' => 'ḿ',
            'н' => 'ń',
            'п' => 'ṕ',
            'р' => 'ŕ',
            'с' => 'ś',
            'т' => 'ť',
            'ц' => 'ć'
        );
        my @lckeys = keys(%palatalized);
        foreach my $x (@lckeys)
        {
            unless(uc($x) eq $x)
            {
                $palatalized{uc($x)} = uc($palatalized{$x});
            }
        }
        my %palatalizing =
        (
            'ь' => '',
            'е' => 'e',
            'ё' => 'o',
            'и' => 'i',
            'ю' => 'u',
            'я' => 'a'
        );
        @lckeys = keys(%palatalizing);
        foreach my $x (@lckeys)
        {
            unless(uc($x) eq $x)
            {
                $palatalizing{uc($x)} = uc($palatalizing{$x});
            }
        }
        foreach my $consonant (keys(%palatalized))
        {
            foreach my $vowel (keys(%palatalizing))
            {
                $prevod->{$consonant.$vowel} = $palatalized{$consonant}.$palatalizing{$vowel};
            }
        }
    }
    return $prevod;
}



1;
