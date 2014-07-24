package tagset::ro::rdt;
use utf8;
use strict;
use warnings;
use Readonly;
use List::MoreUtils qw(none);

# Interset driver for the Romanian Dependency Treebank (RDT) tagset.
# written by Martin Popel
# License: GNU GPL
# Brief tagset documentation in $TMT_ROOT/share/data/resources/treebanks/ro/2008_calacean.pdf
# Useful resource http://dexonline.ro

# ă â î ș ț

# NOTE:
# The original RDT annotation is *not consistent*:
# Four of the twenty POS tags and one dependency type appear only in the first 6% of the material, reducing significantly the POS tagset for the rest of the material. For instance, verbs and adjectives in participle form are annotated as such only in the first part of the material. On the other hand, the definite article POS tag is present only in the last 90% of the material.

my %DECODE = (
    'adjectiv'  => { pos => 'adj' },
    'adverb'    => { pos => 'adv' },
    'art. dem.' => { pos => 'adj', subpos => 'det', definiteness => 'def', prontype => 'dem' },                   # cel (demonstrative article, used only before adjectives "cel bun")
    'art. hot.' => { pos => 'adj', subpos => 'det', definiteness => 'def', poss => 'poss', gender => 'masc' },    # lui (definite article, used only in possessive constructions with male gender)
    'art. poses.' => { pos => 'adj', subpos => 'det', poss         => 'poss' },                                   # al, a, ai, ale (genitival/possessive article)
    'art. nehot.' => { pos => 'adj', subpos => 'art', definiteness => 'ind' },                                    # o, un, niște
    'conj. aux.'   => { pos => 'conj', subpos => 'sub' },
    'conj. coord.' => { pos => 'conj', subpos => 'coor' },
    'numeral'      => { pos => 'num' },
    'prepozitie'   => { pos => 'prep' },
    'pron. reflex.' => { pos => 'noun', prontype => 'prs', reflex => 'reflex' },                                  # se, ne, mă
    'pronume' => { pos => [qw(noun adj)], prontype => [qw(prs int rel neg tot)] },                                # care, ce, le, noi, nimic, totul
    'substantiv'   => { pos => 'noun' },
    'verb'         => { pos => 'verb', verbform => 'fin' },
    'verb aux.'    => { pos => 'verb', subpos => 'aux' },                                                         # a, au, fost, fi, vor, fie, este, sunt
    'verb nepred.' => { pos => 'verb', verbform => [qw(inf trans)] },                                             # fi (a fi = infinitive to be), cântând (transgressive, note that in Romainan it is called "gerunziu", but it is not a gerund like "doing" in English)

    # Due to inconsistent annotation, the following tags appear only in the test set :-(
    'verb la participiu' => { pos => 'verb', verbform => 'part' },
    'verb la infinitiv'  => { pos => 'verb', verbform => 'inf' },                                                 # iluminat (tagged as 'verb nepred.' in the rest of RDT)
    'adj. particip.'     => { pos => 'adj',  verbform => 'part' },                                                # TODO: is this combination valid in Interset?
    'pron. dem.'         => { pos => 'adj',  subpos   => 'det', prontype => 'dem' },                              # cel, aceasta
);

my @ENCODE = (
    'pos=num'                                   => 'numeral',
    'pos=prep'                                  => 'prepozitie',
    'pos=adv'                                   => 'adverb',
    'subpos=sub'                                => 'conj. aux.',
    'subpos=coor'                               => 'conj. coord.',
    'prontype=prs & reflex=reflex'              => 'pron. reflex',
    'prontype=prs|int|rel|neg|tot'              => 'pronume',
    'pos=noun'                                  => 'substantiv',
    'verbform=inf|trans'                        => 'verb nepred.',
    'subpos=aux'                                => 'verb aux.',
    'pos=verb'                                  => 'verb',
    'subpos=det & definiteness=ind'             => 'art. nehot.',
    'subpos=det & definiteness=def & poss=poss' => 'art. hot.',
    'subpos=det'                                => 'art. poses.',
    'pos=adj'                                   => 'adjectiv',
);

foreach my $tag ( keys %DECODE ) {
    $DECODE{$tag}{tagset} = 'ro:rdt';
}

sub decode {
    my ($rdt_tag) = @_;
    return $DECODE{$rdt_tag}
}

sub encode {
    my ( $f, $nonstrict ) = @_;
    my @rules = @ENCODE;
    RULE:
    while (@rules) {
        my $conjunction = shift @rules;
        my $tag         = shift @rules;
        my @conds       = split / & /, $conjunction;
        foreach my $cond (@conds) {
            my ( $cat, $val_regex ) = split /=/, $cond;
            my $v = $f->{$cat};
            next RULE if !defined $v;

            # Interset stores alternative values as an array ref, but single values are stored directly
            next RULE if none {/^$val_regex$/} ( ref $v ? @{$v} : $v );
        }

        # None of the conditions in the conjunction was rejected, so the rule matches
        return $tag;
    }

    # No rule matches
    # TODO: what should be returned in this case?
    return;
}

Readonly my $LIST => [ keys %DECODE ];

sub list {
    return $LIST;
}

1;
