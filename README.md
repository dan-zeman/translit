# translit
Perl script for transliteration between writing systems.

BEWARE:
The actual transliteration tables are implemented as Perl modules (libraries).
My intention was to ultimately have them released at CPAN, however, I have not
completed that process (one open question is what namespace I will use, as
Lingua::Translit is already taken). For now, the main script (translit.pl)
assumes that the libraries can be found in /home/zeman/projekty/translit/lib
(or, alternatively, in any library path you provide to Perl via the -I option
or via the PERL5LIB environment variable). Within this repository, the modules
are available in the 'lib' folder.

Assuming you have a Perl interpreter installed on your system (typically
pre-installed on Linux; on Windows, you may have to download and install
Strawberry Perl), and you have cloned this repository as
`/home/USER/translit`, you should be able to transliterate a Malayalam text
(UTF-8) into a Latin-based alphabet like this:

```bash
cat mltext.txt | perl -I /home/USER/translit/lib /home/USER/translit/translit.pl -s -l ml > transliterated.txt
```

You tell the script the ISO 639-1 language code of the language of the text
(here `ml` for Malayalam) using the `-l` option. This is not strictly necessary,
as you will get the transliteration even without providing the correct language
code. However, for some supported languages, the transliteration from the same
writing system may slightly differ. For example, the Cyrillic letter _г_ will
be transliterated as _g_ when the source language is Russian, and _h_ when it is
Ukrainian.

<!-- Webové rozhraní je vypnuté, protože jinak by ho vytěžovali roboti.

For direct transliteration of web pages (and also for demo of the currently
supported languages), see
[http://quest.ms.mff.cuni.cz/cgi-bin/zeman/translit/translit.pl](http://quest.ms.mff.cuni.cz/cgi-bin/zeman/translit/translit.pl).
-->
