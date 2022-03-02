#!/usr/bin/perl
# Funkce pro přípravu transliterace z korejského písma do latinky.
# Copyright © 2003, 2018 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::hangeul;
use utf8;



#------------------------------------------------------------------------------
# Uloží do hashe přepisy znaků.
#------------------------------------------------------------------------------
sub inicializovat
{
    # Odkaz na hash, do kterého se má ukládat převodní tabulka.
    my $prevod = shift;
    # 59393 prvni dalsi (zacina "oblast osobniho pouziti")
    # ga gga na da dda ra ma ba bba sa ssa a ja jja cha ka ta pa ha
    # ga gae gya gyae geo ge gyeo gye go gwa gwae goe gyo gu gweo gwe gwi gyu geu gyi gi
    # ga gag gagg gags gan ganj ganh gad gar garg garm garb gars gart garp garh gam gab gabs gas gass gang gaj gach gak gat gap gah
    my @init = ("g", "gg", "n", "d", "dd", "r", "m", "b", "bb", "s", "ss", "", "j", "jj", "ch", "k", "t", "p", "h");
    my @vowl = ("a", "ae", "ya", "yae", "eo", "e", "yeo", "ye", "o", "wa", "wae", "oe", "yo", "u", "weo", "we", "wi", "yu", "eu", "yi", "i");
    my @stop = ("", "g", "gg", "gs", "n", "nj", "nh", "d", "l", "rg", "rm", "rb", "rs", "rt", "rp", "rh", "m", "b", "bs", "s", "ss", "ng", "j", "ch", "k", "t", "p", "h");
    for(my $kod = 44032; $kod<55204; $kod++)
    {
        my $init = int(($kod-44032)/588);
        my $vowl = int(($kod-(44032+588*$init))/28);
        my $stop = $kod-(44032+588*$init+28*$vowl);
        $prevod->{chr($kod)} = ".$init[$init]$vowl[$vowl]$stop[$stop]";
    }
    return $prevod;
}



1;
