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

my $driver = get_driver_object('fi::turku');
my $list = $driver->list();
my %map;
foreach my $tag (@{$list})
{
    # Zatím nemáme hotové metody decode() a encode(), ale chceme odstranit rys "up".
    #my @features = grep {$_ ne 'up'} split(/\|/, $tag);
    #my $tag1 = join('|', @features);
    my $fs = $driver->decode($tag);
    my $tag1 = $driver->encode($fs);
    $map{$tag1}++;
    # Dogenerovat chybějící kombinace rysů, u kterých jsme si jisti, že existují.
    #complete_features($tag);
    # Příliš mnoho informací se ukládá do rysu other. Chceme zajistit, aby i značky, které vzniknou, když tyto informace nebudou k dispozici, byly platné.
    $fs->set('other', '');
    my $tag2 = $driver->encode($fs);
    $map{$tag2}++;
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
