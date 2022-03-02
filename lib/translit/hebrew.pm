package translit::hebrew;
use utf8;

#------------------------------------------------------------------------------
# Uloží do hashe přepisy znaků.
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    # Má se do latinky přidávat nečeská diakritika, aby se neztrácela informace?
    my $bezztrat = 1;
    my $alt = 1; # český přepis pro putty

    my %trans_mix = (
        "א" => "'",
        "ב" => "v",
        "בּ" => "b",
        "ג" => "g",
        "גּ" => "g",
        "ג׳" => "ǧ",
        "ד" => "d",
        "דּ" => "d",
        "ד׳" => "ḏ",
        "ה" => "h",
        "הּ" => "h",
        "ו" => "v",
        "וּ" => "v",
        "ז" => "z",
        "זּ" => "z",
        "ז׳" => "ž",
        "ח" => "ẖ", # ch
        "ט" => "t",
        "טּ" => "t",
        "י" => "j",
        "יּ" => "j",
        "ך" => "ḵ", # k/ch
        "כ" => "ḵ", # k/ch
        "ךּ" => "k",
        "כּ" => "k",
        "ל" => "l",
        "לּ" => "l",
        "מ" => "m",
        "ם" => "m",
        "מּ" => "m",
        "נ" => "n",
        "ן" => "n",
        "נּ" => "n",
        "ס" => "s",
        "סּ" => "s",
        "ע" => "'",
        "פ" => "f",
        "ף" => "f",
        "פּ" => "p",
        "ףּ" => "p",
        "צ" => "c", # tz, ts
        "ץ" => "c",
        "צּ" => "c",
        "צ׳" => "č",
        "ץ׳" => "č",
        "ק" => "k",
        "קּ" => "k",
        "ר" => "r",
        "רּ" => "r",
        "ש" => "š",
        "שׁ" => "š",
        "שּׁ" => "š",
        "שׂ" => "s",
        "שּׂ" => "s",
        "ת" => "t",
        "תּ" => "t",
        "ת׳" => "ṯ",
        "ח׳" => "ḫ",
        "ט׳" => "ẓ",
        "ר׳" => "ġ",
        "ע׳" => "ġ",
        "צ׳" => "ḍ",
        "ץ׳" => "ḍ",
        "טְ" => "ḍ",
        "חֱ" => "e",
        "חֲ" => "a",
        "חֳ" => "o",
        "טִ" => "i",
        "טֵ" => "e",
        "טֶ" => "e",
        "טַ" => "a",
        "טָ" => "a",
        "טֹ" => "o",
        "טֻ" => "u",
        "טוּ" => "u",
        "טֵי" => "ej",
        "טֶי" => "ej",
        "טַי" => "aj",
        "טָי" => "aj",
        "טַיְ" => "aj",
        "טָיְ" => "aj",
        "טֹי" => "oj",
        "טֹיְ" => "oj",
        "טֻי" => "uj",
        "טוּיְ" => "uj",
        "טֻיְ" => "uj",
        "טוּי" => "uj",
    );

    my %trans_israeli = (
        "א" => "'",
        "ב" => "v",
        "בּ" => "b",
        "ג" => "g",
        "גּ" => "g",
        "ג׳" => "j",
        "ד" => "d",
        "דּ" => "d",
        "ד׳" => "dh",
        "ה" => "h",
        "הּ" => "h",
        "ו" => "v",
        "וּ" => "v",
        "ז" => "z",
        "זּ" => "z",
        "ז׳" => "zh",
        "ח" => "ch",
        "ט" => "t",
        "טּ" => "t",
        "י" => "y",
        "יּ" => "y",
        "ך" => "kh",
        "כ" => "kh",
        "ךּ" => "k",
        "כּ" => "k",
        "ל" => "l",
        "לּ" => "l",
        "מ" => "m",
        "ם" => "m",
        "מּ" => "m",
        "נ" => "n",
        "ן" => "n",
        "נּ" => "n",
        "ס" => "s",
        "סּ" => "s",
        "ע" => "'",
        "פ" => "f",
        "ף" => "f",
        "פּ" => "p",
        "ףּ" => "p",
        "צ" => "tz",
        "ץ" => "tz",
        "צּ" => "tz",
        "צ׳" => "tsh",
        "ץ׳" => "tsh",
        "ק" => "k",
        "קּ" => "k",
        "ר" => "r",
        "רּ" => "r",
        "ש" => "sh",
        "שׁ" => "sh",
        "שּׁ" => "sh",
        "שׂ" => "s",
        "שּׂ" => "s",
        "ת" => "t",
        "תּ" => "t",
        "ת׳" => "th",
        "ח׳" => "ḫ",
        "ט׳" => "ẓ",
        "ר׳" => "ġ",
        "ע׳" => "ġ",
        "צ׳" => "ḍ",
        "ץ׳" => "ḍ",
        "טְ" => "ḍ",
        "חֱ" => "e",
        "חֲ" => "a",
        "חֳ" => "o",
        "טִ" => "i",
        "טֵ" => "e",
        "טֶ" => "e",
        "טַ" => "a",
        "טָ" => "a",
        "טֹ" => "o",
        "טֻ" => "u",
        "טוּ" => "u",
        "טֵי" => "ei",
        "טֶי" => "ei",
        "טַי" => "ai",
        "טָי" => "ai",
        "טַיְ" => "ai",
        "טָיְ" => "ai",
        "טֹי" => "oi",
        "טֹיְ" => "oi",
        "טֻי" => "ui",
        "טוּיְ" => "ui",
        "טֻיְ" => "ui",
        "טוּי" => "ui",
    );

    my %trans_cs = (
        "א" => "’",
        "ב" => "b",
        "ג" => "g",
        "ג" => "dž",
        "ד" => "d",
        "ד" => "ď",
        "ה" => "h",
        "ו" => "v",
        "ז" => "z",
        "ז" => "ž",
        "ח" => "ch",
        "ט" => "t",
        "י" => "j",
        "כ" => "k",
        "ך" => "k",
        "ל" => "l",
        "מ" => "m",
        "ם" => "m",
        "נ" => "n",
        "ן" => "n",
        "ס" => "s",
        "ע" => "‘",
        "פ" => "p",
        "ף" => "p",
        "צ" => "c",
        "ץ" => "c",
        "'צ" => "č",
        "'ץ" => "č",
        "ק" => "k",
        "ר" => "r",
        "שׁ" => "š",
        "שׂ" => "s",
        "ת" => "t",
        "ת" => "th",
    );
    foreach my $he (keys %trans_mix) {
        $prevod->{$he} = $trans_mix{$he};
    }
    return $prevod;
}



1;

=head1 NAME 

translit::hebrew

=head1 DESCRIPTION

Transliterate Hebrew using Common Israeli transcription as its base, but using
Hebrew Academy 1953 transcription or ISO 259 instead when the Israeli one uses
several latin letters for one Hebrew letter, so that there is a 1:1 mapping
between letters as much as possible
(and terrible things like 'tsh' for 'č' are avoided :-)).
For the 'tz' or 'ts' sound [ts], Czech 'c' transcription is used, so that the
one-letter assumption is kept.
For the 'y' or 'i' sound [j], Czech 'j' transcription is used, so that it is
clear that it a consonant, not vowel.
(For the 'j' sound [dz], 'ǧ' is used, not to be confused with 'j' for [j].)
Based on L<http://en.wikipedia.org/wiki/Romanization_of_Hebrew>.
For each letter, only its most common transliteration is used (as it is often
hard to automatically decide which from the alternatives to use).

(Common Israeli transliteration and Czech transliteration
(based on L<http://cs.wikipedia.org/wiki/Fonologie_hebrej%C5%A1tiny>)
are hidden in the source code, if anyone wants that.)

=head1 AUTHOR

Rudolf Rosa <rosa@ufal.mff.cuni.cz>

=head1 COPYRIGHT AND LICENSE

Copyright © 2013 by Institute of Formal and Applied Linguistics,
Charles University in Prague

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

