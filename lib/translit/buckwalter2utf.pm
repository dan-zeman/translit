#!/usr/bin/perl
# Funkce pro přípravu převodu arabského textu z Buckwalterova kódování do UTF-8 (nebo případně do romanizace používané v ElixirFM). Je nutné si uvědomit následující:
# - Buckwalter zapisuje arabský text pomocí latinky a zvláštních znaků. Pokud do arabského textu měla být vložena skutečná latinka, nepoznáme to.
# Copyright © 2009, 2022 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::buckwalter2utf;
use utf8;



# Tabulka korespondence Buckwalterových znaků, arabských písmen a vědecké transkripce podle Elixiru (která zřejmě odpovídá DIN 31635).
@buckwalter =
(
    ['A', "\x{627}", 'ʾ'], # alef ʾ / ā
    ['b', "\x{628}", 'b'], # beh
    ['t', "\x{62A}", 't'], # teh
    ['v', "\x{62B}", 'ṯ'], # theh
    ['j', "\x{62C}", 'ǧ'], # jeem
    ['H', "\x{62D}", 'ḥ'], # hah
    ['x', "\x{62E}", "\x{1E2B}"], # khah ḫ
    ['d', "\x{62F}", 'd'], # dal
    ['*', "\x{630}", 'ḏ'], # thal (dh)
    ['r', "\x{631}", 'r'], # reh
    ['z', "\x{632}", 'z'], # zain
    ['s', "\x{633}", 's'], # seen
    ['$', "\x{634}", 'š'], # sheen
    ['S', "\x{635}", 'ṣ'], # sad
    ['D', "\x{636}", 'ḍ'], # dad
    ['T', "\x{637}", 'ṭ'], # tah
    ['Z', "\x{638}", 'ẓ'], # zah
    ['E', "\x{639}", 'ʿ'], # ain
    ['g', "\x{63A}", 'ġ'], # ghain
    ['f', "\x{641}", 'f'], # feh
    ['q', "\x{642}", 'q'], # qaf
    ['k', "\x{643}", 'k'], # kaf
    ['l', "\x{644}", 'l'], # lam
    ['m', "\x{645}", 'm'], # meem
    ['n', "\x{646}", 'n'], # noon
    ['h', "\x{647}", 'h'], # heh
    ['w', "\x{648}", 'w'], # waw w / ū
    ['y', "\x{64A}", 'y'], # yeh
    ['Y', "\x{649}", 'ī'], # alef maksura
    ["'", "\x{621}", 'ʾ'], # hamza
    ['>', "\x{623}", 'ʾa'], # hamza on alif
    ['<', "\x{625}", 'ʾi'], # hamza below alif
    ['&', "\x{624}", 'ʾu'], # hamza on wa
    ['}', "\x{626}", 'ʾi'], # hamza on ya
    ['|', "\x{622}", 'ʾā'], # madda on alif
    ['{', "\x{671}", 'ā'], # alif al-wasla
    ['`', "\x{670}", 'ā'], # dagger alif; not sure what it is, used superscript alef
    ['a', "\x{64E}", 'a'], # fatha
    ['u', "\x{64F}", 'u'], # damma
    ['i', "\x{650}", 'i'], # kasra
    ['F', "\x{64B}", 'an'], # fathatan
    ['N', "\x{64C}", 'un'], # dammatan
    ['K', "\x{64D}", 'in'], # kasratan
    ['~', "\x{651}", '~'], # shadda; for Elixir transliteration we would need s/(.)~/$1$1/g but we cannot encode it using this table
    ['o', "\x{652}", ''], # sukun
    ['p', "\x{629}", 'at'], # teh marbuta
    ['_', "\x{640}", ''], # tatweel
    ['0', "\x{660}", '0'],
    ['1', "\x{661}", '1'],
    ['2', "\x{662}", '2'],
    ['3', "\x{663}", '3'],
    ['4', "\x{664}", '4'],
    ['5', "\x{665}", '5'],
    ['6', "\x{666}", '6'],
    ['7', "\x{667}", '7'],
    ['8', "\x{668}", '8'],
    ['9', "\x{669}", '9'],
);



#------------------------------------------------------------------------------
# Uloží do hashe přepisy Buckwalterových znaků. Odkaz na cílový hash převezme
# jako parametr. Vrátí délku nejdelšího řetězce, jehož přepis je v hashi
# definován.
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    my $maxl;
    ###!!! Přepis z Buckwaltera do Elixiru zatím nelze zapnout, i když přibližnou tabulku nahoře nachystanou máme.
    foreach my $radek (@buckwalter)
    {
        my $buck = $radek->[0];
        my $utf = $radek->[1];
        $prevod->{$buck} = $utf;
        my $l = length($buck);
        $maxl = $l if($l>$maxl);
    }
    return $maxl;
}
