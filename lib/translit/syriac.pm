#!/usr/bin/perl
# Funkce pro přípravu transliterace z urdsko-arabského písma do latinky.
# Copyright © 2008 – 2013 Dan Zeman <zeman@ufal.mff.cuni.cz>
# 2013-10-21 ... Zpětně doplňuji vědecký přepis podle arab.pm.
# Licence: GNU GPL

package translit::syriac;
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
    'á'     => ['á',  'á',  'á',  'ā', 'ā',  'A'],
    'í'     => ['í',  'í',  'í',  'ī', 'ī',  'I'],
    'ú'     => ['ú',  'ú',  'ú',  'ū', 'ū',  'U'],
    'é'     => ['é',  'é',  'é',  'e', 'e',  'e'],
    'j'     => ['j',  'j',  'j',  'y', 'y',  'y'],
    'š'     => ['š',  'š',  'š',  'š', 'sh', '$'],
    'ch'    => ['ch', 'ch', 'ch', 'x', 'kh', 'x'],
    # semitské zvláštní hlásky (z historických důvodů je tady mám označené jako arabské)
    # chr(8216) je LEFT SINGLE QUOTATION MARK
    'harab' => ['ḥ',          'H',  'h',  'ḥ',          'h',  'h'],
    'ghajn' => [chr(289), chr(289), 'gh', chr(289),     'gh', 'G'],
    'ajn'   => [chr(703), '`',      "`",  chr(703),     "`",  'c'],
    'sarab' => ['ṣ',          'S',  's',  'ṣ',          's',  'S'],
    'darab' => ['d'.chr(807), 'D',  'd',  'd'.chr(807), 'd',  'd'],
    'tarab' => ['ṭ',          'T',  't',  'ṭ',          't',  't'],
    'zarab' => ['z'.chr(807), 'Z',  'z',  'z'.chr(807), 'z',  'Z'],
    'th'    => [chr(254), chr(254), 'th', chr(254),     'th', 'th'],
    'dh'    => [chr(240), chr(240), 'dh', chr(240),     'dh', 'dh']
);



#------------------------------------------------------------------------------
# Uloží do hashe přepisy znaků.
# Syriac script explained: https://r12a.github.io/scripts/syriac/
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    # Má se do latinky přidávat nečeská diakritika, aby se neztrácela informace?
    my $bezztrat = 1;
    my $alt = 3; # vědecký přepis, tj. bezztrátový s preferencí anglické výslovnosti
    my %syriac =
    (
        1808 => 'ʾ', # alaph
        1809 => $alt{'á'}[$alt], # superscript alaph
        1810 => 'b', # beth
        1811 => 'g', # gamal
        1812 => $alt{'ghajn'}[$alt], # gamal garshuni (to write Arabic)
        1813 => 'd', # dalath
        1814 => 'ḍ', # dotless dalath-rish (Ancient texts, ambiguous between dalath and rish)
        1815 => 'h', # he
        1816 => 'w', # waw
        1817 => 'z', # zain
        1818 => $alt{'harab'}[$alt], # heth
        1819 => $alt{'tarab'}[$alt], # teth
        1820 => $alt{'tarab'}[$alt], # teth garshuni (i.e. really Arabic)
        1821 => $alt{'j'}[$alt], # yudh
        1822 => 'yh', # yudh he
        1823 => 'k', # kaph
        1824 => 'l', # lamadh
        1825 => 'm', # mim
        1826 => 'n', # nun
        1827 => 's', # semkath
        1828 => 's', # final semkath
        1829 => $alt{'ajn'}[$alt], # e
        1830 => 'p', # pe
        1831 => 'p', # reversed pe
        1832 => $alt{'sarab'}[$alt], # sadhe
        1833 => 'q', # qaph
        1834 => 'r', # rish
        1835 => $alt{'š'}[$alt], # shin
        1836 => $alt{'tarab'}[$alt], # taw
        1842 => 'a', # pthaha dotted (A dot above and a dot below a letter represent [a], transliterated as a or ă (called ܦܬ݂ܵܚܵܐ‎, pṯāḥā))
        1845 => 'ā', # zqapha dotted (Two diagonally-placed dots above a letter represent [ɑ], transliterated as ā or â or å (called ܙܩܵܦ݂ܵܐ‎, zqāp̄ā))
        1848 => 'e', # zlama horizontal (Two horizontally-placed dots below a letter represent [ɛ], transliterated as e or ĕ (called ܪܒ݂ܵܨܵܐ ܐܲܪܝܼܟ݂ܵܐ‎, rḇāṣā ʾărīḵā or ܙܠܵܡܵܐ ܦܫܝܼܩܵܐ‎, zlāmā pšīqā; often pronounced [ɪ] and transliterated as i in the East Syriac dialect))
        1849 => 'ē', # zlama angular (Two diagonally-placed dots below a letter represent [e], transliterated as ē (called ܪܒ݂ܵܨܵܐ ܟܲܪܝܵܐ‎, rḇāṣā karyā or ܙܠܵܡܵܐ ܩܲܫܝܵܐ‎, zlāmā qašyā))
        1852 => 'i', # hbasa-esasa should normally only occur after yudh or waw; but it sometimes does occur without it
        1855 => 'o', # rwaha should normally only occur after waw; but it sometimes does occur without it
        1856 => '-tā', # feminine dot => Assyrian feminine suffix
        1863 => '', # syriac oblique line above ... used to indicate letters that are not pronounced in some dialects
        1864 => '', # syriac oblique line below ... used similarly to oblique line above
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
    foreach my $kod (keys(%syriac))
    {
        $prevod->{chr($kod)} = $syriac{$kod};
    }
    # The letter waw with a dot above it represents [o], transliterated as ō or o (called ܥܨܵܨܵܐ ܪܘܝܼܚܵܐ‎, ʿṣāṣā rwīḥā or ܪܘܵܚܵܐ‎, rwāḥā).
    $prevod->{chr(1816).chr(1855)} = 'ō';
    # The letter waw with a dot below it represents [u], transliterated as ū or u (called ܥܨܵܨܵܐ ܐܲܠܝܼܨܵܐ‎, ʿṣāṣā ʾălīṣā or ܪܒ݂ܵܨܵܐ‎, rḇāṣā)
    $prevod->{chr(1816).chr(1852)} = 'ū';
    # The letter yōḏ with a dot beneath it represents [i], transliterated as ī or i (called ܚܒ݂ܵܨܵܐ‎, ḥḇāṣā)
    $prevod->{chr(1821).chr(1852)} = 'ī';
    # Hard and soft pronunciation of certain letters can be made explicit by adding qushshaya (1857, hard) or rukkakha (1858, soft).
    $prevod->{chr(1810).chr(1857)} = 'b';
    $prevod->{chr(1810).chr(1858)} = 'v';
    $prevod->{chr(1811).chr(1857)} = 'g';
    $prevod->{chr(1811).chr(1858)} = $alt{'gh'}[$alt];
    $prevod->{chr(1813).chr(1857)} = 'd';
    $prevod->{chr(1813).chr(1858)} = $alt{'dh'}[$alt];
    $prevod->{chr(1823).chr(1857)} = 'k';
    $prevod->{chr(1823).chr(1858)} = 'x';
    $prevod->{chr(1830).chr(1857)} = 'p';
    $prevod->{chr(1830).chr(1858)} = 'f';
    $prevod->{chr(1830).chr(814)}  = 'f'; # modern texts use U+032E COMBINING BREVE BELOW to indicate a fricative form of pe
    $prevod->{chr(1836).chr(1857)} = $alt{'tarab'}[$alt];
    $prevod->{chr(1836).chr(1858)} = $alt{'th'}[$alt];
    return $prevod;
}



1;
