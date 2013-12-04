#!/usr/bin/env perl
# Vypíše přibližný seznam značek pro Ajku. Protože nemáme k dispozici skutečný
# seznam značek, které Ajka generuje, převedeme všechny značky z PDT do Ajky,
# odstraníme případné duplikáty a vypíšeme tohle. Pokud ale Ajka umí něco, co
# v PDT není zachyceno, tak to v seznamu prostě bude chybět.
# Copyright © 2013 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use tagset::common;
use tagset::cs::pdt;
use tagset::cs::ajka;

my $seznam_pdt = tagset::cs::pdt::list();
my %mapa_ajka;
foreach my $znacka (@{$seznam_pdt})
{
    my $fs = tagset::cs::pdt::decode($znacka);
    my $aj = tagset::cs::ajka::encode($fs);
    $mapa_ajka{$aj}++;
}
my $n = 0;
foreach my $znacka (sort(keys(%mapa_ajka)))
{
    print("$znacka\n");
    $n++;
}
my $m = scalar(@{$seznam_pdt});
print("CELKEM $m --> $n\n");
