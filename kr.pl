#!/usr/bin/perl

use LWP::Simple;
#$content = get("http://www.wonkwang.ac.kr/college/college-main1_1.htm");
$content = get("$ARGV[0]");
$content =~ s/\s+/ /sg;
$content =~ s/<(head|style|script)[^>]*>.*?<\/\1>//ig;
$content =~ s/<!--.*?-->//g;
$content =~ s/<.*?>//g;
$content =~ s/&nbsp;/ /g;
$content =~ s/\s+/ /g;
$content = dekodovat_utf8($content);
# 59393 prvni dalsi (zacina "oblast osobniho pouziti")
# ga gga na da dda ra ma ba bba sa ssa a ja jja cha ka ta pa ha
# ga gae gya gyae geo ge gyeo gye go gwa gwae goe gyo gu gweo gwe gwi gyu geu gyi gi
# ga gag gagg gags gan ganj ganh gad gar garg garm garb gars gart garp garh gam gab gabs gas gass gang gaj gach gak gat gap gah
@init = ("g", "gg", "n", "d", "dd", "r", "m", "b", "bb", "s", "ss", "", "j", "jj", "ch", "k", "t", "p", "h");
@vowl = ("a", "ae", "ya", "yae", "eo", "e", "yeo", "ye", "o", "wa", "wae", "oe", "yo", "u", "weo", "we", "wi", "yu", "eu", "yi", "i");
@stop = ("", "g", "gg", "gs", "n", "nj", "nh", "d", "r", "rg", "rm", "rb", "rs", "rt", "rp", "rh", "m", "b", "bs", "s", "ss", "ng", "j", "ch", "k", "t", "p", "h");
for($i=0; $i<length($content); $i++)
{
    my $kod = ord(substr($content, $i, 1));
    # Slabiky hangul (AC00-D7A3) = (44032-55203)
    if($kod>=44032 && $kod<55204)
    {
        $init = int(($kod-44032)/588);
        $vowl = int(($kod-(44032+588*$init))/28);
        $stop = $kod-(44032+588*$init+28*$vowl);
#        print(" $init-$vowl-$stop");
        print(".$init[$init]$vowl[$vowl]$stop[$stop]");
    }
    else
    {
        print(chr($kod));
    }
}



# Dekóduje UTF-8. Potøebuju tuhle proceduru, proto¾e Perl 5.6.1 je¹tì neposkytuje zpùsob, jak øíct, ¾e text ètený ze
# souboru je kódován v UTF-8. Vnitøní kódování øetìzcù u¾ ale je unikódové, tak¾e staèí pøeètené znaky zase zapsat.
sub dekodovat_utf8
{
    my $bsingle  = 0;   # 0....... samostatný bajt odpovídající jedinému (ASCII) znaku (0000-007F)
    my $bslave   = 128; # 10...... druhý a¾ ètvrtý bajt znaku
    my $bmaster2 = 192; # 110..... první ze dvou  (0080-07FF)
    my $bmaster3 = 224; # 1110.... první ze tøí   (0800-FFFF)
    my $bmaster4 = 240; # 11110... první ze ètyø (10000-FFFFF)
    my @intext = split(//, $_[0]);
    my @unicodes;
    my $nexl = 0; # number of expected slave bytes
    my $i;
    for($i = 0; $i<=$#intext; $i++)
    {
        my $byte = ord($intext[$i]);
        # Zjistit, zda je to ASCII.
        if(($byte & 128) == 0) # $byte & 10000000
        {
            $nexl = 0;
            # Ulo¾it bajt.
            $unicodes[++$#unicodes] = $byte;
        }
        # Není-li to ASCII, zjistit, zda je to zaèátek dvoubajtového znaku.
        elsif(($byte & 224) == $bmaster2) # $byte & 11100000 == 11000000
        {
            # Odstranit z bajtu hlavièku 110.
            $byte = $byte & 31; # $byte & 00011111
            # Udìlat místo na bity, které je¹tì oèekáváme.
            $byte = $byte << 6;
            $nexl = 1;
            # Ulo¾it ji¾ naètenou èást bajtu.
            $unicodes[++$#unicodes] = $byte;
        }
        # Není-li to ani dvoubajtové, zjistit, zda je to zaèátek tøíbajtového znaku.
        elsif(($byte & 240) == $bmaster3) # $byte & 11110000 == 11100000
        {
            # Odstranit z bajtu hlavièku 1110.
            $byte = $byte & 15; # $byte & 00001111
            # Udìlat místo na bity, které je¹tì oèekáváme.
            $byte = $byte << 12;
            $nexl = 2;
            # Ulo¾it ji¾ naètenou èást bajtu.
            $unicodes[++$#unicodes] = $byte;
        }
        # Není-li to ani tøíbajtové, zjistit, zda je to zaèátek ètyøbajtového znaku.
        elsif(($byte & 248) == $bmaster4) # $byte & 11111000 == 11110000
        {
            # Odstranit z bajtu hlavièku 11110.
            $byte = $byte & 7; # $byte & 00000111
            # Udìlat místo na bity, které je¹tì oèekáváme.
            $byte = $byte << 18;
            $nexl = 3;
            # Ulo¾it ji¾ naètenou èást bajtu.
            $unicodes[++$#unicodes] = $byte;
        }
        # Není-li to zaèátek vícebajtové sekvence, zjistit, zda je to její pokraèování.
        elsif(($byte & 192) == $bslave) # $byte & 11000000 == 10000000
        {
            if($nexl<1)
            {
                die("Neocekavany slave byte v UTF-8 je divny.\n");
            }
            # Odstranit z bajtu hlavièku 10.
            $byte = $byte & 63; # $byte & 00111111
            # Pokud je¹tì oèekáváme dal¹í bity, udìlat na nì místo.
            $nexl--;
            $byte = $byte << ($nexl*6);
            # Pøiorovat právì naètenou èást znaku k èástem naèteným døíve.
            $unicodes[$#unicodes] = $unicodes[$#unicodes] | $byte;
        }
        # Není-li to nic z vý¹e uvedeného, je to asi chyba.
        else
        {
            die("Vice nez 4-bytovy kod v UTF-8 je divny.\n");
        }
    }
    # Udìlat z unikódù text.
    my $outext;
    for($i = 0; $i<=$#unicodes; $i++)
    {
        $outext .= chr($unicodes[$i]);
    }
    return $outext;
}
