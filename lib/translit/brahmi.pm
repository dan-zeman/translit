#!/usr/bin/perl
# Funkce pro přípravu transliterace z indického písma do latinky.
# Copyright © 2007, 2008, 2009, 2010 Dan Zeman <zeman@ufal.mff.cuni.cz>
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
    ['m'.chr(771), 'm'.chr(771), 'm'.chr(771), 'z'], # čandrabindu = m s vlnovkou
    ['ñ',          'ṁ',          'ṁ',          'M'], # anusvár = n s vlnovkou, resp. m s tečkou nahoře
    ["'",          'ḥ',          'ḥ',          'H'], # visarg
    ['a',          'a',          'a',          'a'],
    ['á',          'ā',          'ā',          'A'],
    ['i',          'i',          'i',          'i'],
    ['í',          'ī',          'ī',          'I'],
    ['u',          'u',          'u',          'u'],
    ['ú',          'ū',          'ū',          'U'],
    ['ŕ',          'r'.chr(805), 'r'.chr(805), 'q'], # slabikotvorné r = r s kroužkem dole
    ['ĺ',          'l'.chr(805), 'l'.chr(805), 'Q'], # slabikotvorné l = l s kroužkem dole
    ['ê',          'ê',          'ê',          'eV'], # čandra e
    ['e',          'è',          'e',          'eV'], # krátké e
    ['é',          'e',          'ē',          'e'],  # normální e je polodlouhé nebo dlouhé, ale ne v drávidských jazycích
    ['ai',         'ai',         'ai',         'E'],  # vyslovuje se jako ae, otevřené dlouhé e
    ['ô',          'ô',          'ô',          'OY'], # čandra o
    ['o',          'ò',          'o',          'oV'], # krátké o
    ['ó',          'o',          'ō',          'o'],  # normální o je polodlouhé nebo dlouhé
    ['au',         'au',         'au',         'O'],  # vyslovuje se jako ao, otevřené dlouhé o, jako v anglickém "automatic"
    ['k',          'k',          'k',          'k'],
    ['kh',         'kh',         'kh',         'K'],
    ['g',          'g',          'g',          'g'],
    ['gh',         'gh',         'gh',         'G'],
    ['ŋ',          'ṅ',          'ṅ',          'f'], # ng
    ['č',          'c',          'c',          'c'],
    ['čh',         'ch',         'ch',         'C'],
    ['dž',         'j',          'j',          'j'],
    ['džh',        'jh',         'jh',         'J'],
    ['ň',          'ñ',          'ñ',          'F'],
    ['ţ',          'ṭ',          'ṭ',          't'], # retroflexní t
    ['ţh',         'ṭh',         'ṭh',         'T'],
    ['đ',          'ḍ',          'ḍ',          'd'],
    ['đh',         'ḍh',         'ḍh',         'D'],
    ['ņ',          'ṇ',          'ṇ',          'N'],
    ['t',          't',          't',          'w'], # zubové t
    ['th',         'th',         'th',         'W'],
    ['d',          'd',          'd',          'x'],
    ['dh',         'dh',         'dh',         'X'],
    ['n',          'n',          'n',          'n'],
    ['ŉ',          'n',          'n',          'n'], # "NNNA", specifické pro tamilštinu
    ['p',          'p',          'p',          'p'],
    ['ph',         'ph',         'ph',         'P'],
    ['b',          'b',          'b',          'b'],
    ['bh',         'bh',         'bh',         'B'],
    ['m',          'm',          'm',          'm'],
    ['j',          'y',          'y',          'y'],
    ['r',          'r',          'r',          'r'],
    ['ŗ',          'r',          'r',          'r'], # tvrdé R z jižních jazyků
    ['l',          'l',          'l',          'l'],
    ['ļ',          'ḷ',          'ḷ',          'lY'], # tvrdé (retroflexní?) L (maráthština)
    ['ř',          'l',          'l',          'l'], # něco mezi L, americkým R a Ž nebo Ř (tamilština, malajálamština)
    ['v',          'v',          'v',          'v'],
    ['ś',          'ś',          'ś',          'S'], # normální š
    ['š',          'ṣ',          'ṣ',          'R'], # retroflexní š ze sanskrtu, v hindštině se vyslovuje stejně jako normální š
    ['s',          's',          's',          's'],
    ['h',          'h',          'h',          'h'],
    ['q',          'q',          'q',          'kZ'],
    ['ch',         'x',          'x',          'KZ'],
    ['ğ',          'ğ',          'ğ',          'gZ'], # hrdelní gh z arabštiny
    ['z',          'z',          'z',          'jZ'],
    ['ŗ',          'ṛ',          'ṛ',          'dZ'], # DDDHA = DDA + NUKTA
    ['ŗh',         'ṛh',         'ṛh',         'DZ'], # RHA = DDHA + NUKTA
    ['f',          'f',          'f',          'PZ'],
    ['ĵ',          'ŷ',          'ŷ',          'yZ'], # YYA = YA + NUKTA (zřejmě odpovídá JYA z ISCII (bengálština, ásámština a urijština), výslovnost snad něco mezi j a ď, můj přepis je "j", resp. vědecky "y" se stříškou)
    ['ŕ',          'r'.chr(772).chr(805), 'r'.chr(772).chr(805), 'q'], # VOCALIC RR
    ['ĺ',          'l'.chr(772).chr(805), 'l'.chr(772).chr(805), 'Q'], # VOCALIC LL
    ['óm',         'om',         'ōm',         'om'], # posvátná slabika z modliteb
    ['r',          'r',          'r',          'r'], # ásámské R je v bengálském písmu až za číslicemi
    ['w',          'w',          'w',          'w'], # ásámské W je v bengálském písmu až za číslicemi
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
    my $souhlasky = $pocatek+21;
    my $nukta = $pocatek+60;
    my $avagraha = $pocatek+61;
    my $diasamohlasky = $pocatek+62;
    my $virama = $pocatek+77;
    my $om = $pocatek+80;
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
    # Samostatné samohlásky.
    for(my $i = 0; $i<=$#samohlasky; $i++)
    {
        my $src = chr($samohlasky+$i);
        $prevod->{$src} = $samohlasky[$i];
        $maxl = length($src) if(length($src)>$maxl);
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
    }
    # Anusvara způsobuje, že předcházející samohláska je nosová.
    # Anusvára se na konci vyslovuje m, jinde n, ň nebo m podle následující souhlásky.
    # Znaménko candrabindu rovněž nazalizuje předcházející samohlásku.
    $prevod->{chr($candrabindu)} = $latcandrabindu;
    $prevod->{chr($anusvara)} = $latanusvara;
    # Visarga přidává neznělý dech za samohláskou.
    $prevod->{chr($visarga)} = $latvisarga;
    # Avagraha může nahrazovat vynechané hlásky na spoji sandhi, ale také může označovat prodlouženou slabiku ("cooool") aj.
    $prevod->{chr($avagraha)} = '’';
    # Interpunkce: danda ukončuje větu. Dvojitá danda se používá zřídka, např. v básních ukončuje dvojverší nebo sloku, zatímco danda ukončuje verš uvnitř sloky.
    $prevod->{chr($danda)} = '.';
    $prevod->{chr($ddanda)} = ':';
    # Číslice.
    for(my $i = 0; $i<=9; $i++)
    {
        my $src = chr($cislice+$i);
        $prevod->{$src} = $i;
        $maxl = length($src) if(length($src)>$maxl);
    }
    # Další znaky.
    $prevod->{chr($om)} = $lat[66];
    # Za číslicemi mohou být další znaky, které jsou důležité v některých jazycích daného písma, ale neodpovídají stejné pozici v jiných písmech.
    # $pocatek:
    # 0x900 = 2304: Devanagari script (Hindi etc.)
    # 0x980 = 2432: Bengali script. (also Assamese)
    # 0xA00 = 2560: Gurmukhi script (for Punjabi).
    # 0xA80 = 2688: Gujarati script.
    # 0xB00 = 2816: Oriya script.
    # 0xB80 = 2944: Tamil script.
    # 0xC00 = 3072: Telugu script.
    # 0xC80 = 3200: Kannada script.
    # 0xD00 = 3328: Malayalam script.
    if($pocatek>=2560) # gurmukhí a výše
    {
        # Znaménko tippi v písmu gurmukhí označuje nazalizaci stejně jako bindí (anusvár).
        $prevod->{chr($tippi)} = $latanusvara;
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
    $prevod->{$src} = $tgt.'a';
    $maxl = length($src) if(length($src)>$maxl);
    # Znaménko virám likviduje implicitní samohlásku "a".
    my $src2 = chr($virama);
    $prevod->{$src.$src2} = $tgt;
    $maxl = length($src.$src2) if(length($src.$src2)>$maxl);
    for(my $j = 0; $j<=$#{$tgtsam}; $j++)
    {
        my $src2 = chr($srcsam+$j);
        $prevod->{$src.$src2} = $tgt.$tgtsam->[$j];
        $maxl = length($src.$src2) if(length($src.$src2)>$maxl);
    }
}



1;
