package tagset::google;
use utf8;
use strict;
use warnings;
use Readonly;
use List::MoreUtils qw(none);

# Interset driver for the Google Universal Part-of-Speech Tagset
# http://code.google.com/p/universal-pos-tags/
# written by Martin Popel
# License: GNU GPL

# The whole documentation for Google Universal Part-of-Speech Tagset:
# VERB - verbs (all tenses and modes)
# NOUN - nouns (common and proper)
# PRON - pronouns 
# ADJ - adjectives
# ADV - adverbs
# ADP - adpositions (prepositions and postpositions)
# CONJ - conjunctions
# DET - determiners
# NUM - cardinal numbers
# PRT - particles or other function words
# X - other: foreign words, typos, abbreviations
# . - punctuation

my %DECODE = (
    VERB  => { pos => 'verb' },
    NOUN  => { pos => 'noun' },
    #PRON => { pos => [qw(noun adj)], prontype => [qw(prs rcp int rel dem neg ind tot)] }, # Interset does not support this solution so far,
    PRON  => { pos => 'noun', prontype => 'prs' },                                         # so we must use some silly "default" values.
    ADJ   => { pos => 'adj' },
    ADV   => { pos => 'adv' },
    ADP   => { pos => 'prep' },
    CONJ  => { pos => 'conj' },
    DET   => { pos => 'adj', subpos => 'det' },
    NUM   => { pos => 'num' },
    PRT   => { pos => 'part' },
    X     => { pos => 'int', },
    '.'   => { pos => 'punc' },
);

foreach my $tag ( keys %DECODE ) {
    $DECODE{$tag}{tagset} = 'google';
}

sub decode {
    my ($google_tag) = @_;
    return $DECODE{$google_tag}
}

sub encode {
    my ( $f, $nonstrict ) = @_;
    # PRON and DET must be tried first
    return 'PRON' if $f->{prontype};
    return 'DET' if $f->{subpos} eq 'det';
    my $pos = uc $f->{'pos'};
    return $pos if $DECODE{$pos};
    return 'ADP' if $pos eq 'PREP';
    return 'PRT' if $pos eq 'PART';
    return '.' if $pos eq 'PUNC';
    return 'X';
}

Readonly my $LIST => [ keys %DECODE ];

sub list {
    return $LIST;
}

1;
