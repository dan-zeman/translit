#!/usr/bin/env perl
# Převede text na entity HTML (s výjimkou znaků ASCII).
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

while(<>)
{
    my @znaky = map {ord($_)<128 ? $_ : "&\#".ord($_).';'} (split(//, $_));
    print(join('', @znaky));
}
