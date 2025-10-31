#!/usr/bin/perl
# Funkce pro přípravu transliterace z arménského písma do latinky.
# Copyright © 2009 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

package translit::armen;
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
    my %armen =
    (
        1329 => 'A',  # Ա ayb
        1330 => 'B',  # Բ ben
        1331 => 'G',  # Գ gim
        1332 => 'D',  # Դ da
        1333 => 'E',  # Ե ech (na začátku slova se čte "je", jinak "e")
        1334 => 'Z',  # Զ za
        1335 => "Ē",  # Է eh
        1336 => "Ə",  # Ը et
        1337 => "Tʰ", # Թ to (th)
        1338 => 'Ž',  # Ժ zhe
        1339 => 'I',  # Ի ini
        1340 => 'L',  # Լ liwn
        1341 => 'X',  # Խ xeh (čte se jako české "ch")
        1342 => 'C',  # Ծ ca (bez přídechu resp. s rázem)
        1343 => 'K',  # Կ ken
        1344 => 'H',  # Հ ho
        1345 => 'J', # Ձ ja (čte se "dz", ne "dž"; alternativní přepis "Ǳ")
        1346 => "Ğ",  # Ղ ghad
        1347 => 'Č',  # Ճ cheh (bez přídechu resp. s rázem)
        1348 => 'M',  # Մ men
        1349 => "Y",  # Յ yi (čte se jako české "j")
        1350 => 'N',  # Ն now
        1351 => 'Š',  # Շ sha
        1352 => 'O',  # Ո vo (na začátku slova se čte "vo", jinak "o")
        1353 => "Čʰ", # Չ cha (bez rázu popř. s přídechem)
        1354 => 'P',  # Պ peh
        1355 => "J̌",  # Ջ jheh (čte se "dž" nebo "š"; zdá se, že v zeměpisných názvech se to přepisuje jako š)
        1356 => "Ṙ",  # Ռ ra
        1357 => 'S',  # Ս seh
        1358 => 'V',  # Վ vew
        1359 => 'T',  # Տ tiwn
        1360 => 'R',  # Ր reh
        1361 => "Cʰ", # Ց co (bez rázu popř. s přídechem)
        1362 => 'W',  # Ւ yiwn, hiun
        1363 => "Pʰ", # Փ piwr, piur
        1364 => "Kʰ", # Ք keh
        1365 => "Ô",  # Օ oh
        1366 => 'F',  # Ֆ feh
        1377 => 'a',  # ա
        1378 => 'b',  # բ
        1379 => 'g',  # գ
        1380 => 'd',  # դ
        1381 => 'e',  # ե
        1382 => 'z',  # զ
        1383 => "ē",  # է eh
        1384 => "ə",  # ը et
        1385 => "tʰ", # թ to
        1386 => 'ž',  # ժ
        1387 => 'i',  # ի
        1388 => 'l',  # լ
        1389 => 'x',  # խ
        1390 => 'c',  # ծ
        1391 => 'k',  # կ ken
        1392 => 'h',  # հ
        1393 => 'j', # ձ ja (alternativní přepis "ǳ")
        1394 => "ğ",  # ղ ghat
        1395 => 'č',  # ճ cheh
        1396 => 'm',  # մ
        1397 => "y",  # յ
        1398 => 'n',  # ն
        1399 => 'š',  # շ
        1400 => 'o',  # ո
        1401 => "čʰ", # չ cha
        1402 => "p",  # պ peh
        1403 => "ǰ",  # ջ jheh (čte se "dž" nebo "š"; zdá se, že v zeměpisných názvech se to přepisuje jako š)
        1404 => "ṙ",  # ռ ra
        1405 => 's',  # ս
        1406 => 'v',  # վ
        1407 => 't',  # տ tiwn
        1408 => 'r',  # ր reh
        1409 => "cʰ", # ց co
        1410 => 'w',  # ւ yiwn, hiun
        1411 => "pʰ", # փ piwr, piur
        1412 => "kʰ", # ք keh
        1413 => "ô",  # օ oh
        1414 => 'f',  # ֆ
        1415 => 'ew', # և ligatura ECH-YIWN, tedy e+w
    );
    foreach my $kod (keys(%armen))
    {
        $prevod->{chr($kod)} = $armen{$kod};
    }
    # "u" se dnes považuje za jedno písmeno, ale je to kombinace vo+yiwn
    $prevod->{chr(1352).chr(1362)} = 'U';
    $prevod->{chr(1352).chr(1410)} = 'U';
    $prevod->{chr(1400).chr(1410)} = 'u';
    return $prevod;
}



1;
