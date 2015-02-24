#!/usr/bin/env perl
# Reads the list of known tags, decodes them and encodes again. As a result, the features are in the canonical order.
# Some features or entire tags can be filtered if desired. This is a one-time action and the exact behavior must be specified by editing this source code.
# We typically need this script during the development of a new driver.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Lingua::Interset qw(get_driver_object);

my $driver = get_driver_object('te::conll');
my $action = 'other';
my $list = $driver->list();
my %map;
foreach my $tag (@{$list})
{
    my $tag1 = $tag;
    # Zatím nemáme hotové metody decode() a encode(), ale chceme upravit seznam značek z třísloupcového CoNLL formátu na jeho část.
    if($action eq 'deconll')
    {
        my ($pos, $subpos, $features) = split(/\s+/, $tag);
        $tag1 = "$subpos\t$features";
    }
    # Zatím nemáme hotové metody decode() a encode(), ale chceme vyhodit některé rysy, které nemají být součástí značky.
    if($action eq 'remove_features')
    {
        my ($pos, $features) = split(/\s+/, $tag);
        my @features = map {s/^(vib|tam)-0(_avy)?$/$1-/; s/-any$/-/; $_} (grep {$_ !~ m/^((posl)?cat|pbank|stype|voicetype)-/} (split(/\|/, $features)));
        $features = join('|', @features);
        $tag1 = "$pos\t$features";
    }
    # If we have implemented decode() and encode(), we can use them to normalize permutations of features.
    my $fs;
    if($action eq 'recode' || $action eq 'other')
    {
        $fs = $driver->decode($tag);
        $tag1 = $driver->encode($fs);
    }
    $map{$tag1}++;
    # Dogenerovat chybějící kombinace rysů, u kterých jsme si jisti, že existují.
    #complete_features($tag);
    # Too much information is stored in the 'other' feature.
    # We want to make sure that even if the 'other' feature is not available, the encoder will produce only known (valid) tags.
    if($action eq 'other')
    {
        $fs->set('other', '');
        my $tag2 = $driver->encode($fs);
        $map{$tag2}++;
    }
}
my @list1 = sort(keys(%map));
foreach my $tag (@list1)
{
    print("$tag\n");
}



#------------------------------------------------------------------------------
# For selected tags adds all similar tags with certain feature changed. This
# function is used e.g. to ensure that all combinations of case and number of
# nouns are included.
#------------------------------------------------------------------------------
sub complete_features
{
    my $tag = shift;
    my $fs = $driver->decode($tag);
    if($fs->is_noun() || $fs->is_adjective() || $fs->is_numeral())
    {
        my $case = $fs->case();
        my $number = $fs->number();
        if($case ne '' && $number ne '')
        {
            foreach my $c (qw(nom gen par ess tra ine ela ill ade abl all abe com ins))
            {
                foreach my $n (qw(sing plur))
                {
                    $fs->set('case', $c);
                    $fs->set('number', $n);
                    my $tag1 = $driver->encode($fs);
                    $map{$tag1}++;
                }
            }
        }
    }
    elsif($fs->is_verb())
    {
        my $person = $fs->person();
        my $number = $fs->number();
        if($person ne '' && $number ne '')
        {
            foreach my $n (qw(sing plur))
            {
                foreach my $p (1, 2, 3)
                {
                    $fs->set('person', $p);
                    $fs->set('number', $n);
                    my $tag1 = $driver->encode($fs);
                    $map{$tag1}++;
                }
            }
        }
    }
}
