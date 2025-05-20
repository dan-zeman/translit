#!/usr/bin/perl
# Funkce pro přípravu transliterace z thajského písma do latinky.
# Copyright © 2022 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::thai;
use utf8;
use Unicode::Normalize;



# https://en.wikipedia.org/wiki/Thai_script



#------------------------------------------------------------------------------
# Pro některé hlásky máme několik alternativních přepisů.
# Vysvětlivky:
# - bezztrátový = Přepis se snaží odlišit zdrojové znaky tak, aby bylo možné
#   rekonstruovat původní pravopis. K tomu používáme diakritická znaménka.
# - standard = Odpovídá královské thajské normě RTGS (Royal Thai General System
#   of Transcription), která se téměř shoduje s ISO 11940-2. Znaky, které se
#   vyslovují stejně, dostanou stejný přepis. U souhlásek se místo diakritiky
#   používají spřežky s písmenem "h".
# Alternativní přepisy jsou uvedené v tomto pořadí (index do pole):
# 0 ... bezztrátový
# 1 ... thajský královský standard
# 2 ... thajský název znaku (tradičně následovaný thajským slovem, kde se vyskytuje)
# 3 ... třída znaku (high = aspirated, mid = unaspirated, low = formerly voiced)
# Klíčem k hashi je decimální kód thajského znaku v Unicode.
#------------------------------------------------------------------------------
%alt =
(
    3585 => ['k',  'k',  'ko kai',       'mid'],
    3586 => ['kʰ', 'kh', 'kho khai',     'high'],
    3587 => ['ǩʰ', 'kh', 'kho khuat',    'high'], # zastaralý znak, varianta kho khai, s nímž má stejnou výslovnost i třídu
    3588 => ['gʰ', 'kh', 'kho khwai',    'low'],
    3589 => ['ǧʰ', 'kh', 'kho khon',     'low'], # zastaralý znak, varianta kho khwai, s nímž má stejnou výslovnost i třídu
    3590 => ['qʰ', 'kh', 'kho ra-khang', 'low'],
    3591 => ['ŋ',  'ng', 'ngo ngu',      'low'],
    3592 => ['č',  'ch', 'cho chan',     'mid'],
    3593 => ['čʰ', 'ch', 'cho ching',    'high'],
    3594 => ['ćʰ', 'ch', 'cho chang',    'low'],
    3595 => ['c',  's',  'so so',        'low'],
    3596 => ['jʰ', 'ch', 'cho choe',     'low'],
    3597 => ['ŷ',  'y',  'yo ying',      'low'],
    3598 => ['ḍ',  'd',  'do chada',     'mid'], # Modern Thai sounds /b/ and /d/ were formerly — and sometimes still are — pronounced /ʔb/ and /ʔd/. For this reason, they were treated as voiceless unaspirated, and hence placed in the "middle" class; this was also the reason they were unaffected by the changes that devoiced most originally voiced stops.
    3599 => ['ṭ',  't',  'to patak',     'mid'],
    3600 => ['ṭʰ', 'th', 'tho than',     'high'],
    3601 => ['ḍʰ', 'th', 'tho montho',   'low'],
    3602 => ['ḑʰ', 'th', 'tho phuthao',  'low'],
    3603 => ['ṇ',  'n',  'no nen',       'low'],
    3604 => ['d',  'd',  'do dek',       'mid'],
    3605 => ['t',  't',  'to tao',       'mid'],
    3606 => ['tʰ', 'th', 'tho thung',    'high'],
    3607 => ['dʰ', 'th', 'tho thahan',   'low'],
    3608 => ['ḏʰ', 'th', 'tho thong',    'low'],
    3609 => ['n',  'n',  'no nu',        'low'],
    3610 => ['b',  'b',  'bo baimai',    'mid'],
    3611 => ['p',  'p',  'po pla',       'mid'],
    3612 => ['pʰ', 'ph', 'pho phung',    'high'],
    3613 => ['fʰ', 'f',  'fo fa',        'high'],
    3614 => ['bʰ', 'ph', 'pho phan',     'low'],
    3615 => ['f',  'f',  'fo fan',       'low'],
    3616 => ['ḇʰ', 'ph', 'pho samphao',  'low'],
    3617 => ['m',  'm',  'mo ma',        'low'],
    3618 => ['y',  'y',  'yo yak',       'low'],
    3619 => ['r',  'r',  'ro rua',       'low'],
    3620 => ['ṟ',  'r',  'ru',           ''],
    3621 => ['l',  'l',  'lo ling',      'low'],
    3622 => ['ḻ',  'l',  'lu',           ''],
    3623 => ['w',  'w',  'wo waen',      'low'],
    3624 => ['ś',  's',  'so sala',      'high'],
    3625 => ['š',  's',  'so rusi',      'high'],
    3626 => ['s',  's',  'so sua',       'high'],
    3627 => ['h',  'h',  'ho hip',       'high'],
    3628 => ['ḷ',  'l',  'lo chula',     'low'],
    3629 => ["'",  "'",  'o ang',        'mid'], # používá se, když slabika začíná samohláskou
    3630 => ['ḥ',  'h',  'ho nokhuk',    'low']
);



# Samohlásky a slabiky:
# Znak pro souhlásku má v sobě inherentní samohlásku, která se čte v otevřených slabikách "a" a v uzavřených slabikách "o" (jsou nějaké výjimky u slov převzatých z páli).
# Znak sara a (3632) po souhlásce se čte "a", pokud tedy není součástí nějaké složitější kombinace.
# Znak sara aa (3634) po souhlásce se čte "á" (dlouze).
# Znak sara i (3636) se čte "i". Logicky následuje po souhlásce, ale vizuálně jde o diakritiku nad souhláskou.
# Znak sara ii (3637) se čte "í". Logicky následuje po souhlásce, ale vizuálně jde o diakritiku nad souhláskou.
# Znak sara ue (3638) se čte "ü". Logicky následuje po souhlásce, ale vizuálně jde o diakritiku nad souhláskou.
# Znak sara uee (3639) se čte "ű" (dlouze). Logicky následuje po souhlásce, ale vizuálně jde o diakritiku nad souhláskou.
# Znak sara u (3640) se čte "u". Logicky následuje po souhlásce, ale vizuálně jde o diakritiku pod souhláskou.
# Znak sara uu (3641) se čte "ú". Logicky následuje po souhlásce, ale vizuálně jde o diakritiku pod souhláskou.
# Znak sara e (3648) se čte "é". V logické posloupnosti se píše před souhláskou, ale čte se až za ní.
# - Pokud za souhláskou navíc následuje sara a, jde dohromady o reprezentaci krátkého "e".
# Znak sara ae (3649) se čte jako dlouhé "ää" ("ǽ"). V logické posloupnosti se píše před souhláskou, ale čte se až za ní.
# - Pokud za souhláskou navíc následuje sara a, jde dohromady o reprezentaci krátkého "ä" ("æ").
# Znak sara o (3650) se čte jako dlouhé "ó". V logické posloupnosti se píše před souhláskou, ale čte se až za ní.
# - Pokud za souhláskou navíc následuje sara a, jde dohromady o reprezentaci krátkého "o".
# Znak o ang (3629) může být použit i jako samohláska (následuje po souhlásce), pak reprezentuje dlouhé otevřené "ɔɔ" ("ɔː").
# Posloupnost เ◌าะ (sara e – souhláska – sara aa – sara a) reprezentuje krátké otevřené "ɔ".
# Posloupnost เ◌อะ (sara e – souhláska – o ang – sara a) reprezentuje krátké "oe" (IPA prý "ɤʔ" – ɤ je polozavřená zadní nezaokrouhlená samohláska; asi to není daleko od švy).
# Posloupnost เ◌อ (sara e – souhláska – o ang) reprezentuje dlouhé "oe" (IPA "ɤː" nebo "ɤ").



#------------------------------------------------------------------------------
# Uloží do globálního hashe přepisy souhlásek a slabik.
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    # Má se do latinky přidávat nečeská diakritika, aby se neztrácela informace?
    my $bezztrat = 1;
    # Kód začátku segmentu s thajským písmem.
    my $pocatek = 3585;
    my $souhlasky = 3585;
    my $samohlasky = 3632;
    local $tony = 3656;
    my $yo_yak = chr(3618); # vyskytuje se jako souhláska nebo jako součást některých dvojhlásek
    my $wo_waen = chr(3623); # vyskytuje se jako souhláska nebo jako součást některých dvojhlásek
    my $o_ang = chr(3629); # funguje jako ráz před samohláskou nebo jako součást některých samohlásek
    my $sara_a = chr(3632);
    my $maihanakat = chr(3633);
    my $sara_aa = chr(3634);
    my $sara_am = chr(3635);
    my $sara_i = chr(3636);
    my $sara_ii = chr(3637);
    my $sara_uee = chr(3639);
    my $sara_e = chr(3648);
    my $sara_ae = chr(3649);
    my $sara_o = chr(3650);
    my $sara_ai1 = chr(3651); # maimuan
    my $sara_ai2 = chr(3652); # maimalai
    my $maitaikhu = chr(3655); # mai taikhu (ไม้ไต่คู้) = stick that climbs and squats (hůl, která šplhá a dřepuje); vypadá jako malá thajská osmička; zkracuje samohlásky v otevřených slabikách
    my $cislice = 3664;
    my @samohlasky = ('a', 'ạ', 'aː', 'ãː', 'i', 'iː', 'ü', 'üː', 'u', 'uː'); # ã = 'am' = sara am = chr(3635)
    local @tony = ('¹', '²', '³', '⁴');
    local @diatony = (chr(768), chr(770), chr(769), chr(780)); # COMBINING GRAVE ACCENT, CIRCUMFLEX ACCENT, ACUTE ACCENT, CARON
    # Uložit do tabulky samohlásky jako záložní řešení, pokud bychom je někde
    # nedokázali spojit se souhláskami.
    for(my $j = 0; $j <= $#samohlasky; $j++)
    {
        $prevod->{chr($samohlasky+$j)} = $samohlasky[$j];
    }
    # Uložit do tabulky samostatné souhlásky. Zatím se nezabývat inherentními
    # samohláskami. Jednak nevím, jak bychom odlišili případ, kdy je samohláska,
    # která může být inherentní, uvedena explicitně, jednak nevím, jak se odliší
    # souhláska na konci slabiky od souhlásky, která je na začátku slabiky a má
    # inherentní samohlásku.
    for(my $i = 3585; $i <= 3630; $i++)
    {
        my $tsouhlaska = chr($i);
        my $rsouhlaska = $alt{$i}[0];
        $prevod->{$tsouhlaska} = $rsouhlaska;
        # Přidat slabiky začínající touto souhláskou. Nejdřív se samohláskami
        # ze základního bloku, popsaného v poli @samohlasky.
        for(my $j = 0; $j <= $#samohlasky; $j++)
        {
            # Značka tónu se může volitelně objevit mezi souhláskou a samohláskou.
            tonovat($prevod, $tsouhlaska, chr($samohlasky+$j), $rsouhlaska.$samohlasky[$j]);
        }
        # Sara e = 3648.
        tonovat($prevod, $sara_e.$tsouhlaska, '', $rsouhlaska.'eː');
        tonovat($prevod, $sara_e.$tsouhlaska.$sara_a, '', $rsouhlaska.'e');
        $prevod->{$sara_e.$tsouhlaska.$maitaikhu} = $rsouhlaska.'eʔ';
        tonovat($prevod, $sara_e.$tsouhlaska.$sara_i, '', $rsouhlaska.'ei');
        # Sara ae = 3649.
        tonovat($prevod, $sara_ae.$tsouhlaska, '', $rsouhlaska.'æː');
        tonovat($prevod, $sara_ae.$tsouhlaska.$sara_a, '', $rsouhlaska.'æ');
        $prevod->{$sara_ae.$tsouhlaska.$maitaikhu} = $rsouhlaska.'æʔ';
        # Sara o = 3650.
        tonovat($prevod, $sara_o.$tsouhlaska, '', $rsouhlaska.'oː');
        tonovat($prevod, $sara_o.$tsouhlaska.$sara_a, '', $rsouhlaska.'o');
        # Sara ai = 3651 (maimuan) a 3652 (maimalai); nevím, jaký je mezi nimi rozdíl.
        tonovat($prevod, $sara_ai1.$tsouhlaska, '', $rsouhlaska.'ai');
        tonovat($prevod, $sara_ai2.$tsouhlaska, '', $rsouhlaska.'ại');
        # Dvojhlásky.
        # Sara ia (podle RTGS se jak dlouhá, tak krátká přepisuje "ia").
        tonovat($prevod, $sara_e.$tsouhlaska.$sara_ii, $yo_yak, $rsouhlaska.'iaː');
        # Sara uea (podle RTGS se jak dlouhá, tak krátká přepisuje "uea").
        tonovat($prevod, $sara_e.$tsouhlaska.$sara_uee, $o_ang, $rsouhlaska.'üaː');
        # Sara ua (podle RTGS se jak dlouhá, tak krátká přepisuje "ua").
        tonovat($prevod, $tsouhlaska.$maihanakat, $wo_waen, $rsouhlaska.'uaː');
        # Sara ao (podle RTGS se jak dlouhá, tak krátká přepisuje "ao"). Foneticky jde o dvojhlásku, ale podle thajské tradice je krátká verze považována za další samohlásku.
        tonovat($prevod, $sara_e.$tsouhlaska, $sara_aa, $rsouhlaska.'aoː');
        # Další kombinace.
        tonovat($prevod, $tsouhlaska, $o_ang, $rsouhlaska.'ɔː');
        # Pozor! Pokud za souhláskou následuje o ang, neznamená to automaticky, že o ang označuje samohlásku 'ɔː'.
        # Může se stát, že aktuální souhláska je koncovou souhláskou předcházející slabiky a o ang naopak zahajuje novou slabiku.
        # Tuto druhou interpretaci určitě musíme zvolit, když za o ang následuje samohláska, která by jinak zůstala plonková.
        # Příklad, který se vyskytl, je "ผ่านอำนาจ" a měl by zřejmě být přepsán "pʰá¹n'ãnáč".
        for(my $j = 0; $j <= $#samohlasky; $j++)
        {
            # Značka tónu se může volitelně objevit mezi souhláskou a samohláskou.
            tonovat($prevod, $tsouhlaska.$o_ang, chr($samohlasky+$j), $rsouhlaska."'".$samohlasky[$j]);
        }
        tonovat($prevod, $sara_e.$tsouhlaska.$sara_aa.$sara_a, '', $rsouhlaska.'ɔ');
        $prevod->{$tsouhlaska.$maitaikhu.$o_ang} = $rsouhlaska.'ɔ';
        tonovat($prevod, $sara_e.$tsouhlaska.$o_ang, '', $rsouhlaska.'œː');
        tonovat($prevod, $sara_e.$tsouhlaska.$o_ang.$sara_a, '', $rsouhlaska.'œ');
        $prevod->{$sara_e.$tsouhlaska.$maitaikhu} = $rsouhlaska.'e'; ###!!! vyskytuje se následované souhláskou wo waen; tvoří dvojhlásku "ew", podle RTGS přepisovanou "eo"
        $prevod->{$tsouhlaska.$maitaikhu.$o_ang} = $rsouhlaska.'ɔ'; ###!!! vyskytuje se následované souhláskou yo yak; tvoří dvojhlásku "ɔi", podle RTGS přepisovanou "oi"
        # Není jasné, jakou samohlásku by mělo představovat maitaikhu, které není doprovázeno jiným samohláskovým znakem. Vyskytlo se slovo "ก็", googlí výslovnost mi připomíná otevřené "o".
        $prevod->{$tsouhlaska.$maitaikhu} = $rsouhlaska.'ɔʔ';
        # The inherent vowels are /a/ in open syllables (CV) and /o/ in closed syllables (CVC).
        # For example, ถนน transcribes /tʰànǒn/ "road". There are a few exceptions in Pali loanwords, where the inherent vowel of an open syllable is /o/.
        # The circumfix vowels, such as เ–าะ /ɔʔ/, encompass a preceding consonant with an inherent vowel. For example, /pʰɔʔ/ is written เพาะ (SARA E + PHO PHAN + SARA AA + SARA A), and /tɕʰapʰɔʔ/ "only" is written เฉพาะ (SARA E + CHO CHING + PHO PHAN + SARA AA + SARA A).
        ###!!! We currently cannot convert 'เฉพาะ' correctly to 'čʰabʰɔ' because we do not have any consonant clusters covered.
        ###!!! Similarly: ใหม่ (SARA AI MAIMUAN + HO HIP + MO MA + MAI EK) should be 'hmaì' but we currently get 'haim¹'.
        # We cannot recognize inherent vowels in the general case but if a consonant
        # is followed by a tone mark and there are no vowel marks in the vicinity,
        # we have to assume the inherent vowel. It would be pronounced either /a/
        # or /o/ but we transliterate it as 'ə' to prevent confusion with explicit
        # vowels.
        tonovat($prevod, $tsouhlaska, '', $rsouhlaska.'ə');
    }
    # Tones should have been dealt with in the function tonovat(). Just in case
    # a tone mark occurs at a position where we do not expect it, we also provide
    # direct transliteration of the tone marks.
    # https://en.wikipedia.org/wiki/Thai_language#Tones
    # There are five tones. One of them seems to be unmarked and the other tones
    # may be marked by the characters below. However, in practice it is more complicated.
    # The selected consonant character also affects the choice of available tones.
    # The first two tone marks are more likely to occur than the other two, and
    # they may be used to mark a tone which does not correspond to the name of the
    # ; for example, the second mark with a specific consonant indicates the high
    # tone (mai tri).
    # Unmarked tone (สามัญ = saːmạŷ = ordinary): mid tone (33), e.g., คา /kʰāː/ gʰaː
    $prevod->{chr(3656)} = $tony[0]; # THAI CHARACTER MAI EK (= tone one) # low tone (21), e.g., ข่า /kʰàː/ kʰàː
    $prevod->{chr(3657)} = $tony[1]; # THAI CHARACTER MAI THO (= tone two) # falling tone (41), e.g., ค่า /kʰâː/ gʰàː
    $prevod->{chr(3658)} = $tony[2]; # THAI CHARACTER MAI TRI (= tone three) # high tone (45), e.g., ค้า /kʰáː/ gʰâː
    $prevod->{chr(3659)} = $tony[3]; # THAI CHARACTER MAI CHATTAWA (= tone four) # rising tone (214), e.g., ขา /kʰǎː/ kʰaː
    # Další diakritika.
    $prevod->{chr(3660)} = ''; # thanthakhat (meaning "capital punishment") indicates that the previous letter is silent ###!!! we should not convert it to an empty string, it is not reversible
    # Číslice.
    for(my $i = 0; $i<=9; $i++)
    {
        my $src = chr($cislice+$i);
        $prevod->{$src} = $i;
    }
    # Interpunkce a další znaky.
    $prevod->{chr(3631)} = '.'; # paiyannoi se používá u zkratek
    $prevod->{chr(3654)} = ''; # maiyamok udává, že předcházející slovo nebo fráze je reduplikované
    $prevod->{chr(3674)} = ''; # angkhankhu je konec sloky, oddílu, kapitoly
    $prevod->{chr(3675)} = ''; # khomut je konec kapitoly, dokumentu, příběhu
}



#------------------------------------------------------------------------------
# Generates transliterations for syllable without tone mark and for correspon-
# ding syllables with various tone marks. The main problem we solve here is
# that the optional tone mark may occur between two strings that together
# identify a vowel or a diphtong.
#------------------------------------------------------------------------------
sub tonovat
{
    my $prevod = shift; # reference to hash with transliteration table
    my $pred = shift; # characters before optional tone mark
    my $po = shift; # characters after optional tone mark
    my $rbez = shift; # romanization of the syllable without tone mark
    # Add transliteration of toneless syllable.
    # Do not do this with the inherent vowel because there we do not know whether
    # it should be added if we do not see a tone mark.
    $prevod->{$pred.$po} = $rbez unless($rbez =~ m/ə$/);
    # Add transliterations of the syllable with each of the four tone marks.
    my $rdl = $rbez =~ s/ː$// ? 'ː' : '';
    for(my $k = 0; $k <= 3; $k++)
    {
        # There are two options how to transcribe tones. Either as a superscript
        # number (from the local array @tony) or as diacritics (@diatony).
        #$prevod->{$pred.chr($tony+$k).$po} = $rbez.$rdl.$tony[$k];
        #my $r = $rbez.$rdl.$tony[$k];
        my $r = NFC($rbez.$diatony[$k].$rdl);
        $prevod->{$pred.chr($tony+$k).$po} = $r;
        $prevod->{$pred.$po.chr($tony+$k)} = $r;
    }
}



1;
