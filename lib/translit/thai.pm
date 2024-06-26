#!/usr/bin/perl
# Funkce pro přípravu transliterace z thajského písma do latinky.
# Copyright © 2022 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::thai;
use utf8;



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
    my $sara_ii = chr(3637);
    my $sara_uee = chr(3639);
    my $sara_e = chr(3648);
    my $sara_ae = chr(3649);
    my $sara_o = chr(3650);
    my $sara_ai1 = chr(3651); # maimuan
    my $sara_ai2 = chr(3652); # maimalai
    my $maitaikhu = chr(3655); # mai taikhu = stick that climbs and squats (hůl, která šplhá a dřepuje); vypadá jako malá thajská osmička; zkracuje samohlásky
    my $cislice = 3664;
    my @samohlasky = ('a', 'â', 'á', 'ã', 'i', 'í', 'ü', 'ű', 'u', 'ú'); # ã = 'am' = sara am = chr(3635)
    local @tony = ('¹', '²', '³', '⁴');
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
        # Přidat slabiky začínající touto souhláskou.
        for(my $j = 0; $j <= $#samohlasky; $j++)
        {
            # Značka tónu se může volitelně objevit mezi souhláskou a samohláskou.
            tonovat($prevod, $tsouhlaska, chr($samohlasky+$j), $rsouhlaska.$samohlasky[$j]);
        }
        # Sara e = 3648.
        $prevod->{$sara_e.$tsouhlaska} = $rsouhlaska.'é';
        $prevod->{$sara_e.$tsouhlaska.$sara_a} = $rsouhlaska.'e';
        $prevod->{$sara_e.$tsouhlaska.$maitaikhu} = $rsouhlaska.'e';
        # Sara ae = 3649.
        $prevod->{$sara_ae.$tsouhlaska} = $rsouhlaska.'ǽ';
        $prevod->{$sara_ae.$tsouhlaska.$sara_a} = $rsouhlaska.'æ';
        $prevod->{$sara_ae.$tsouhlaska.$maitaikhu} = $rsouhlaska.'æ';
        # Sara o = 3650.
        $prevod->{$sara_o.$tsouhlaska} = $rsouhlaska.'ó';
        $prevod->{$sara_o.$tsouhlaska.$sara_a} = $rsouhlaska.'o';
        # Sara ai = 3651 (maimuan) a 3652 (maimalai); nevím, jaký je mezi nimi rozdíl.
        $prevod->{$sara_ai1.$tsouhlaska} = $rsouhlaska.'ai';
        $prevod->{$sara_ai2.$tsouhlaska} = $rsouhlaska.'ai';
        # Dvojhlásky.
        # Sara ia (podle RTGS se jak dlouhá, tak krátká přepisuje "ia").
        tonovat($prevod, $sara_e.$tsouhlaska.$sara_ii, $yo_yak, $rsouhlaska.'íá');
        # Sara uea (podle RTGS se jak dlouhá, tak krátká přepisuje "uea").
        tonovat($prevod, $sara_e.$tsouhlaska.$sara_uee, $o_ang, $rsouhlaska.'űá');
        # Sara ua (podle RTGS se jak dlouhá, tak krátká přepisuje "ua").
        tonovat($prevod, $tsouhlaska.$maihanakat, $wo_waen, $rsouhlaska.'úá');
        # Sara ao (podle RTGS se jak dlouhá, tak krátká přepisuje "ao"). Foneticky jde o dvojhlásku, ale podle thajské tradice je krátká verze považována za další samohlásku.
        tonovat($prevod, $sara_e.$tsouhlaska, $sara_aa, $rsouhlaska.'ao');
        # Další kombinace.
        $prevod->{$tsouhlaska.$o_ang} = $rsouhlaska.'ɔː'; ###!!! Zatím nekonzistentní označování délky samohlásky, ale u otevřeného o bych musel použít combining acute accent.
        # Pozor! Pokud za souhláskou následuje o ang, neznamená to automaticky, že o ang označuje samohlásku 'ɔː'.
        # Může se stát, že aktuální souhláska je koncovou souhláskou předcházející slabiky a o ang naopak zahajuje novou slabiku.
        # Tuto druhou interpretaci určitě musíme zvolit, když za o ang následuje samohláska, která by jinak zůstala plonková.
        # Příklad, který se vyskytl, je "ผ่านอำนาจ" a měl by zřejmě být přepsán "pʰá¹n'ãnáč".
        for(my $j = 0; $j <= $#samohlasky; $j++)
        {
            # Značka tónu se může volitelně objevit mezi souhláskou a samohláskou.
            tonovat($prevod, $tsouhlaska.$o_ang, chr($samohlasky+$j), $rsouhlaska."'".$samohlasky[$j]);
        }
        $prevod->{$sara_e.$tsouhlaska.$sara_aa.$sara_a} = $rsouhlaska.'ɔ';
        $prevod->{$tsouhlaska.$maitaikhu.$o_ang} = $rsouhlaska.'ɔ';
        $prevod->{$sara_e.$tsouhlaska.$o_ang} = $rsouhlaska.'óé';
        $prevod->{$sara_e.$tsouhlaska.$o_ang.$sara_a} = $rsouhlaska.'oe';
        $prevod->{$sara_e.$tsouhlaska.$maitaikhu} = $rsouhlaska.'e'; ###!!! vyskytuje se následované souhláskou wo waen; tvoří dvojhlásku "ew", podle RTGS přepisovanou "eo"
        $prevod->{$tsouhlaska.$maitaikhu.$o_ang} = $rsouhlaska.'ɔ'; ###!!! vyskytuje se následované souhláskou yo yak; tvoří dvojhlásku "ɔi", podle RTGS přepisovanou "oi"
        # Není jasné, jakou samohlásku by mělo představovat maitaikhu, které není doprovázeno jiným samohláskovým znakem. Vyskytlo se slovo "ก็", googlí výslovnost mi připomíná otevřené "o".
        $prevod->{$tsouhlaska.$maitaikhu} = $rsouhlaska.'ɔ';
        # The inherent vowels are /a/ in open syllables (CV) and /o/ in closed syllables (CVC).
        # For example, ถนน transcribes /tʰànǒn/ "road". There are a few exceptions in Pali loanwords, where the inherent vowel of an open syllable is /o/.
        # The circumfix vowels, such as เ–าะ /ɔʔ/, encompass a preceding consonant with an inherent vowel. For example, /pʰɔʔ/ is written เพาะ, and /tɕʰapʰɔʔ/ "only" is written เฉพาะ
        ###!!! We currently cannot convert 'เฉพาะ' correctly to 'čʰabʰɔ' because we do not have any consonant clusters covered.
    }
    # Tóny.
    $prevod->{chr(3656)} = $tony[0];
    $prevod->{chr(3657)} = $tony[1];
    $prevod->{chr(3658)} = $tony[2];
    $prevod->{chr(3659)} = $tony[3];
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
# Vygeneruje převody pro slabiku bez tónové značky a pro odpovídající slabiky
# s různými tónovými značkami. Hlavní problém, který zde řešíme, tkví v tom,
# že volitelná tónová značka může rozdělovat sekvenci znaků, které identifikují
# samohlásku nebo dvojhlásku.
#------------------------------------------------------------------------------
sub tonovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    my $pred = shift; # znaky před případnou tónovou značkou
    my $po = shift; # znaky po případné tónové značce
    my $rbez = shift; # romanizace slabiky bez tónové značky
    $prevod->{$pred.$po} = $rbez;
    for(my $k = 0; $k <= 3; $k++)
    {
        $prevod->{$pred.chr($tony+$k).$po} = $rbez.$tony[$k];
    }
}



1;
