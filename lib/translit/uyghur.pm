#!/usr/bin/perl
# Funkce pro přípravu transliterace z ujgursko-arabského písma do latinky.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::uyghur;
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
# Alternativní přepisy jsou uvedené v tomto pořadí (index do pole):
# 0 ... český bezztrátový
# 1 ... český bezztrátový putty
# 2 ... český ztrátový
# 3 ... vědecký (v případě ujgurštiny jde o ULY, která obsahuje spřežky; viz https://en.wikipedia.org/wiki/Uyghur_alphabets)
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
    'Á'     => ['Á',  'Á',  'Á',  'Ā',  'Ā',  '>'],
    'Í'     => ['Í',  'Í',  'Í',  'Ī',  'Ī',  '<'],
    'Ú'     => ['Ú',  'Ú',  'Ú',  'Ū',  'Ū',  '&'],
    'á'     => ['á',  'á',  'á',  'ā',  'ā',  'A'],
    'í'     => ['í',  'í',  'í',  'ī',  'ī',  'I'],
    'ú'     => ['ú',  'ú',  'ú',  'ū',  'ū',  'U'],
    'é'     => ['é',  'é',  'é',  'e',  'e',  'e'],
    'dž'    => ['dž', 'dž', 'dž', 'j',  'j',  'j'],
    'j'     => ['j',  'j',  'j',  'y',  'y',  'y'],
    'š'     => ['š',  'š',  'š',  'sh', 'sh', '$'],
    'č'     => ['č',  'č',  'č',  'ch', 'ch', 'č'],
    'ch'    => ['ch', 'ch', 'ch', 'x',  'kh', 'x'],
    'ž'     => ['ž',  'ž',  'ž',  'zh', 'zh', 'ž'],
    # indické zvláštní hlásky
    # chr(355) je LATIN SMALL LETTER T WITH CEDILLA
    # chr(273) je LATIN SMALL LETTER D WITH STROKE
    # chr(326) je LATIN SMALL LETTER N WITH CEDILLA
    # chr(771) je COMBINING TILDE
    # chr(241) je LATIN SMALL LETTER N WITH TILDE
    # chr(331) je LATIN SMALL LETTER ENG
    # chr(343) je LATIN SMALL LETTER R WITH CEDILLA
    'tind'    => ['t'.chr(803), chr(355), 't',  't'.chr(803), 't', 'T'],
    'dind'    => ['d'.chr(803), chr(273), 'd',  'd'.chr(803), 'd', 'D'],
    'nind'    => ['n'.chr(803), chr(326), 'n',  'n'.chr(803), 'n', 'N'],
    'anusvár' => ['n'.chr(771), chr(241), 'n',  'n'.chr(771), 'n', 'M'],
    'ng'      => [chr(331),     chr(331), 'ng', chr(331),     'ng', 'ng'],
    'ň'       => ['ň',          'ň',      'ň',  'ň',          'ny', 'ny'],
    'rind'    => ['r'.chr(803), chr(343), 'r',  'r',          'r', 'R'],
    # chr(8216) je LEFT SINGLE QUOTATION MARK
    'harab' => ['h'.chr(803), 'H',  'h',  'h',          'h',  'h'],
    'ajn'   => [chr(703), '`',      "`",  chr(703),     "`",  'c'],
    'sarab' => ['s'.chr(807), 'S',  's',  's'.chr(807), 's',  'S'],
    'darab' => ['d'.chr(807), 'D',  'd',  'd'.chr(807), 'd',  'd'],
    'tarab' => ['t'.chr(807), 'T',  't',  't'.chr(807), 't',  't'],
    'zarab' => ['z'.chr(807), 'Z',  'z',  'z'.chr(807), 'z',  'Z'],
    'th'    => [chr(254), chr(254), 'th', chr(254),     'th', 'th'],
    'dh'    => [chr(240), chr(240), 'dh', chr(240),     'dh', 'dh']
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
    my $alt = 3; # vědecký přepis, tj. bezztrátový s preferencí anglické výslovnosti
    my %urdu =
    (
        1548 => ',', # comma
        1563 => ';', # semicolon
        1567 => '?', # question
        1569 => "'", # hamza (samotná bývá někdy na konci slova)
        1570 => $alt{'Á'}[$alt], # alef madda Ř˘
        1571 => 'Á', # alef hamza above
        1572 => $alt{'Ú'}[$alt], # hamza waw Ř¤
        1573 => 'Í', # alef hamza below
        1574 => '',  # hamza yeh se v ujgurštině používá před samohláskou na začátku slova nebo slabiky; v latince má zmizet
        1575 => 'a', # alef
        1576 => 'b', # beh
        1577 => 'eh', # teh marbuta (používá se v arabštině; v ujgurštině asi spíš jen omylem)
        1578 => 't', # teh
        1579 => $alt{'th'}[$alt], # theh
        1580 => $alt{'dž'}[$alt], # jeem
        1581 => $alt{'harab'}[$alt], # hah
        1582 => 'x', # khah
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
        1594 => 'gh', # ghain
        1600 => '_', # tatweel (plnidlo mezi znaky na typografické prodloužení slova)
        1601 => 'f', # feh
        1602 => 'q', # qaf
        1603 => 'k', # kaf
        1604 => 'l', # lam
        1605 => 'm', # meem
        1606 => 'n', # noon
        1607 => 'h', # heh
        1608 => 'o', # waw: v ujgurštině se používá jako samohláska o
        1609 => 'i', # alef maksura: v ujgurštině se používá jako samohláska i
        1610 => 'y', # yeh
        1611 => 'an', # fathatan (diakritika pro krátké a s "nunací")
        1612 => 'un', # dammatan (diakritika pro krátké u s "nunací")
        1613 => 'in', # kasratan (diakritika pro krátké i s "nunací")
        1614 => 'a', # fatha (diakritika pro krátké a)
        1615 => 'u', # damma (diakritika pro krátké u)
        1616 => 'i', # kasra (diakritika pro krátké i)
        1617 => ':', # shadda (zdvojená souhláska)
        1618 => '',  # sukun (žádná samohláska)
        1642 => '%', # percent
        1643 => ',', # decimal separator
        1644 => chr(160), # thousands separator
        1648 => $alt{'á'}[$alt], # superscript alef
        1649 => '-', # alef wasla (arabština Koránu; uvnitř slova; značí, že kvůli spojování se nevyslovuje ráz ani samohláska alefu)
        1657 => $alt{'tind'}[$alt], # tteh
        1662 => 'p', # peh
        1670 => $alt{'č'}[$alt], # tcheh
        1672 => $alt{'dind'}[$alt], # ddal
        1681 => $alt{'rind'}[$alt], # rreh
        1688 => $alt{'ž'}[$alt], # jeh
        1705 => 'k', # keheh
        1709 => 'ng', # ARABIC LETTER NG, variant used in Turkic languages
        1711 => 'g', # gaf
        1722 => $alt{'anusvár'}[$alt], # noon ghunna
        1726 => 'h', # heh doachashmee
        1728 => 'h', # heh with yeh above
        1729 => 'h', # heh goal
        1730 => 'h', # heh goal hamza
        1731 => 'eh', # teh marbuta goal
        1734 => 'ö', # ARABIC LETTER OE
        1735 => 'u', # ARABIC LETTER U
        1736 => 'ü', # ARABIC LETTER YU
        1739 => 'w', # ARABIC LETTER VE (v ujgurštině se waw používá jako samohláska o, proto pro v/w potřebujeme jiné písmeno)
        1740 => $alt{'í'}[$alt], # farsi yeh
        1744 => 'ë', # ARABIC LETTER E
        1746 => $alt{'é'}[$alt], # yeh barree
        1747 => $alt{'é'}[$alt], # yeh barree hamza
        1748 => '.', # full stop
        1749 => 'e', # ARABIC LETTER AE
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
        2404 => '.', # danda (oddělovač vět v dévanágarí, v urdštině může být jen omylem)
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
    foreach my $kod (keys(%urdu))
    {
        $prevod->{chr($kod)} = $urdu{$kod};
    }
    # U písmene waw je těžké rozhodnout, zda reprezentuje souhlásku "v", nebo samohlásku "ú".
    # Na začátku slova ale dáme přednost souhláskovému čtení, protože samohláskové by asi bylo vyznačeno hamzou.
    # (Obecně popsat hranici slova je také těžké. Omezíme se na několik běžných kontextů.)
    # Obdobně písmeno yeh bude na začátku slova souhláska "y" ("j"), jinde samohláska "í".
    # Obdobně písmeno alif na začátku slova označuje libovolnou krátkou samohlásku, uvnitř a na konci slova je to dlouhé "á".
    foreach my $pred (' ', '<', '>', '(', ')')
    {
        $prevod->{$pred.chr(1608)} = $pred.'v';
        $prevod->{$pred.chr(1610)} = $pred.'y';
        $prevod->{$pred.chr(1740)} = $pred.'y';
        $prevod->{$pred.chr(1575)} = $pred.'a';
    }
    return $prevod;
}



1;
