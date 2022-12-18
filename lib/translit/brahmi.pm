#!/usr/bin/perl
# Funkce pro přípravu transliterace z indického písma do latinky.
# Copyright © 2007, 2008, 2009, 2010, 2022 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL
# 2.8.2009: přidána vědecká transliterace (potřebná pro články, ale nepraktická v terminálu)
# 21.11.2010: přidán přepis do systému WX (jednoznačný přepis používaný v Hajdarábádu, zuboretné t=w, d=x)

package translit::brahmi;
use utf8;



# První sloupec = Danova transliterace (podle české výslovnosti, snaha neztrácet informaci, vyhýbá se odděleným znakům pro diakritiku).
# Druhý sloupec = Vědecká transliterace (mezinárodnější a vhodnější do článků, využívá oddělené znaky pro diakritiku).
# Třetí sloupec = Také vědecká transliterace, ale krátké "e" a "o" se píší bez diakritiky, dlouhé s makronem. Vhodnější pro tamilštinu než pro dévanágarí.
# Čtvrtý sloupec = Transliterace WX (používaná indickými počítačovými lingvisty, prosté zobrazení do oblasti ASCII).
@altlat =
(
    ['m'.chr(771), 'm'.chr(771), 'm'.chr(771), 'z'],  #  0 čandrabindu = m s vlnovkou
    ['ñ',          'ṁ',          'ṁ',          'M'],  #  1 anusvár = n s vlnovkou, resp. m s tečkou nahoře
    ["'",          'ḥ',          'ḥ',          'H'],  #  2 visarg
    ['a',          'a',          'a',          'a'],  #  3
    ['á',          'ā',          'ā',          'A'],  #  4
    ['i',          'i',          'i',          'i'],  #  5
    ['í',          'ī',          'ī',          'I'],  #  6
    ['u',          'u',          'u',          'u'],  #  7
    ['ú',          'ū',          'ū',          'U'],  #  8
    ['ŕ',          'r'.chr(805), 'r'.chr(805), 'q'],  #  9 slabikotvorné r = r s kroužkem dole
    ['ĺ',          'l'.chr(805), 'l'.chr(805), 'Q'],  # 10 slabikotvorné l = l s kroužkem dole ###!!! v malajálamštině nejasné: samostatná pozice (\xD0C, 3340) se jmenuje LETTER VOCALIC L jako v jiných písmech; ale nesamostatná pozice (\xD44, 3396) se jmenuje VOWEL SIGN VOCALIC RR, to bychom přepisovali jinak
    ['ê',          'ê',          'ê',          'eV'], # 11 čandra e
    ['e',          'è',          'e',          'eV'], # 12 krátké e
    ['é',          'e',          'ē',          'e'],  # 13 normální e je polodlouhé nebo dlouhé, ale ne v drávidských jazycích
    ['ai',         'ai',         'ai',         'E'],  # 14 vyslovuje se jako ae, otevřené dlouhé e
    ['ô',          'ô',          'ô',          'OY'], # 15 čandra o
    ['o',          'ò',          'o',          'oV'], # 16 krátké o
    ['ó',          'o',          'ō',          'o'],  # 17 normální o je polodlouhé nebo dlouhé
    ['au',         'au',         'au',         'O'],  # 18 vyslovuje se jako ao, otevřené dlouhé o, jako v anglickém "automatic"
    ['k',          'k',          'k',          'k'],  # 19
    ['kh',         'kh',         'kh',         'K'],  # 20
    ['g',          'g',          'g',          'g'],  # 21
    ['gh',         'gh',         'gh',         'G'],  # 22
    ['ŋ',          'ṅ',          'ṅ',          'f'],  # 23 ng
    ['č',          'c',          'c',          'c'],  # 24
    ['čh',         'ch',         'ch',         'C'],  # 25
    ['dž',         'j',          'j',          'j'],  # 26
    ['džh',        'jh',         'jh',         'J'],  # 27
    ['ň',          'ñ',          'ñ',          'F'],  # 28
    ['ţ',          'ṭ',          'ṭ',          't'],  # 29 retroflexní t
    ['ţh',         'ṭh',         'ṭh',         'T'],  # 30
    ['đ',          'ḍ',          'ḍ',          'd'],  # 31
    ['đh',         'ḍh',         'ḍh',         'D'],  # 32
    ['ņ',          'ṇ',          'ṇ',          'N'],  # 33
    ['t',          't',          't',          'w'],  # 34 zubové t
    ['th',         'th',         'th',         'W'],  # 35
    ['d',          'd',          'd',          'x'],  # 36
    ['dh',         'dh',         'dh',         'X'],  # 37
    ['n',          'n',          'n',          'n'],  # 38
    ['ŉ',          'n',          'n',          'n'],  # 39 "NNNA", specifické pro tamilštinu
    ['p',          'p',          'p',          'p'],  # 40
    ['ph',         'ph',         'ph',         'P'],  # 41
    ['b',          'b',          'b',          'b'],  # 42
    ['bh',         'bh',         'bh',         'B'],  # 43
    ['m',          'm',          'm',          'm'],  # 44
    ['j',          'y',          'y',          'y'],  # 45
    ['r',          'r',          'r',          'r'],  # 46
    ['ŗ',          'ṟ',          'ṟ',          'r'],  # 47 tvrdé R z jižních jazyků
    ['l',          'l',          'l',          'l'],  # 48
    ['ļ',          'ḷ',          'ḷ',          'lY'], # 49 tvrdé (retroflexní?) L (maráthština)
    ['ř',          'ḻ',          'ḻ',          'l'],  # 50 něco mezi L, americkým R a Ž nebo Ř (tamilština, malajálamština)
    ['v',          'v',          'v',          'v'],  # 51
    ['ś',          'ś',          'ś',          'S'],  # 52 normální š
    ['š',          'ṣ',          'ṣ',          'R'],  # 53 retroflexní š ze sanskrtu, v hindštině se vyslovuje stejně jako normální š
    ['s',          's',          's',          's'],  # 54
    ['h',          'h',          'h',          'h'],  # 55
    ['q',          'q',          'q',          'kZ'], # 56
    ['ch',         'x',          'x',          'KZ'], # 57
    ['ğ',          'ğ',          'ğ',          'gZ'], # 58 hrdelní gh z arabštiny
    ['z',          'z',          'z',          'jZ'], # 59
    ['ŗ',          'ṛ',          'ṛ',          'dZ'], # 60 DDDHA = DDA + NUKTA
    ['ŗh',         'ṛh',         'ṛh',         'DZ'], # 61 RHA = DDHA + NUKTA
    ['f',          'f',          'f',          'PZ'], # 62
    ['ĵ',          'ŷ',          'ŷ',          'yZ'], # 63 YYA = YA + NUKTA (zřejmě odpovídá JYA z ISCII (bengálština, ásámština a urijština), výslovnost snad něco mezi j a ď, můj přepis je "j", resp. vědecky "y" se stříškou)
    ['ŕ',          'r'.chr(772).chr(805), 'r'.chr(772).chr(805), 'q'], # 64 VOCALIC RR
    ['ĺ',          'l'.chr(772).chr(805), 'l'.chr(772).chr(805), 'Q'], # 65 VOCALIC LL
    ['óm',         'om',         'ōm',         'om'], # 66 posvátná slabika z modliteb
    ['r',          'r',          'r',          'r'],  # 67 ásámské R je v bengálském písmu až za číslicemi
    ['w',          'w',          'w',          'w'],  # 68 ásámské W je v bengálském písmu až za číslicemi
    # Písmeno chillu představuje souhlásku bez inherentní samohlásky a dělá to bez pomoci virámu (malajálamsky zvaného candrakkala).
    # Pokud malajálamské slovo končí souhláskou s virámem, často se ve skutečnosti vyslovuje s velmi krátkou středovou zavřenou samohláskou -ŭ.
    # Pokud chceme vyjádřit, že ve skutečnosti není vyslovena ani tato krátká samohláska, místo souhlásky s virámem použijeme souhlásku chillu.
    # Problém je, že v transliteraci tyto souhlásky těžko odlišíme. To bychom se museli ještě více odchýlit od přepisu ostatních indických písem
    # a všechny virámy v malajálamštině přepisovat jako ŭ. Nebo aspoň ty na konci slova a ty, za kterými je ZERO WIDTH NON-JOINER (\x200C).
    # Zkusíme místo toho alespoň ve vědeckém přepisu přidat COMBINING COMMA ABOVE RIGHT.
    ['m',          'm'.chr(789), 'm'.chr(789), 'm'],  # 69 malajálamské CHILLU M
    ['j',          'y'.chr(789), 'y'.chr(789), 'y'],  # 70 malajálamské CHILLU Y
    ['ř',          'ḻ'.chr(789), 'ḻ'.chr(789), 'l'],  # 71 malajálamské CHILLU LLL (něco mezi L, americkým R a Ž nebo Ř)
    ['ņ',          'ṇ'.chr(789), 'ṇ'.chr(789), 'N'],  # 72 malajálamské CHILLU NN
    ['n',          'n'.chr(789), 'n'.chr(789), 'n'],  # 73 malajálamské CHILLU N
    ['ŗ',          'ṟ'.chr(789), 'ṟ'.chr(789), 'r'],  # 74 malajálamské CHILLU RR (tvrdé R z jižních jazyků)
    ['l',          'l'.chr(789), 'l'.chr(789), 'l'],  # 75 malajálamské CHILLU L
    ['ļ',          'ḷ'.chr(789), 'ḷ'.chr(789), 'lY'], # 76 malajálamské CHILLU LL (tvrdé (retroflexní?) L)
    ['k',          'k'.chr(789), 'k'.chr(789), 'k'],  # 77 malajálamské CHILLU K
    ['ŕ',          'r'.chr(804), 'r'.chr(804), 'q'],  # 78 slabikotvorné RR = r s přehláskou dole
    ['ĺ',          'l'.chr(804), 'l'.chr(804), 'Q'],  # 79 slabikotvorné LL = l s přehláskou dole
);



#------------------------------------------------------------------------------
# Uloží do hashe přepisy souhlásek a slabik. Odkaz na cílový hash převezme jako
# parametr. Vrátí délku nejdelšího řetězce, jehož přepis je v hashi definován.
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    # Kód začátku segmentu s daným písmem (o 1 nižší než kód znaku čandrabindu).
    my $pocatek = shift;
    # Volba alternativní sady výstupních znaků.
    my $alt = shift;
    local $maxl = 1;
    my $candrabindu = $pocatek+1;
    my $anusvara = $pocatek+2;
    my $visarga = $pocatek+3;
    my $samohlasky = $pocatek+5;
    my $souhlasky = $pocatek==3456 ? $pocatek+26 : $pocatek+21;
    my $nukta = $pocatek==3456 ? undef : $pocatek+60;
    my $avagraha = $pocatek==3456 ? undef : $pocatek+61;
    my $diasamohlasky = $pocatek==3456 ? $pocatek+79 : $pocatek+62;
    my $virama = $pocatek==3456 ? 3530 : $pocatek+77;
    my $om = $pocatek==3456 ? undef : $pocatek+80;
    my $souhlasky2 = $pocatek+88;
    my $danda = $pocatek+100;
    my $ddanda = $pocatek+101;
    my $cislice = $pocatek+102;
    my $asamr = $pocatek+112;
    my $asamw = $pocatek+113;
    my $tippi = $pocatek+112;
    my $addak = $pocatek+113;
    # Má se do latinky přidávat nečeská diakritika, aby se neztrácela informace?
    my $bezztrat = 1;
    # Zvolit výstupní sadu latinských písmen.
    my @lat = map {$_->[$alt]} @altlat;
    my $latcandrabindu = $lat[0];
    my $latanusvara = $lat[1];
    my $latvisarga = $lat[2];
    my @samohlasky = @lat[3..18];
    my @diasamohlasky = @lat[4..18];
    my @souhlasky = @lat[19..55];
    my @souhlasky2 = @lat[56..63];
    # Přídavné samohlásky a souhlásky pro sinhálštinu.
    ###!!! Výhledově by se tohle mělo řešit nějak systematičtěji, přinejmenším pokud jde o různé varianty přepisu do latinky.
    if($pocatek==3456)
    {
        @samohlasky = (@lat[3..4], 'æ', 'ǣ', @lat[5..8], 'ru', 'rū', 'lu', 'lū', 'e', 'ē', 'ai', 'o', 'ō', 'au'); # r̥, r̥̄, l̥, l̥̄
        @diasamohlasky = ($lat[4], 'æ', 'ǣ', @lat[5..8], 'ru', 'rū', 'lu', 'e', 'ē', 'ai', 'o', 'ō', 'au', 'û'); # nejsem si jist, čemu odpovídá ta poslední samohláska, gayanukitta, ale vypadá jako pravá půlka té předposlední
        @souhlasky = (@lat[19..23], 'ňg', @lat[24..28], 'jň', 'ňj', @lat[29..33], 'ňḍ', @lat[34..39], 'ňd', @lat[40..44], 'm̌b', @lat[45..55], 'ḷ', 'f');
    }
    # Samostatné samohlásky.
    for(my $i = 0; $i<=$#samohlasky; $i++)
    {
        my $src = chr($samohlasky+$i);
        pridat($prevod, $src, $samohlasky[$i]);
    }
    # Sestavit převodní tabulku všech souhlásek.
    # Vyrobíme dvě pole. Prvek prvního pole je indická souhláska, prvek druhého je její latinský protějšek.
    # Na obou stranách mohou být řetězce znaků, nemusí to být jen jeden znak.
    # Základní sada souhlásek, které se v indických písmech vyskytují.
    my @indicke_souhlasky = map {chr($_)} ($souhlasky..$souhlasky+$#souhlasky);
    my @latinske_souhlasky = @souhlasky;
    # Znaky s nuktou (tečkou) pro souhlásky, které se objevily dodatečně.
    push(@indicke_souhlasky, map {chr($_)} ($souhlasky2..$souhlasky2+$#souhlasky2));
    push(@latinske_souhlasky, @souhlasky2);
    # Tytéž znaky s nuktou se mohou objevit také jako řetězec dvou znaků: bázový znak ze základní sady + znak nukty.
    push(@indicke_souhlasky, chr($pocatek+2325-2304).chr($nukta)); # QA = KA + NUKTA
    push(@indicke_souhlasky, chr($pocatek+2326-2304).chr($nukta)); # KHHA = KHA + NUKTA
    push(@indicke_souhlasky, chr($pocatek+2327-2304).chr($nukta)); # GHHA = GA + NUKTA
    push(@indicke_souhlasky, chr($pocatek+2332-2304).chr($nukta)); # ZA = JA + NUKTA
    push(@indicke_souhlasky, chr($pocatek+2337-2304).chr($nukta)); # DDDHA = DDA + NUKTA
    push(@indicke_souhlasky, chr($pocatek+2338-2304).chr($nukta)); # RHA = DDHA + NUKTA
    push(@indicke_souhlasky, chr($pocatek+2347-2304).chr($nukta)); # FA = PHA + NUKTA
    push(@indicke_souhlasky, chr($pocatek+2351-2304).chr($nukta)); # YYA = YA + NUKTA
    push(@latinske_souhlasky, @souhlasky2);
    # Ásámská varianta bengálského písma: r, w
    # Gurmukhí má na stejných pozicích (až za číslicemi) jiné znaky, takže musíme zkontrolovat počátek.
    if($pocatek==2432)
    {
        push(@indicke_souhlasky, chr($pocatek+2544-2432)); # RA WITH MIDDLE DIAGONAL
        push(@indicke_souhlasky, chr($pocatek+2545-2432)); # RA WITH LOWER DIAGONAL
        push(@latinske_souhlasky, $lat[67]);
        push(@latinske_souhlasky, $lat[68]);
    }
    # Gurmukhí: s + nukta = š
    push(@indicke_souhlasky, chr($pocatek+2616-2560).chr($nukta)); # SA + NUKTA
    push(@latinske_souhlasky, 'š');
    ###!!! KONTROLA
#    die unless($#indicke_souhlasky==$#latinske_souhlasky);
    # Gurmukhí: znaménko addak zdvojuje následující souhlásku (přestože jako diakritika se připojuje k té předcházející).
    my $n = scalar(@indicke_souhlasky);
    for(my $i = 0; $i<$n; $i++)
    {
        push(@indicke_souhlasky, chr($addak).$indicke_souhlasky[$i]);
        push(@latinske_souhlasky, $latinske_souhlasky[$i].$latinske_souhlasky[$i]);
    }
    # Souhlásky implicitně obsahují samohlásku "a".
    # Pokud má slabika obsahovat jinou samohlásku, musí za znakem pro souhlásku následovat diakritické znaménko samohlásky.
    for(my $i = 0; $i<=$#indicke_souhlasky; $i++)
    {
        my $src = $indicke_souhlasky[$i];
        my $tgt = $latinske_souhlasky[$i];
        pridat_slabiky($prevod, $src, $tgt, $diasamohlasky, \@diasamohlasky, $virama);
        # "MALAYALAM AU LENGTH MARK" jsem viděl v přepisu anglického "Brown" ("braun").
        # Využilo se inherentního "a" v "ra", za něj se připojilo tohle.
        # Není mi jasné, čím se využití tohoto znaku liší od plnohodnotného
        # VOWEL SIGN AU.
        if($pocatek==3328) # malajálam
        {
            pridat_slabiky($prevod, $src, $tgt, 3415, ['au'], $virama); ###!!! kombinace s virámem tady přidáváme podruhé zbytečně, v tabulce už jsou
        }
    }
    # Anusvara způsobuje, že předcházející samohláska je nosová.
    # Anusvára se na konci vyslovuje m, jinde n, ň nebo m podle následující souhlásky.
    # Znaménko candrabindu rovněž nazalizuje předcházející samohlásku.
    pridat($prevod, chr($candrabindu), $latcandrabindu);
    pridat($prevod, chr($anusvara), $latanusvara);
    # Visarga přidává neznělý dech za samohláskou.
    pridat($prevod, chr($visarga), $latvisarga);
    # Avagraha může nahrazovat vynechané hlásky na spoji sandhi, ale také může označovat prodlouženou slabiku ("cooool") aj.
    pridat($prevod, chr($avagraha), '’');
    # Interpunkce: danda ukončuje větu. Dvojitá danda se používá zřídka, např. v básních ukončuje dvojverší nebo sloku, zatímco danda ukončuje verš uvnitř sloky.
    pridat($prevod, chr($danda), '.');
    pridat($prevod, chr($ddanda), ':');
    # Číslice.
    for(my $i = 0; $i<=9; $i++)
    {
        my $src = chr($cislice+$i);
        pridat($prevod, $src, $i);
    }
    # Další znaky.
    pridat($prevod, chr($om), $lat[66]);
    # Za číslicemi mohou být další znaky, které jsou důležité v některých jazycích daného písma, ale neodpovídají stejné pozici v jiných písmech.
    # $pocatek:
    # 0x900 = 2304: Devanagari script (Hindi etc.)
    # 0x980 = 2432: Bengali script (also Assamese)
    # 0xA00 = 2560: Gurmukhi script (for Punjabi)
    # 0xA80 = 2688: Gujarati script
    # 0xB00 = 2816: Oriya script
    # 0xB80 = 2944: Tamil script
    # 0xC00 = 3072: Telugu script
    # 0xC80 = 3200: Kannada script
    # 0xD00 = 3328: Malayalam script
    if($pocatek==2560) # gurmukhí
    {
        # Znaménko tippi v písmu gurmukhí označuje nazalizaci stejně jako bindí (anusvár).
        pridat($prevod, chr($tippi), $latanusvara);
    }
    if($pocatek==3328) # malajálam
    {
        # Některá písmena mají variantu zvanou "chillu". Předpokládám, že jde
        # o souhlásku na konci slabiky, tj. bez inherentní samohlásky.
        for(my $i = 3412; $i <= 3414; $i++) # M, Y, LLL
        {
            pridat($prevod, chr($i), $lat[69+$i-3412]);
        }
        for(my $i = 3450; $i <= 3455; $i++) # NN, N, RR, L, LL, K
        {
            pridat($prevod, chr($i), $lat[72+$i-3450]);
        }
        # Slabikotvorné (vocalic) RR a LL jako samostatné znaky se nacházejí
        # těsně před číslicemi, jinde než ostatní samohlásky.
        for(my $i = 3424; $i <= 3425; $i++) # VOCALIC RR, VOCALIC LL
        {
            pridat($prevod, chr($i), $lat[78+$i-3424]);
        }
    }
    return $maxl;
}



#------------------------------------------------------------------------------
# Přidá do převodní tabulky kombinace dané souhlásky se všemi samohláskami.
#------------------------------------------------------------------------------
sub pridat_slabiky
{
    my $prevod = shift; # odkaz na převodní tabulku (hash)
    my $src = shift; # řetězec obsahující počáteční souhlásku slabiky v daném indickém písmu
    my $tgt = shift; # řetězec obsahující přepis této souhlásky do latinky
    my $srcsam = shift; # kód první nesamostatné samohlásky v daném indickém písmu
    my $tgtsam = shift; # odkaz na pole přepisů nesamostatných samohlásek do latinky
    my $virama = shift; # kód znaku virám v daném indickém písmu
    # local $maxl seshora
    pridat($prevod, $src, $tgt.'a');
    # Znaménko virám likviduje implicitní samohlásku "a".
    my $src2 = chr($virama);
    pridat($prevod, $src.$src2, $tgt);
    for(my $j = 0; $j<=$#{$tgtsam}; $j++)
    {
        my $src2 = chr($srcsam+$j);
        pridat($prevod, $src.$src2, $tgt.$tgtsam->[$j]);
    }
}



#------------------------------------------------------------------------------
# Přidá do převodní tabulky zdrojový a cílový řetězec. Navíc aktualizuje
# hodnotu maxl (která je deklarovaná jako local v hlavní funkci).
#------------------------------------------------------------------------------
sub pridat
{
    my $prevod = shift; # odkaz na převodní tabulku (hash)
    my $src = shift; # řetězec ve zdrojovém písmu
    my $tgt = shift; # řetězec v cílovém písmu (latince)
    # local $maxl
    $prevod->{$src} = $tgt;
    my $l = length($src);
    $maxl = $l if($l>$maxl);
    return $maxl;
}



1;
