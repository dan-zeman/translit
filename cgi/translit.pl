#!/usr/bin/perl
# Downloads a HTML document from the web, transliterates non-Latin characters in it, and displays it.
# We have the script under version control in the git repository together with the rest of the translit package.
# When changed, it must be manually copied to the right place on the server, because we do not want to clone
# the whole repository in the cgi folder, and the server does not follow symlinks leading out of the cgi folder.
# quest: /home/zeman/cgi/translit (= /usr/lib/cgi-bin/zeman/translit)
# orinoko: C:\Users\Dan\Documents\Web\cgi\ufal-zeman\translit
# Copyright and security: This script should be protected by a .htaccess file.
# It processes and serves web content created and possibly copyright by others. It thus cannot serve the content to anyone.
# Copyright © 2010, 2013, 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use URI::Escape;
use HTML::Entities;
# Let Apache know where Dan's libraries are.
use lib 'C:/Users/Dan/Documents/lib';
use lib '/home/zeman/lib';
use lib '/home/zeman/projekty/translit/lib';
use cas; # Dan's library for time operations
use dzcgi; # Dan's library for CGI parameters
use htmlform; # Dan's web client. Using LWP::Simple would cause Wikipedia not to talk to us at all.
use htmlabspath; # Dan's library to convert hyperlinks to absolute addresses
use translit; # Dan's transliteration library
use translit::han2pinyin; # Dan's conversion of Han characters to pinyin (table from Unicode.org)

print("Content-type: text/html; charset=utf8\n\n");

# IP address 52.3.127.144 is a robot from Amazon and it ignores robots.txt. Do not talk to it.
if($ENV{REMOTE_ADDR} eq '52.3.127.144')
{
    exit;
}

# Read cgi parameters.
dzcgi::cist_parametry(\%config);
# Ask for URL to download.
if(!exists($config{url}))
{
    print("<html>\n");
    print("  <head>\n");
    print("    <title>DZ Translit: Please provide URL</title>\n");
    print("    <meta name=\"robots\" content=\"noindex, nofollow\">\n");
    print("  </head>\n");
    print("  <body>\n");
    print("    <h1>DZ Translit: Please provide URL</h1>\n");
    print("    <p>Enter address of a website (HTML) that contains letters from one or more non-Latin alphabets. You will get romanized contents of the page. ");
    print("       Questions, comments? Contact <a href=\"http://ufal.mff.cuni.cz/daniel-zeman/\">Dan Zeman</a>.</p>\n");
    print("    <form action='translit.pl' method=get>\n");
    print("      <input type=text name=url size=50 />\n");
    print("      Optional language code: <input type=text name=jazyk />\n");
    print("      <input type=submit name=submit value='Submit' />\n");
    print("    </form>\n");
    print("    <h2>Examples</h2>\n");
    print("    <ul>\n");
    print("      <li><a href=\"translit.pl?jazyk=ru&amp;url=https://ru.wikipedia.org/wiki/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9_%D1%8F%D0%B7%D1%8B%D0%BA\">ru</a> (článek o ruštině na ruské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=uk&amp;url=https://uk.wikipedia.org/wiki/%D0%A3%D0%BA%D1%80%D0%B0%D1%97%D0%BD%D1%81%D1%8C%D0%BA%D0%B0_%D0%BC%D0%BE%D0%B2%D0%B0\">uk</a> (článek o ukrajinštině na ukrajinské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=be&amp;url=https://be.wikipedia.org/wiki/%D0%91%D0%B5%D0%BB%D0%B0%D1%80%D1%83%D1%81%D0%BA%D0%B0%D1%8F_%D0%BC%D0%BE%D0%B2%D0%B0\">be</a> (článek o běloruštině na běloruské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=sr&amp;url=https://sr.wikipedia.org/wiki/%D0%A1%D1%80%D0%BF%D1%81%D0%BA%D0%B8_%D1%98%D0%B5%D0%B7%D0%B8%D0%BA\">sr</a> (článek o srbštině na srbské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=mk&amp;url=https://mk.wikipedia.org/wiki/%D0%9C%D0%B0%D0%BA%D0%B5%D0%B4%D0%BE%D0%BD%D1%81%D0%BA%D0%B8_%D1%98%D0%B0%D0%B7%D0%B8%D0%BA\">mk</a> (článek o makedonštině na makedonské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=bg&amp;url=https://bg.wikipedia.org/wiki/%D0%91%D1%8A%D0%BB%D0%B3%D0%B0%D1%80%D1%81%D0%BA%D0%B8_%D0%B5%D0%B7%D0%B8%D0%BA\">bg</a> (článek o bulharštině na bulharské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=el&amp;url=https://el.wikipedia.org/wiki/%CE%95%CE%BB%CE%BB%CE%B7%CE%BD%CE%B9%CE%BA%CE%AE_%CE%B3%CE%BB%CF%8E%CF%83%CF%83%CE%B1\">el</a> (článek o řečtině na řecké Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=hy&amp;url=https://hy.wikipedia.org/wiki/%D5%80%D5%A1%D5%B5%D5%A5%D6%80%D5%A5%D5%B6\">hy</a> (článek o arménštině na arménské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=ka&amp;url=https://ka.wikipedia.org/wiki/%E1%83%A5%E1%83%90%E1%83%A0%E1%83%97%E1%83%A3%E1%83%9A%E1%83%98_%E1%83%94%E1%83%9C%E1%83%90\">ka</a> (článek o gruzínštině na gruzínské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=am&amp;url=https://am.wikipedia.org/wiki/%E1%8A%A0%E1%88%9B%E1%88%AD%E1%8A%9B\">am</a> (článek o amharštině na amharské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=arc&amp;url=https://arc.wikipedia.org/wiki/%DC%9B%DC%98%DC%AA%DC%9D%DC%90\">arc</a> (článek o jazyce turoyo, verzi asyrštiny, na asyrské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=ar&amp;url=https://ar.wikipedia.org/wiki/%D9%84%D8%BA%D8%A9_%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9\">ar</a> (článek o arabštině na arabské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=fa&amp;url=https://fa.wikipedia.org/wiki/%D8%B2%D8%A8%D8%A7%D9%86_%D9%81%D8%A7%D8%B1%D8%B3%DB%8C\">fa</a> (článek o perštině na perské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=ur&amp;url=https://ur.wikipedia.org/wiki/%D8%A7%D8%B1%D8%AF%D9%88\">ur</a> (článek o urdštině na urdské Wikipedii)</li>\n");

    print("      <li><a href=\"translit.pl?jazyk=hi&amp;url=https://hi.wikipedia.org/wiki/%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80\">hi</a> (článek o hindštině na hindské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=pa&amp;url=https://pa.wikipedia.org/wiki/%E0%A8%AA%E0%A9%B0%E0%A8%9C%E0%A8%BE%E0%A8%AC%E0%A9%80_%E0%A8%AD%E0%A8%BE%E0%A8%B8%E0%A8%BC%E0%A8%BE\">pa</a> (článek o paňdžábštině na paňdžábské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=gu&amp;url=https://gu.wikipedia.org/wiki/%E0%AA%97%E0%AB%81%E0%AA%9C%E0%AA%B0%E0%AA%BE%E0%AA%A4%E0%AB%80_%E0%AA%AD%E0%AA%BE%E0%AA%B7%E0%AA%BE\">gu</a> (článek o gudžarátštině na gudžarátské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=bn&amp;url=https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%82%E0%A6%B2%E0%A6%BE_%E0%A6%AD%E0%A6%BE%E0%A6%B7%E0%A6%BE\">bn</a> (článek o bengálštině na bengálské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=or&amp;url=https://or.wikipedia.org/wiki/%E0%AC%93%E0%AC%A1%E0%AC%BC%E0%AC%BF%E0%AC%86_%E0%AC%AD%E0%AC%BE%E0%AC%B7%E0%AC%BE\">or</a> (článek o urijštině na urijské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=si&amp;url=https://si.wikipedia.org/wiki/%E0%B7%83%E0%B7%92%E0%B6%82%E0%B7%84%E0%B6%BD_%E0%B6%B7%E0%B7%8F%E0%B7%82%E0%B7%8F%E0%B7%80\">si</a> (článek o sinhálštině na sinhálské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=te&amp;url=https://te.wikipedia.org/wiki/%E0%B0%A4%E0%B1%86%E0%B0%B2%E0%B1%81%E0%B0%97%E0%B1%81\">te</a> (článek o telugštině na telugské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=kn&amp;url=https://kn.wikipedia.org/wiki/%E0%B2%95%E0%B2%A8%E0%B3%8D%E0%B2%A8%E0%B2%A1\">kn</a> (článek o kannadštině na kannadské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=ml&amp;url=https://ml.wikipedia.org/wiki/%E0%B4%AE%E0%B4%B2%E0%B4%AF%E0%B4%BE%E0%B4%B3%E0%B4%82\">ml</a> (článek o malajálamštině na malajálamské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=ta&amp;url=https://ta.wikipedia.org/wiki/%E0%AE%A4%E0%AE%AE%E0%AE%BF%E0%AE%B4%E0%AF%8D\">ta</a> (článek o tamilštině na tamilské Wikipedii)</li>\n");

    print("      <li><a href=\"translit.pl?jazyk=bo&amp;url=https://bo.wikipedia.org/wiki/%E0%BD%96%E0%BD%BC%E0%BD%91%E0%BC%8B%E0%BD%A6%E0%BE%90%E0%BD%91%E0%BC%8D\">bo</a> (článek o tibetštině na tibetské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=th&amp;url=https://th.wikipedia.org/wiki/%E0%B8%A0%E0%B8%B2%E0%B8%A9%E0%B8%B2%E0%B9%84%E0%B8%97%E0%B8%A2\">th</a> (článek o thajštině na thajské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=km&amp;url=https://km.wikipedia.org/wiki/%E1%9E%97%E1%9E%B6%E1%9E%9F%E1%9E%B6%E1%9E%81%E1%9F%92%E1%9E%98%E1%9F%82%E1%9E%9A\">km</a> (článek o khmerštině na khmerské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=zh&amp;url=https://zh.wikipedia.org/wiki/%E6%B1%89%E8%AF%AD\">zh</a> (článek o čínštině na čínské Wikipedii)</li>\n");
    print("      <li><a href=\"translit.pl?jazyk=ko&amp;url=https://ko.wikipedia.org/wiki/%ED%95%9C%EA%B5%AD%EC%96%B4\">ko</a> (článek o korejštině na korejské Wikipedii)</li>\n");
    print("    </ul>\n");
    print("  </body>\n");
    print("</html>\n");
}
else
{
    # Initialize the transliteration library.
    my $maxl = initialize(\%prevod, $config{jazyk});
    my $ua = htmlform::vytvorit_klienta();
    my $html = htmlform::get($ua, $config{url});
    # Decode HTML entities. Sometimes a foreign text looks entirely like this:
    # &#2986;&#3007;&#2985;&#3021;&#2984;&#2997;&#3008;&#2985;&#2980;&#3021;
    # Which would render the transliteration procedure useless.
    $html = decode_entities($html);
    # Convert relative links to absolute because now we are serving the content from a different domain.
    # Otherwise the hyperlinks to other pages (frames, form actions) would be lost.
    # More importantly, the page would look different from the original because links to images, styles and scripts would be broken.
    #my @debug;
    $html = htmlabspath::zabsolutnit_odkazy($html, $config{url}, \@debug);
    #my $debug_html = '<div lang="en" dir="ltr">'.join("\n", map {"<p>$_</p>"} (@debug)).'</div>';
    #$html =~ s:</body>:$debug_html\n</body>:i;
    ###!!! Change all https: links to http:. It may break them but it may also work. And the installation of Perl at quest currently
    ###!!! cannot handle https: communication, this is the error message:
    ###!!! LWP will support https URLs if either Crypt::SSLeay or IO::Socket::SSL is installed. More information at .
    $html =~ s-https://-http://-g;
    # Change links to proxy links.
    ###!!! All this should happen inside of a HTML Parser! Otherwise, we will fail to change links in framesets, and we might change text about URLs!
    $html =~ s-a href="http://-a href="?jazyk=$config{jazyk}&amp;url=http://-ig;
    #print($html);
    my $orig_html_length = length($html);
    #print("Length of original HTML document = $orig_html_length characters\n");
    my $starttime = time();
    #print("Start time = $starttime\n");
    my $translit_html = translit::prevest(\%prevod, $html, $maxl);
    $translit_html = translit::han2pinyin::pinyin($translit_html); ###!!! BETA
    # The transliterated text uses the Latin script, which is written left-to-right. If the original was right-to-left, try to change the instructions for the browser.
    # Also remove all language identifiers. It is no more the original language anyway, and we do not want Firefox to believe it should select fonts for us.
    $translit_html =~ s/dir="rtl"/dir="ltr"/g;
    $translit_html =~ s/lang="\w+"//g;
    print($translit_html);
    my $translit_html_length = length($translit_html);
    #print(cas::sestavit_hlaseni_o_trvani_programu($starttime));
    #print("Length of original HTML document = $orig_html_length characters\n");
    #print("Length of transliterated HTML document = $translit_html_length characters\n");
}



#------------------------------------------------------------------------------
# Initializes transliteration tables.
#------------------------------------------------------------------------------
sub initialize
{
    my $table = shift; # reference to hash
    my $language = shift; # optional source language code
    my $scientific = 1; # type of romanization
    my $maxl = translit::inicializovat_vse($table, $language, $scientific);
    return $maxl;
}
