#!/usr/bin/perl
# Funkce pro přípravu transliterace z arabského písma do latinky.
# Obsahuje i perská písmena, ale při výběru latinských ekvivalentů primárně předpokládá arabský vstup.
# Pro urdštinu je nekompletní (chybí retroflexní souhlásky).
# Copyright © 2008 – 2013 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::arab;
use utf8;



#------------------------------------------------------------------------------
# Problematické hlásky nabízejí několik možných přepisů.
# Vysvětlivky:
# - český = Preferuje se zápis výslovnosti podle češtiny. To neznamená, že
#   přepis dobře modeluje výslovnost (ani v mezích možností české abecedy).
#   Ke správnému zápisu výslovnosti by bylo potřeba znát pravidla pravopisu
#   zdrojového jazyka, která mohou být někdy velmi složitá.
# - anglický = Preferuje se zápis výslovnosti podle angličtiny. To neznamená,
#   že přepis dobře modeluje výslovnost (viz stejná poznámka u českého).
# - bezztrátový = Přepis se snaží odlišit zdrojové znaky tak, aby bylo možné
#   rekonstruovat původní pravopis. "Český", resp. "anglický" přepis tak musí
#   být rozšířen o diakritická znaménka, psaní velkých písmen místo malých aj.
# - putty = Bezztrátový přepis, který se ale vyhýbá využití některých
#   prostředků, které nejsou vidět v terminálu Putty (a asi ani jinde, kde se
#   používá neproporcionální písmo). Jde zejména o znaky třídy "combining", tj.
#   samostatně kódovanou diakritiku.
# - ztrátový = Vyhýbá se použití zvláštních znaků, u kterých není výslovnost
#   na první pohled patrná.
# - technický = Preferuje bezztrátovost, přepis 1:1 (jeden znak za jeden znak)
#   a přepis pouze do ASCII znaků. Cenou je snížená čitelnost, ale zase mohou
#   odpadnout některé technické problémy se zobrazováním unikódové latinky.
#   Hodí se také pro opačný přepis při zadávání cizího písma z klávesnice (IME).
#   V případě arabštiny je asi nejznámější přepis Tima Buckwaltera.
# Alternativní přepisy jsou uvedené v tomto pořadí (index do pole):
# 0 ... český bezztrátový
# 1 ... český bezztrátový putty
# 2 ... český ztrátový
# 3 ... vědecký (v podstatě anglický bezztrátový)
# 4 ... anglický ztrátový
# 5 ... technický (částečný Buckwalter; pouze pro arabštinu; písmena jiných
#       jazyků i zde využívají diakritiku)
#------------------------------------------------------------------------------
%alt =
(
    # chr(240) je LATIN SMALL LETTER ETH
    # chr(254) je LATIN SMALL LETTER THORN
    # chr(289) je LATIN SMALL LETTER G WITH DOT ABOVE
    # chr(702) je MODIFIER LETTER RIGHT HALF RING # pro přepis hamzy používá Ota Smrž ("ʾ")
    # chr(703) je MODIFIER LETTER LEFT HALF RING # pro přepis ajnu používá Ota Smrž ("ʿ")
    # chr(803) je COMBINING DOT BELOW
    # chr(807) je COMBINING CEDILLA
    # chr(814) je COMBINING BREVE BELOW # Ota Smrž používá pro přepis hlásky "ch"
    # chr(817) je COMBINING MACRON BELOW
    'Á'     => ['Á',  'Á',  'Á',  'Ā', 'Ā',  '>'],
    'Í'     => ['Í',  'Í',  'Í',  'Ī', 'Ī',  '<'],
    'Ú'     => ['Ú',  'Ú',  'Ú',  'Ū', 'Ū',  '&'],
    'á'     => ['á',  'á',  'á',  'ā', 'ā',  'A'],
    'í'     => ['í',  'í',  'í',  'ī', 'ī',  'I'],
    'ú'     => ['ú',  'ú',  'ú',  'ū', 'ū',  'U'],
    'dž'    => ['dž', 'dž', 'dž', 'j', 'j',  'j'],
    'j'     => ['j',  'j',  'j',  'y', 'y',  'y'],
    'š'     => ['š',  'š',  'š',  'š', 'sh', '$'],
    'č'     => ['č',  'č',  'č',  'č', 'ch', 'č'],
    'ch'    => ['ch', 'ch', 'ch', 'ḫ', 'kh', 'x'],
    'ž'     => ['ž',  'ž',  'ž',  'ž', 'zh', 'ž'],
    'hamza' => [chr(702),     chr(702),     "'",  chr(702),     "'",  "'"],
    'aham'  => [chr(702).'a', chr(702).'a', 'a',  chr(702).'a', 'a',  '>'],
    'iham'  => [chr(702).'i', chr(702).'i', 'i',  chr(702).'i', 'i',  '<'],
    'ah'    => ['ât',         'ât',         'a',  'ât',         'ah', 'p'], # teh marbuta
    'harab' => ['h'.chr(803), 'H',          'h',  'h'.chr(803), 'h',  'h'],
    'ghajn' => [chr(289),     chr(289),     'gh', chr(289),     'gh', 'g'],
    'ajn'   => [chr(703),     chr(703),     '`',  chr(703),     '`',  'E'],
    'sarab' => ['s'.chr(803), 'S',          's',  's'.chr(803), 's',  'S'],
    'darab' => ['d'.chr(803), 'D',          'd',  'd'.chr(803), 'd',  'D'],
    'tarab' => ['t'.chr(803), 'T',          't',  't'.chr(803), 't',  'T'],
    'zarab' => ['z'.chr(803), 'Z',          'z',  'z'.chr(803), 'z',  'Z'],
    'th'    => ['t'.chr(817), chr(254),     'th', 't'.chr(817), 'th', 'th'],
    'dh'    => ['d'.chr(817), chr(240),     'dh', 'd'.chr(817), 'dh', 'dh']
);



#------------------------------------------------------------------------------
# Uloží do hashe přepisy znaků.
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    # Má se do latinky přidávat nečeská diakritika, aby se neztrácela informace?
    my $bezztrat = 1;
    my $alt = 3; # vědecký přepis ###!!! Tohle chceme v budoucnosti parametrizovat zvenku!
    my %arab =
    (
        1548 => ',', # comma
        1563 => ';', # semicolon
        1567 => '?', # question
        1569 => $alt{'hamza'}[$alt], # hamza (samotná bývá někdy na konci slova)
        1570 => $alt{'Á'}[$alt], # alef madda آ
        1571 => $alt{'aham'}[$alt], # alef hamza above أ
        1572 => $alt{'Ú'}[$alt], # hamza waw ؤ
        1573 => $alt{'iham'}[$alt], # alef hamza below إ
        1574 => 'ʾi', # hamza yeh ئ; to s půlkruhem vpravo je Otův přepis
        1575 => $alt{'á'}[$alt], # alef
        1576 => 'b', # beh
        1577 => $alt{'ah'}[$alt], # teh marbuta (vyskytuje se na konci slova, ve výslovnosti se zřejmě často redukuje na "a")
        1578 => 't', # teh
        1579 => $alt{'th'}[$alt], # theh
        1580 => $alt{'dž'}[$alt], # jeem
        1581 => $alt{'harab'}[$alt], # hah
        1582 => $alt{'ch'}[$alt], # khah
        1583 => 'd', # dal
        1584 => $alt{'dh'}[$alt], # thal
        1585 => 'r', # reh
        1586 => 'z', # zain
        1587 => 's', # seen
        1588 => $alt{'š'}[$alt], # sheen
        1589 => $alt{'sarab'}[$alt], # sad
        1590 => $alt{'darab'}[$alt], # dad
        1591 => $alt{'tarab'}[$alt], # tah
        1592 => $alt{'zarab'}[$alt], # zah
        1593 => $alt{'ajn'}[$alt], # ain
        1594 => $alt{'ghajn'}[$alt], # ghain
        1600 => '_', # tatweel (plnidlo mezi znaky na typografické prodloužení slova)
        1601 => 'f', # feh
        1602 => 'q', # qaf
        1603 => 'k', # kaf
        1604 => 'l', # lam
        1605 => 'm', # meem
        1606 => 'n', # noon
        1607 => 'h', # heh
        1608 => $alt{'ú'}[$alt], # waw
        1609 => $alt{'í'}[$alt], # alef maksura
        1610 => $alt{'í'}[$alt], # yeh
        1611 => 'an', # fathatan (diakritika pro krátké a s "nunací")
        1612 => 'un', # dammatan (diakritika pro krátké u s "nunací")
        1613 => 'in', # kasratan (diakritika pro krátké i s "nunací")
        1614 => 'a', # fatha (diakritika pro krátké a)
        1615 => 'u', # damma (diakritika pro krátké u)
        1616 => 'i', # kasra (diakritika pro krátké i)
        1617 => ':', # shadda (zdvojená souhláska)
        1618 => '',  # sukun (žádná samohláska)
        1632 => '0', # arabic-indic digit zero
        1633 => '1', # arabic-indic digit one
        1634 => '2', # arabic-indic digit two
        1635 => '3', # arabic-indic digit three
        1636 => '4', # arabic-indic digit four
        1637 => '5', # arabic-indic digit five
        1638 => '6', # arabic-indic digit six
        1639 => '7', # arabic-indic digit seven
        1640 => '8', # arabic-indic digit eight
        1641 => '9', # arabic-indic digit nine
        1642 => '%', # percent
        1643 => ',', # decimal separator
        1644 => chr(160), # thousands separator
        1648 => $alt{'á'}[$alt], # superscript alef
        1649 => '-', # alef wasla (arabština Koránu; uvnitř slova; značí, že kvůli spojování se nevyslovuje ráz ani samohláska alefu)
        #1657 => $alt{'tind'}[$alt], # tteh
        1658 => 'ṭh', # tteheh (dvě tečky svisle pod sebou; používá se pro retroflexní aspirované "ṭh" v sindštině)
        1659 => 'ɓ', # beeh (používá se v sindštině pro souhlásku voiced bilabial implosive; IPA "b with hook")
        1660 => 'ṭ', # teh with ring (používá se pro retroflexní "t" v paštunštině)
        1661 => 'ṭ', # teh with three dots above downwards (používá se pro retroflexní "t" v sindštině)
        1662 => 'p', # peh
        1663 => 'th', # teheh (používá se pro aspirované "th" v sindštině)
        1664 => 'bh', # beheh (používá se pro aspirované "bh" v sindštině)
        1665 => 'ź', # hah with hamza above (používá se pro souhlásku "dz" v paštunštině)
        1667 => 'ň', # nyeh (používá se pro souhlásku "ň" v sindštině)
        1668 => 'ď', # dyeh (používá se v sindštině pro souhlásku voiced palatal implosive, tj. asi "ď")
        1669 => 'c', # hah with three dots above (používá se pro souhlásku "c" v paštunštině)
        1670 => $alt{'č'}[$alt], # tcheh
        1671 => $alt{'č'}[$alt].'h', # tcheheh (používá se pro aspirované "čh" v sindštině)
        #1672 => $alt{'dind'}[$alt], # ddal
        1673 => 'ḍ', # dal with ring (používá se pro retroflexní "d" v paštunštině)
        1674 => 'ɖ', # dal with dot below (používá se pro souhlásku "ɖ" v sindštině; IPA "d with tail")
        1676 => 'dh', # dahal (používá se pro aspirované "dh" v sindštině)
        1677 => 'ɖh', # ddahal (používá se pro aspirované "ɖh" v sindštině)
        1679 => 'ɗ', # dal with three dots above downwards (používá se pro souhlásku "ɗ" v sindštině; IPA "d with hook"; voiced alveolar implosive)
        #1681 => $alt{'rind'}[$alt], # rreh
        1683 => 'ṛ', # reh with ring (používá se pro retroflexní "r" v paštunštině)
        1685 => 'rr', # reh with small v below (používá se v kurdštině/sorání)
        1686 => 'ẑ', # reh with dot below and dot above (používá se pro nějakou variantu "ž" nebo "g" v paštunštině)
        1688 => $alt{'ž'}[$alt], # jeh
        1689 => 'ṛ', # reh with four dots above (používá se v sindštině pro retroflexní "ɽ")
        1690 => 'ṩ', # seen with dot below and dot above (používá se pro nějakou variantu "š" nebo "ch" v paštunštině)
        1700 => 'v', # veh (pro přepis "v" v cizích slovech např. v egyptsko-arabské Wikipedii)
        1702 => 'ph', # peheh (používá se pro aspirované "ph" v sindštině)
        1703 => 'q', # qaf with dot above (maghrebská verze qáfu má jen jednu tečku, zatímco na východě se používají dvě tečky; kromě toho jsem ale tohle písmeno viděl v ujgurské Wikipedii)
        1705 => 'k', # keheh
        1706 => 'k', # swash kaf (používá se v sindštině pro souhlásku "k", zatímco pro "kh" se zde používá perské keheh)
        1709 => 'ng', # ng (používá se v ujgurštině)
        1711 => 'g', # gaf
        1713 => 'ng', # ngoeh (používá se v sindštině pro souhlásku "ŋ")
        1715 => 'ɠ', # gueh (používá se v sindštině pro souhlásku "ɠ"; voiced velar implosive; IPA "g with hook")
        1717 => 'll', # lam with small v (používá se v kurdštině/sorání)
        #1722 => $alt{'anusvár'}[$alt], # noon ghunna
        1723 => 'ṇ', # rnoon (používá se pro retroflexní "ɳ" v sindštině)
        1724 => 'ṇ', # noon with ring (používá se pro retroflexní "ɳ" v paštunštině)
        1726 => 'h', # heh doachashmee
        1728 => 'h', # heh with yeh above
        1729 => 'h', # heh goal
        1730 => 'h', # heh goal hamza
        1731 => 'ah', # teh marbuta goal
        1734 => 'o', # oe (používá se pro samohlásku "o" v kurdštině/sorání)
        1735 => 'u', # u (používá se v ujgurštině)
        1736 => 'ü', # yu (používá se v ujgurštině pro samohlásku "ü")
        1738 => 'ü', # waw with two dots above (používá se pro samohlásku "ü" v jižní kurdštině a taky v gílánštině)
        1739 => 'v', # ve (používá se v ujgurštině)
        1740 => $alt{'í'}[$alt], # farsi yeh
        1741 => 'əy', # yeh with tail (používá se v paštunštině)
        1742 => 'ê', # yeh with small v (používá se pro samohlásku "e"/zavřené "é" v kurdštině/sorání)
        1744 => 'e', # e (používá se v ujgurštině)
        #1746 => 'é', # yeh barree
        #1747 => 'é', # yeh barree hamza
        1748 => '.', # full stop
        1749 => 'e', # ae (používá se pro samohlásku otevřené "e" v kurdštině/sorání)
        1776 => '0', # zero
        1777 => '1', # one
        1778 => '2', # two
        1779 => '3', # three
        1780 => '4', # four
        1781 => '5', # five
        1782 => '6', # six
        1783 => '7', # seven
        1784 => '8', # eight
        1785 => '9', # nine
        1789 => '&', # arabic sign sindhi ampersand
        1790 => 'men', # arabic sign sindhi postposition men (odpovídá předložce "v")
        1891 => 'g', # keheh with three dots above (pro přepis "g" v cizích slovech v marocké arabštině)
        8204 => '', # zero width non-joiner
        8205 => '', # zero width joiner
        8206 => '', # left-to-right mark
        8207 => '', # right-to-left mark
        8234 => '', # left-to-right embedding
        8235 => '', # right-to-left embedding
        8236 => '', # pop directional formatting
        8237 => '', # left-to-right override
        8238 => '', # right-to-left override
    );
    foreach my $kod (keys(%arab))
    {
        $prevod->{chr($kod)} = $arab{$kod};
    }
    # U písmene waw je těžké rozhodnout, zda reprezentuje souhlásku "w", nebo samohlásku "ú".
    # Na začátku slova ale dáme přednost souhláskovému čtení, protože samohláskové by asi bylo vyznačeno hamzou.
    # (Obecně popsat hranici slova je také těžké. Omezíme se na několik běžných kontextů.)
    # Obdobně písmeno yeh bude na začátku slova souhláska "y" ("j"), jinde samohláska "í".
    # Obdobně písmeno alif na začátku slova označuje libovolnou krátkou samohlásku, uvnitř a na konci slova je to dlouhé "á".
    foreach my $pred (' ', '<', '>', '(', ')')
    {
        $prevod->{$pred.chr(1608)} = $pred.'w';
        $prevod->{$pred.chr(1610)} = $pred.'y';
        $prevod->{$pred.chr(1740)} = $pred.'y';
        $prevod->{$pred.chr(1575)} = $pred.'a';
    }
    return $prevod;
}



1;
