#!/usr/bin/perl
# Načte seznam značek PDT, všechny překóduje do CoNLL, upraví je, aby se daly vložit do zdrojáku v Perlu, a vypíše je.
# (c) 2008 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use tagset::cs::pdt;
use tagset::cs::conll;

$seznam = tagset::cs::pdt::list();
foreach my $znacka (@{$seznam})
{
    my $fs = tagset::cs::pdt::decode($znacka);
    my $conll = tagset::cs::conll::encode($fs);
    $conll = upravit_pro_perl($conll);
    push(@vysledny_seznam, $conll);
}
# Značky obsahující rys Sem nemohou být vygenerovány ze seznamu značek PDT.
$cesta = "C:\\Documents and Settings\\Dan\\Dokumenty\\Lingvistika\\Data\\CoNLL\\2006\\czech\\pdt\\tags_with_sem_feature_set.txt";
open(SEM, $cesta) or die("Nelze cist $cesta: $!\n");
while(<SEM>)
{
    s/\r?\n$//;
    my $conll = upravit_pro_perl($_);
    push(@vysledny_seznam, $conll);
}
close(SEM);
@vysledny_seznam = sort(@vysledny_seznam);
foreach my $znacka (@vysledny_seznam)
{
    print("$znacka\n");
}



sub upravit_pro_perl
{
    my $conll = shift;
    # Zneškodnit znaky, které mají v Perlu zvláštní význam.
    $conll =~ s/([\\\$\@\%])/\\$1/g;
    # Přepsat tabulátor do perlového opisu, aby byl chráněný před rozmary editoru.
    $conll =~ s/\t/\\t/g;
    return $conll;
}
