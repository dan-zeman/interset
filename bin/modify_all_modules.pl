#!/usr/bin/env perl
# Projde všechny moduly *.pm v Intersetu a upraví řádek s verzí modulu.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use find;

$n_modified = 0;
find::go("C:\\Users\\Dan\\Documents\\Lingvistika\\Projekty\\interset\\lib\\Lingua", \&print);
print("Celkem $n_modified modulu.\n");



#------------------------------------------------------------------------------
# Ukázková callback funkce, která vytiskne úplnou cestu k objektu na standardní
# výstup. Její návratová hodnota říká, zda se máme vnořit do aktuálního objektu
# (tj. za předpokladu, že druh objektu je drx, tedy složka, do které smíme
# vstoupit).
#------------------------------------------------------------------------------
sub print
{
    my $cesta = shift;
    my $objekt = shift;
    my $druh = shift;
    if($objekt =~ m/\.pm$/)
    {
        my $hit = 0;
        my $source;
        open(PM, "$cesta/$objekt") or die("Cannot open $cesta/$objekt: $!");
        while(<PM>)
        {
            if(m/\#\s*VERSION/)
            {
                $hit++;
                $source .= "our \$VERSION = '2.031';\n";
            }
            else
            {
                $source .= $_;
            }
        }
        close(PM);
        # Make sure we only produce LF line breaks even if this script is run on Windows.
        my @chars = split(//, $source);
        my $m = scalar(@chars);
        @chars = grep {ord($_) != 13} @chars;
        my $n = scalar(@chars);
        $source = join('', @chars);
        print("$cesta/$objekt ... $hit ... $m => $n\n");
        open(PM, ">$cesta/$objekt") or die("Cannot write $cesta/$objekt: $!");
        binmode(PM); # no text file, no CRLF output on Windows
        print PM ($source);
        close(PM);
        $n_modified++;
    }
    return $druh eq 'drx';
}
