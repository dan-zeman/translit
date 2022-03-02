# translit
Perl script for transliteration between writing systems.

BEWARE:
The actual transliteration tables are implemented as Perl modules (libraries).
My intention was to ultimately have them released at CPAN, however, I have not
completed that process (one open question is what namespace I will use, as
Lingua::Translit is already taken). For now, the main script (translit.pl)
assumes that the libraries can be found in /home/zeman/lib (or, alternatively,
in any library path you provide to Perl via the -I option or via the PERL5LIB
environment variable).

I have yet to straighten the way how I version those modules. At present they
are physically different files from the ones in this repo, and although I
obviously want them to be identical to the ones here, I cannot guarantee it.
