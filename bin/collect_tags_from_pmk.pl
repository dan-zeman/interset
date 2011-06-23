#!/usr/bin/perl
# Přečte Pražský mluvený korpus, zapamatuje si všechny morfosyntaktické značky, vypíše jejich seznam a počet.
# Nesnaží se obecně rozebírat XML. Předpokládá, že prvky XML, které popisují jednu značku, leží bez mezery na jednom řádku za sebou.
# Copyright © 2009 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ":utf8";
# PMK používá kódování ISO 8859-2.
#binmode(STDIN, ":utf8");
binmode(STDIN, ":encoding(iso-8859-2)");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

while(<>)
{
    if(m/(<i\d+>.*<\/i\d+>)/)
    {
        $znacky{$1}++;
    }
}
foreach my $znacka (sort(keys(%znacky)))
{
    print("$znacka\n");
}
print STDERR ("Celkem nalezeno ", scalar(keys(%znacky)), " různých značek.\n");
# V pmk_kr.xml nalezeno 236 různých značek.
# V pmk_dl.xml nalezeno 10900 různých značek.
# Možných kombinací hodnot, které se v korpusu nevyskytly, bude samozřejmě ještě mnohem víc.
