#!/usr/bin/env perl
# Načte statistiku značek vypsanou Treexem, konkrétně tímto příkazem:
# treex -Lbn Read::Treex from='!data/treex/000_orig/{train,test}/*.treex.gz' Print::TagStats > tagstats.txt
# Vyhází přebytečné sloupce a vybrané rysy, které jsou v indických treebancích navíc (lex, head, name).
# Z výsledného seznamu odstraní duplikáty a vypíše ho na standardní výstup.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my %hash;
while(<>)
{
    chomp();
    # Přeskočit řádek se shrnutím.
    next if(m/^TOTAL \d+ TAG TYPES FOR \d+ TOKENS/);
    my @fields = split(/\t/, $_);
    # Potřebujeme pouze první tři pole, tj. CPOS, POS a FEAT.
    splice(@fields, 3);
    # Třetí pole jsou rysy, tam chceme odstranit lex, head a další rysy (jsou i v jiných jazycích, např. v perštině).
    my @features = grep {$_ !~ m/^(lex|head|name|coref|chunkId|chunkType|senID)[-=]/} (split(/\|/, $fields[2]));
    $fields[2] = join('|', @features);
    foreach my $field (@fields)
    {
        if($field eq '')
        {
            $field = '_';
        }
    }
    $hash{join("\t", @fields)}++;
}
foreach my $tag (sort(keys(%hash)))
{
    print("$tag\n");
}
