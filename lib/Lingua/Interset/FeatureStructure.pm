#!/usr/bin/env perl
# The main class of DZ Interset 2.0.
# It defines all morphosyntactic features and their values.
# Copyright © 2008-2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Lingua::Interset::FeatureStructure;
use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use Carp;
our $VERSION; BEGIN { $VERSION = "2.00" }



# Should the features have their own classes, too?
# Pluses:
# + We could bind all properties of one feature tighter (its name, its priority, list of values and their intuitive ordering, list of default value changes).
# + There would be more space for additional services such as documentation and examples of the feature values.
# Minuses:
# - It is good to have them all together here. Better overall picture, mutual relations checking etc. If they are spread across 30 files, the picture will be lost.
# - Handling classes might turn out to be more complicated than handling simple attributes?
# - Perhaps efficiency issues?

# We want to know the following about the features:
# 1. List of known feature names
# 1.1. Each feature named using the 'has' keyword of Moose
# 1.2. Print order of features, i.e. the order in which we want to sort a list of features when printed
# 1.3. Default priority order of features, to be used when restricting value combinations (can be overriden for particular tagsets)
# 2. For each feature, list of known values
# 2.1. Each value named using the 'enum' keyword of Moose to trigger Moose data validation
# 2.2. Print order of values, e.g. we want to print 'sing' before 'plu' although alphabetical order says otherwise
# 3. For each value, order in which the other values should be considered as replacements when value restrictions are in effect

# Solution: One big matrix of features, values and their properties follows.
# The Moose declarations will be simply derived from the matrix below.
# The order of the features and values in the matrix is their print order.
# Default priority order of features is defined by the 'priority' values, ascending.

# Help to the replacement arrays:

# What follows is an attempt to describe the system of value replacements
# in an easily readable and maintainable way. The algorithm to process it
# may be complicated but the human interpretation should (hopefully) be simple.

# Rule 1: Values of each feature are ordered. This is the order of priority
#         when searching for replacement of an empty value.
# Rule 2: A non-empty value is replaced by empty value in the first place.
#         If the empty value is not permitted, it is replaced according to
#         Rule 1.
# Rule 3: Some values of some features have customized replacement sequences.
#         They contain replacements that are used prior to the default empty value.
#         For instance, if we have pos=det (determiner), we want to try
#         pos=adj (adjective) first, and only if this value is not permitted,
#         we default to the empty value.
#         Customized replacement sequences, if present, are specified
#         immediately next to the value being replaced (in one array).
#         The last element is a link: if we pass this value, we proceed to
#         its own customized replacement sequence. If the value does not
#         have a customized replacement sequence or if the link constitutes
#         a loop, proceed as if replacing an empty value according to Rule 1.

# The empty value does not need to be specified in the main (top-down) list
# of values of a feature. However, should a customized replacement sequence
# (left-to-right list) contain an empty value, it must explicitely state it.

# The algorithm:
# $valord{$feature}[$first][$second]
# 1. Find the 2D array according to feature name.
# 2. Find the value to be replaced in the first dimension.
# 3. Try to find replacement in the second dimension (respect ordering).
# 4. If unsuccessful and the second dimension has more than one member, try to replace the last member (go back to step 2). Check loops!
# 5. In case of a loop go to next step and act as if there was only one member.
# 6. If unsuccessful and the second dimension has only one member (the value to replace), check empty value as replacement.
# 7. If unsuccessful, try to find replacement in the first dimension (respect ordering).

# Since the order of the hash keys is important (it encodes the print order of the features),
# also store the hash as array (we will subsequently separate the keys from the values).
my @_matrix;
my %matrix = @_matrix =
(
    # Main part of speech
    ###!!! RENAME prep to adp (adposition)?
    'pos' =>
    {
        'priority' => 10,
        'values'   => ['noun', 'adj', 'num', 'verb', 'adv', 'prep', 'conj', 'part', 'int', ''],
        'replacements' =>
        [
            ['part'        ],
            ['noun', 'verb'],
            ['verb'        ],
            ['punc'        ],
            ['adj',  'noun'],
            ['num',  'adj' ],
            ['adv'         ],
            ['prep', 'adv' ],
            ['conj', 'prep'],
            ['int'         ]
        ],
    },
    # Subpart of speech.
    ###!!! This feature will probably be dissolved into several POS-specific features or something.
    'subpos' =>
    {
        'priority' => 190,
        'values' => ['mod', 'ex', 'voc', 'post', 'circ', 'preppron', 'comprep', 'emp', 'res', 'inf', 'vbp', ''],
        'replacements' =>
        [
            ['mod'],
            ['ex'],
            ['voc'],
            ['post'],
            ['circ'],
            ['preppron'],
            ['comprep'],
            ['emp'],
            ['res'],
            ['inf'],
            ['vbp']
        ],
    },
    # Special type of noun if applicable and if known.
    ###!!! NEW FEATURE (from subpos)
    'nountype' =>
    {
        'priority' => 80,
        'values' => ['com', 'prop', 'class', ''],
        'replacements' =>
        [
            ['com'],
            ['prop'],
            ['class'],
        ],
    },
    # Special type of adjective if applicable and if known.
    ###!!! NEW FEATURE (from subpos)
    'adjtype' =>
    {
        'priority' => 90,
        'values' => ['pdt', 'det', 'art', ''],
        'replacements' =>
        [
            ['pdt'],
            ['det'],
            ['art', 'det'],
        ],
    },
    # Pronominality and its type for nouns (pronouns), adjectives (determiners), numerals, adverbs etc.
    ###!!! NEW VALUE prn ... pronominal, without knowing the exact type
    'prontype' =>
    {
        'priority' => 100,
        'values' => ['prn', 'prs', 'rcp', 'int', 'rel', 'dem', 'neg', 'ind', 'tot', ''],
        'replacements' =>
        [
            ['prn'],
            ['ind'],
            ['dem'],
            ['prs'],
            ['rcp', 'prs'],
            ['int', 'rel'],
            ['rel', 'int'],
            ['neg', 'ind'],
            ['tot', 'ind'],
        ],
    },
    # Numeral types.
    ###!!! Note that it is currently not guaranteed that pos eq 'num'. (Nor do I find such cross-feature implications desirable.)
    ###!!! For instance, ordinal numbers are often classified as adjectives.
    ###!!! We may want to consider restricting pos = 'num' to cardinal numbers.
    'numtype' =>
    {
        'priority' => 110,
        'values' => ['card', 'ord', 'mult', 'frac', 'gen', 'dist', ''],
        'replacements' =>
        [
            ['card', '', 'ord'],
            ['ord', '', 'card'],
            ['mult', 'card'],
            ['frac', 'card'],
            ['gen', 'card'],
            ['dist', 'card']
        ],
    },
    # Presentation form of numerals.
    'numform' =>
    {
        'priority' => 120,
        'values' => ['word', 'digit', 'roman', ''],
        'replacements' =>
        [
            ['word'],
            ['digit', 'roman'],
            ['roman', 'digit']
        ],
    },
    # Numeric value (class of values) of numerals.
    # Some low-value numerals in some languages behave differently.
    'numvalue' =>
    {
        'priority' => 130,
        'values' => ['1', '2', '3', ''],
        'replacements' =>
        [
            ['1'],
            ['2', '3'],
            ['3', '2']
        ],
    },
    # Special type of verb if applicable and if known.
    ###!!! NEW FEATURE (from subpos)
    'verbtype' =>
    {
        'priority' => 140,
        'values' => ['aux', 'cop', 'mod', 'verbconj', ''],
        'replacements' =>
        [
            ['aux'],
            ['cop', 'aux'],
            ['mod', 'aux'],
            ['verbconj'],
        ],
    },
    # Semantic type of adverb.
    'advtype' =>
    {
        'priority' => 150,
        'values' => ['man', 'loc', 'tim', 'deg', 'cau', ''],
        'replacements' =>
        [
            ['man'],
            ['loc'],
            ['tim'],
            ['deg'],
            ['cau']
        ],
    },
    # Conjunction type.
    ###!!! NEW FEATURE (from subpos)
    'conjtype' =>
    {
        'priority' => 160,
        'values' => ['coor', 'sub', 'comp', ''],
        'replacements' =>
        [
            ['coor'],
            ['sub'],
            ['comp'],
        ],
    },
    # Punctuation type.
    'punctype' =>
    {
        'priority' => 170,
        'values' => ['peri', 'qest', 'excl', 'quot', 'brck', 'comm', 'colo', 'semi', 'dash', 'symb', 'root', ''],
        'replacements' =>
        [
            ['colo'],
            ['comm', 'colo'],
            ['peri', 'colo'],
            ['qest', 'peri'],
            ['excl', 'peri'],
            ['quot', 'brck'],
            ['brck', 'quot'],
            ['semi', 'comm'],
            ['dash', 'colo'],
            ['symb'],
            ['root']
        ],
    },
    # Distinction between opening and closing brackets and other paired punctuation.
    'puncside' =>
    {
        'priority' => 180,
        'values' => ['ini', 'fin', ''],
        'replacements' =>
        [
            ['ini'],
            ['fin']
        ],
    },
    # Syntactic part of speech.
    ###!!! DO WE STILL NEED THIS?
    # It was originally used with pronouns and numerals that behaved syntactically as nouns, adjectives or even adverbs.
    # The problem of pronouns has been solved by making pronominality a separate feature.
    # If we do something similar with numerals (but what about cardinals?), the synpos feature will probably become superfluous.
    # Before removing the feature we should analyze all existing tagsets to see which tagsets set synpos and where.
    'synpos' =>
    {
        'priority' => 200,
        'values' => ['subst', 'attr', 'adv', 'pred', ''],
        'replacements' =>
        [
            ['subst'],
            ['attr'],
            ['adv'],
            ['pred']
        ],
    },
    #--------------------------------------------------------------------------
    # For the following group of almost-boolean attributes I am not sure what would be the best internal representation.
    # Many of them constitute a distinct part of speech in some tagsets but they are in principle orthogonal to the part-of-speach feature.
    # However, regardless the representation, I would like the setter (writer) method to accept boolean values (zero/nonzero), too.
    # Possessivity.
    'poss' =>
    {
        'priority' => 210,
        'values' => ['poss', ''], ###!!! OR yes-no-empty? But I do not think it would be practical.
        'replacements' =>
        [
            ['poss']
        ],
    },
    # Reflexivity.
    'reflex' =>
    {
        'priority' => 220,
        'values' => ['reflex', ''], ###!!! OR yes-no-empty? But I do not think it would be practical.
        'replacements' =>
        [
            ['reflex']
        ],
    },
    # Foreign word? (Not a loanword but a quotation from a foreign language.)
    'foreign' =>
    {
        'priority' => 400,
        'values' => ['foreign', ''], ###!!! OR yes-no-empty? But I do not think it would be practical.
        'replacements' =>
        [
            ['foreign']
        ],
    },
    # Abbreviation?
    'abbr' =>
    {
        'priority' => 20,
        'values' => ['abbr', ''], ###!!! OR yes-no-empty? But I do not think it would be practical.
        'replacements' =>
        [
            ['abbr']
        ],
    },
    # Is this a part of a hyphenated compound?
    # Typically one part gets a normal part of speech and the other gets this flag.
    # Whether this is the first or the second part depends on the original tagset and language.
    'hyph' =>
    {
        'priority' => 30,
        'values' => ['hyph', ''], ###!!! OR yes-no-empty? But I do not think it would be practical.
        'replacements' =>
        [
            ['hyph']
        ],
    },
    # Is this / does this word contain a typo?
    'typo' =>
    {
        'priority' => 430,
        'values' => ['typo', ''], ###!!! OR yes-no-empty? But I do not think it would be practical.
        'replacements' =>
        [
            ['typo']
        ],
    },
    # Is this a reduplicated or echo word?
    'echo' =>
    {
        'priority' => 40,
        'values' => ['rdp', 'ech', ''],
        'replacements' =>
        [
            ['rdp', 'ech'],
            ['ech', 'rdp']
        ],
    },
    # Negativeness (presence of negative morpheme in languages and word classes where applicable).
    'negativeness' =>
    {
        'priority' => 240,
        'values' => ['pos', 'neg', ''],
        'replacements' =>
        [
            ['pos'],
            ['neg']
        ],
    },
    # Definiteness (or state in Arabic).
    'definiteness' =>
    {
        'priority' => 250,
        'values' => ['ind', 'def', 'red', 'com', ''],
        'replacements' =>
        [
            ['ind'],
            ['def'],
            ['red', 'def'],
            ['com', 'red', 'def']
        ],
    },
    # Gender.
    'gender' =>
    {
        'priority' => 300,
        'values' => ['masc', 'fem', 'com', 'neut', ''],
        'replacements' =>
        [
            ['neut'],
            ['com', 'masc', 'fem'],
            ['masc', 'com'],
            ['fem', 'com']
        ],
    },
    # Animateness (considered part of gender in some tagsets, but still orthogonal).
    'animateness' =>
    {
        'priority' => 310,
        'values' => ['anim', 'nhum', 'inan', ''],
        'replacements' =>
        [
            ['anim'],
            ['nhum', 'anim'],
            ['inan']
        ],
    },
    # Grammatical number.
    'number' =>
    {
        'priority' => 320,
        'values' => ['sing', 'dual', 'plu', 'ptan', 'coll', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plu'],
            ['plu'],
            ['ptan', 'plu'],
            ['coll', 'sing']
        ],
    },
    # Grammatical case.
    'case' =>
    {
        'priority' => 330,
        'values' => ['nom', 'gen', 'dat', 'acc', 'voc', 'loc', 'ins', 'ist',
                     'abl', 'del', 'par', 'dis', 'ess', 'tra', 'com', 'abe', 'ine', 'ela', 'ill', 'ade', 'all', 'sub', 'sup', 'lat',
                     'add', 'tem', 'ter', 'abs', 'erg', 'cau', 'ben', ''],
        'replacements' =>
        [
            ['nom'],
            ['acc'],
            ['dat', 'ben'],
            ['gen'],
            ['loc', 'ine', 'ade', 'sup', 'tem'],
            ['ins'],
            ['voc'],
            ['abl', 'del', 'lat', 'loc'],
            ['del', 'abl', 'lat', 'loc'],
            ['par', 'gen'],
            ['dis'],
            ['ess'],
            ['tra'],
            ['com', 'ins'],
            ['abe'],
            ['ine', 'loc'],
            ['ela', 'loc'],
            ['ill', 'lat', 'loc'],
            ['add', 'ill'],
            ['ade', 'sup', 'loc'],
            ['sup', 'ade', 'loc'],
            ['all', 'sub', 'lat', 'loc'],
            ['sub', 'all', 'lat', 'loc'],
            ['lat', 'all', 'sub', 'loc'],
            ['tem', 'loc'],
            ['ter', 'ill'],
            ['abs', 'nom', 'acc'],
            ['erg', 'nom'],
            ['cau'],
            ['ben', 'dat']
        ],
    },
    # Is this a special form (case) after a preposition?
    # Typically applies to personal pronouns, e.g. in Czech and Portuguese.
    'prepcase' =>
    {
        'priority' => 340,
        'values' => ['npr', 'pre', ''],
        'replacements' =>
        [
            ['npr'],
            ['pre']
        ],
    },
    # Degree of comparison.
    'degree' =>
    {
        'priority' => 230,
        'values' => ['pos', 'comp', 'sup', 'abs', ''],
        'replacements' =>
        [
            ['pos'],
            ['comp'],
            ['sup', 'comp'],
            ['abs', 'sup']
        ],
    },
    # Person.
    'person' =>
    {
        'priority' => 260,
        'values' => ['1', '2', '3', ''],
        'replacements' =>
        [
            ['3'],
            ['1'],
            ['2']
        ],
    },
    # Politeness, formal vs. informal word forms.
    'politeness' =>
    {
        'priority' => 350,
        'values' => ['inf', 'pol', ''],
        'replacements' =>
        [
            ['inf'],
            ['pol']
        ],
    },
    # Possessor's gender. (The gender feature typically holds the possession's gender in this case.)
    'possgender' =>
    {
        'priority' => 360,
        'values' => ['masc', 'fem', 'com', 'neut', ''],
        'replacements' =>
        [
            ['neut'],
            ['com', 'masc', 'fem'],
            ['masc', 'com'],
            ['fem', 'com']
        ],
    },
    # Possessor's person.
    # Used e.g. in Hungarian where possessive morphemes can be attached to possessed nouns ("apple-mine").
    'possperson' =>
    {
        'priority' => 370,
        'values' => ['1', '2', '3', ''],
        'replacements' =>
        [
            ['3'],
            ['1'],
            ['2']
        ],
    },
    # Possessor's number.
    'possnumber' =>
    {
        'priority' => 380,
        'values' => ['sing', 'dual', 'plu', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plu'],
            ['plu']
        ],
    },
    # Possession's number.
    # In Hungarian, it is possible (though rare) that a noun has three numbers:
    # 1. its own grammatical number; 2. number of its possessor; 3. number of its possession.
    'possednumber' =>
    {
        'priority' => 390,
        'values' => ['sing', 'dual', 'plu', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plu'],
            ['plu']
        ],
    },
    # Subcategorization.
    # So far this feature only keeps the transitive-intransitive distinction encoded in some tagsets.
    # However, real verb subcategorization is in fact much more complex.
    'subcat' =>
    {
        'priority' => 50,
        'values' => ['intr', 'tran', ''],
        'replacements' =>
        [
            ['intr'],
            ['tran']
        ],
    },
    # Verb form.
    ###!!! Combine this feature with mood? Non-empty mood seems to always imply verbform=fin.
    ###!!! On the other hand, we may want to make some verb forms self-standing parts of speech:
    # part (participle, properties of both verbs and adjectives)
    # ger (gerund, properties of both verbs and nouns)
    # trans (transgressive, properties of both verbs and adverbs)
    'verbform' =>
    {
        'priority' => 60,
        'values' => ['fin', 'inf', 'sup', 'part', 'trans', 'ger', ''],
        'replacements' =>
        [
            ['inf'],
            ['fin'],
            ['part'],
            ['ger'],
            ['sup'],
            ['trans']
        ],
    },
    # Mood.
    'mood' =>
    {
        'priority' => 70,
        'values' => ['ind', 'imp', 'cnd', 'pot', 'sub', 'jus', 'qot', ''],
        'replacements' =>
        [
            ['ind'],
            ['imp'],
            ['cnd', 'sub'],
            ['pot', 'cnd'],
            ['sub', 'cnd', 'jus'],
            ['jus', 'sub'],
            ['qot', 'ind']
        ],
    },
    # Tense.
    ###!!! In contrast to DZ Interset 1, the subtense feature is now incorporated here.
    ###!!! There are other hierarchical features anyway (case, number...)
    'tense' =>
    {
        'priority' => 270,
        'values' => ['pres', 'fut', 'past', 'aor', 'imp', 'pqp', ''],
        'replacements' =>
        [
            ['pres'],
            ['fut'],
            ['past', 'aor', 'imp'],
            ['aor', 'past'],
            ['imp', 'past'],
            ['pqp', 'past']
        ],
    },
    # Voice.
    'voice' =>
    {
        'priority' => 280,
        'values' => ['act', 'pass', ''],
        'replacements' =>
        [
            ['act'],
            ['pass']
        ],
    },
    # Aspect (lexical or grammatical; but see also the 'imp' tense).
    'aspect' =>
    {
        'priority' => 290,
        'values' => ['imp', 'perf', 'pro', ''],
        'replacements' =>
        [
            ['imp'],
            ['perf'],
            ['pro']
        ],
    },
    # Variant. Used in some tagsets to distinguish between forms of the same lemma that would otherwise get the same tag.
    # The meaning of the values is not and cannot be universal, not even within the scope of one tagset.
    'variant' =>
    {
        'priority' => 440,
        'values' => ['short', 'long', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ''],
        'replacements' =>
        [
            ['0'],
            ['1'],
            ['2'],
            ['3'],
            ['4'],
            ['5'],
            ['6'],
            ['7'],
            ['8'],
            ['9'],
            ['short'],
            ['long']
        ],
    },
    # Style.
    # Either lexical category of the lemma, or grammatical
    # (e.g. standard and colloquial suffix of the same lemma, cf. Czech "zelený" vs. "zelenej").
    'style' =>
    {
        'priority' => 420,
        'values' => ['arch', 'form', 'norm', 'coll', 'vrnc', 'slng', 'derg', 'vulg', ''],
        'replacements' =>
        [
            ['norm'],
            ['form'],
            ['arch', 'form'],
            ['coll'],
            ['vrnc'],
            ['slng'],
            ['derg', 'coll'],
            ['vulg', 'derg']
        ],
    },
    # Tagset identifier. Where does this feature structure come from? Used to interpret the 'other' feature.
    # The expected values can be checked by a regular expression but they cannot be enumerated.
    # isa => subtype as 'Str', where { m/^([a-z]+::[a-z]+)?$/ }, message { "'$_' does not look like a tagset identifier ('lang::corpus')." } );
    'tagset' =>
    {
        'priority' => 9998,
    },
    # Tagset-specific information that does not fit elsewhere.
    # Any value is permitted, even a hash reference.
    'other' =>
    {
        'priority' => 9999,
    }
);
my @features_in_print_order = grep {ref($_) eq ''} @_matrix;



# Define the features as Moose attributes.
foreach my $feature (keys(%matrix))
{
    unless($feature =~ m/^(tagset|other)$/)
    {
        has $feature => (is => 'rw', default => '');
    }
}
has 'tagset'       => ( is  => 'rw', default => '' );
#                        isa => { subtype as 'Str', where { m/^([a-z]+::[a-z]+)?$/ }, message { "'$_' does not look like a tagset identifier ('lang::corpus')." } } );
has 'other'        => ( is  => 'rw', default => '' );



#------------------------------------------------------------------------------
# Static function. Returns the list of known features (in print order).
#------------------------------------------------------------------------------
sub known_features
{
    return @features_in_print_order;
}



#------------------------------------------------------------------------------
# Static function. Returns the list of features according to their priority
# (used when enforcing permitted feature-value combinations during strict
# encoding).
#------------------------------------------------------------------------------
sub priority_features
{
    my @features = keys(%matrix);
    @features = sort {$matrix{$a}{priority} <=> $matrix{$b}{priority}} (@features);
    return @features;
}



#------------------------------------------------------------------------------
# Static function. Returns the list of known values (in print order) of
# a feature. Dies if asked about an unknown feature.
#------------------------------------------------------------------------------
sub known_values
{
    my $feature = shift;
    if(exists($matrix{$feature}))
    {
        return @{$matrix{$feature}{values}};
    }
    else
    {
        confess("Unknown feature $feature");
    }
}



#------------------------------------------------------------------------------
# Static function. Tells whether a string is the name of a known feature.
#------------------------------------------------------------------------------
sub feature_valid
{
    my $feature = shift;
    my @known_features = known_features();
    return scalar(grep {$_ eq $feature} (@known_features));
}



#------------------------------------------------------------------------------
# Static function. Tells for a given feature-value pair whether both the
# feature and the value are known and valid. References to lists of valid
# values are also valid. Does not die when the feature is not valid.
#------------------------------------------------------------------------------
sub value_valid
{
    my $feature = shift;
    my $value = shift;
    # Avoid warnings if feature is not defined.
    if(!defined($feature))
    {
        return 0;
    }
    # Value of the 'other' feature can be anything.
    elsif($feature eq 'other')
    {
        return 1;
    }
    # For the 'tagset' feature, a regular expression is used instead of a list of values.
    elsif($feature eq 'tagset')
    {
        return $value =~ m/^[a-z]+::[a-z]+$/;
    }
    # Other known features all have their lists of values (including the empty string).
    else
    {
        return 0 unless(feature_valid($feature));
        my @known_values = known_values($feature);
        # If the value is a list of values, each of them must be valid.
        my $ref = ref($value);
        if($ref eq 'ARRAY')
        {
            foreach my $svalue (@{$value})
            {
                # No nested arrays are expected.
                if(ref($svalue) ne '')
                {
                    return 0;
                }
                else
                {
                    return 0 unless(grep {$_ eq $svalue} (@known_values));
                }
            }
            # All values tested successfully.
            return 1;
        }
        # Single value.
        elsif($ref eq '')
        {
            return scalar(grep {$_ eq $value} (@known_values));
        }
        # No other references expected.
        else
        {
            return 0;
        }
    }
}



#------------------------------------------------------------------------------
# Named setters for each feature are nice but we also need a generic setter
# that takes both the feature name and value.
#------------------------------------------------------------------------------
sub set
{
    my $self = shift;
    my $feature = shift;
    my $value = shift;
    # Validation of the arguments is not automatic in this case. We must take care of it! ###!!!
    my $old = $self->{$feature};
    $self->{$feature} = $value;
    return $old;
}



#------------------------------------------------------------------------------
# Analogically, get() is a generic feature value getter.
#------------------------------------------------------------------------------
sub get
{
    my $self = shift;
    my $feature = shift;
    return $self->{$feature};
}



#------------------------------------------------------------------------------
# Similar to get but always returns scalar. If there is an array of disjoint
# values, it does not pick just one. Instead, it sorts all values and joins
# them using the vertical bar. Example: 'masc|fem'.
###!!! Do we need set_joined(), too?
#------------------------------------------------------------------------------
sub get_joined
{
    my $self = shift;
    my $feature = shift;
    return array_to_scalar_value($self->get($feature));
}



#------------------------------------------------------------------------------
# Similar to get but always returns list of values. If there is an array of
# disjoint values, this is the list. If there is a single value (empty or not),
# this value is the only member of the list.
#------------------------------------------------------------------------------
sub get_list
{
    my $self = shift;
    my $feature = shift;
    my $value = $self->get($feature);
    my @list;
    if(ref($value) eq 'ARRAY')
    {
        @list = @{$value};
    }
    else
    {
        @list = ($value);
    }
    return @list;
}



#------------------------------------------------------------------------------
# Creates a hash of all features and their values. Returns a reference to the
# hash.
#------------------------------------------------------------------------------
sub get_hash
{
    my $self = shift;
    my %fs;
    foreach my $feature ($self->known_features())
    {
        $fs{$feature} = $self->get($feature);
    }
    return \%fs;
}



#------------------------------------------------------------------------------
# Takes a reference to a hash of features and their values. Sets the values of
# the features in $self. Unknown features and values are ignored. Known
# features that are not set in the hash will be (re-)set to empty values in
# $self.
#------------------------------------------------------------------------------
sub set_hash
{
    my $self = shift;
    my $fs = shift;
    foreach my $feature ($self->known_features())
    {
        my $value = defined($fs->{$feature}) ? $fs->{$feature} : '';
        $self->set($feature, $value);
    }
}



#------------------------------------------------------------------------------
# Sets several features at once. Takes list of value assignments, i.e. an array
# of an even number of elements (feature1, value1, feature2, value2...)
# This is useful when defining decoders from physical tagsets. Typically, one
# wants to define a table of assignments for each part of speech or input
# feature:
# 'CC' => ['pos' => 'conj', 'conjtype' => 'coor']
#------------------------------------------------------------------------------
sub multiset
{
    my $self = shift;
    my @assignments = @_;
    for(my $i = 0; $i<=$#assignments; $i += 2)
    {
        $self->set($assignments[$i], $assignments[$i+1]);
    }
}



#------------------------------------------------------------------------------
# Generates text from contents of feature structure so it can be printed.
#------------------------------------------------------------------------------
sub as_string
{
    my $self = shift;
    my @assignments = map
    {
        my $f = $_;
        my $v = $self->{$f};
        if($f eq 'other')
        {
            $v = structure_to_string($v);
        }
        elsif(ref($v) eq 'ARRAY')
        {
            $v = join("|", map {"\"$_\""} @{$v});
        }
        else
        {
            $v = "\"$v\"";
        }
        "$f=$v";
    }
    (grep{$self->{$_} ne ''}(known_features()));
    return "[".join(', ', @assignments)."]";
}



#------------------------------------------------------------------------------
# Recursively converts a structure to string describing a Perl constant.
# Useful for using eval.
#------------------------------------------------------------------------------
sub structure_to_string
{
    my $source = shift;
    my $string;
    my $ref = ref($source);
    if($ref eq 'ARRAY')
    {
        $string = "[".join(", ", map{structure_to_string($_)}(@{$source}))."]";
    }
    elsif($ref eq 'HASH')
    {
        $string = "{".join(", ", map{structure_to_string($_)." => ".structure_to_string($source->{$_})}(keys(%{$source})))."}";
    }
    else
    {
        $string = $source;
        $string =~ s/([\\"\$\@])/\\$1/g;
        $string = "\"$string\"";
    }
    return $string;
}



###############################################################################
# ENFORCING PERMITTED (EXPECTED) VALUES IN FEATURE STRUCTURES
###############################################################################



#------------------------------------------------------------------------------
# Preprocesses the lists of replacement values defined above in the %matrix.
# In the original tagset::common module, this code was in the BEGIN block and
# it created the global hash %defaults1 from %defaults.
#------------------------------------------------------------------------------
sub preprocess_list_of_replacements
{
    my %defaults1;
    # Loop over features.
    my @keys = keys(%matrix);
    foreach my $feature (@keys)
    {
        # For each feature, there is an array of arrays.
        # The first member of each second-order array is the value to replace.
        # The rest (if any) are the preferred replacements for this particular value.
        # First of all, collect preferred replacements for all values of this feature.
        my %map;
        foreach my $valarray (@{$matrix{$feature}{replacements}})
        {
            my $value = $valarray->[0];
            $map{$value}{$value}++;
            my @backoff;
            # Add all preferred replacements (if any) to the list.
            for(my $i = 1; $i<=$#{$valarray}; $i++)
            {
                push(@backoff, $valarray->[$i]);
                # Remember all values that have been added as replacements of $value.
                $map{$value}{$valarray->[$i]}++;
            }
            $defaults1{$feature}{$value} = \@backoff;
        }
        # The primary list of values constitutes the sequence of replacements for the empty value.
        foreach my $valarray (@{$defaults{$feature}})
        {
            my $replacement = $valarray->[0];
            unless($map{''}{$replacement} || $replacement eq '')
            {
                push(@{$defaults1{$feature}{''}}, $replacement);
                $map{''}{$replacement}++;
            }
        }
        # If a value had preferred replacements, add replacements of the last preferred replacement. Check loops!
        # Loop over values again.
        foreach my $value (keys(%{$defaults1{$feature}}))
        {
            # Remember all visited values to prevent loops!
            my %visited;
            $visited{$value}++;
            # Find the last preferred replacement, if any.
            my $last;
            for(;;)
            {
                my $new_last;
                if(scalar(@{$defaults1{$feature}{$value}}))
                {
                    $last = $defaults1{$feature}{$value}[$#{$defaults1{$feature}{$value}}];
                }
                # Unless the last preferred replacement has been visited, try to find its replacements.
                if($last)
                {
                    unless($visited{$last})
                    {
                        $visited{$last}++;
                        my @replacements_of_last = @{$defaults1{$feature}{$last}};
                        # If $last has replacements that $value does not have, add them to $value.
                        foreach my $replacement (@replacements_of_last)
                        {
                            unless($map{$value}{$replacement} || $replacement eq $value)
                            {
                                push(@{$defaults1{$feature}{$value}}, $replacement);
                                $map{$value}{$replacement}++;
                                $new_last++;
                            }
                        }
                    }
                }
                # If no $last has been found or if it has been visited, break the loop.
                last unless($new_last);
            }
            # The empty value and all other unvisited values are the next replacements to consider.
            foreach my $valarray ('', @{$defaults{$feature}})
            {
                my $replacement = $valarray->[0];
                unless($map{$value}{$replacement} || $replacement eq $value)
                {
                    push(@{$defaults1{$feature}{$value}}, $replacement);
                    $map{$value}{$replacement}++;
                }
            }
            # Debugging: print the complete list of replacements.
            # print STDERR ("$feature: $value:\t", join(', ', @{$defaults1{$feature}{$value}}), "\n");
        }
    }
    return \%defaults1;
}



#------------------------------------------------------------------------------
# Compares two arrays of values. Prefers precision over recall. Accepts that
# value X can serve as replacement of value Y, and counts it as 1/N occurrences
# of Y. Replacements are retrieved from the global %matrix.
#------------------------------------------------------------------------------
sub get_similarity_of_arrays
{
    my $feature = shift; # feature name needed to find default values
    my $srch = shift; # array reference
    my $eval = shift; # array reference
    ###!!! Chtělo by to nějak dotáhnout, aby se tenhle kód volal jen jednou na začátku při inicializaci modulu.
    my $defaults = preprocess_list_of_replacements();
    ###!!! Konec kódu na špatném místě.
    # For each scalar searched, get replacement array (beginning with the scalar itself).
    my @menu; # 2-dimensional matrix
    for(my $i = 0; $i<=$#{$srch}; $i++)
    {
        push(@{$menu[$i]}, $srch->[$i]);
        push(@{$menu[$i]}, @{$defaults->{$feature}{$srch->[$i]}});
    }
    # Look for menu values in array being evaluated. If not found, look for replacements.
    my @found; # srch values matched to something in eval
    my @used; # eval values identified as something searched for
    my $n_found = 0; # how many srch values have been found
    my $n_used = 0; # how many eval values have been used
    my $n_srch = scalar(@{$srch});
    my $n_eval = scalar(@{$eval});
    my $score = 0; # number of hits, weighed (replacement is not a full hit, original value is)
    if(@menu)
    {
        # Loop over levels of replacement.
        for(my $i = 0; $i<=$#{$menu[0]} && $n_found<$n_srch && $n_used<$n_eval; $i++)
        {
            # Loop over searched values.
            for(my $j = 0; $j<=$#menu && $n_found<$n_srch && $n_used<$n_eval; $j++)
            {
                next if($found[$j]);
                # Look for i-th replacement of j-th value in the evaluated array.
                for(my $k = 0; $k<=$#{$eval}; $k++)
                {
                    if(!$used[$k] && $eval->[$k] eq $menu[$j][$i])
                    {
                        $found[$j]++;
                        $used[$k]++;
                        $n_found++;
                        $n_used++;
                        # Add reward for this level of replacement.
                        # (What fraction of an occurrence are we going to count for this?)
                        $score += 1/($i+1);
                        last;
                    }
                }
            }
        }
    }
    # Use the score to compute precision and recall.
    my $p = $score/$n_srch if($n_srch);
    my $r = $score/$n_eval if($n_eval);
    # Prefer precision over recall.
    my $result = (2*$p+$r)/3;
    return $result;
}



#------------------------------------------------------------------------------
# Selects the most suitable replacement. Can deal with arrays of values.
#------------------------------------------------------------------------------
sub select_replacement
{
    my $feature = shift; # feature name needed to get default replacements of a value
    my $value = shift; # scalar or array reference
    my $permitted = shift; # hash reference; keys are permitted values; array values joint
    # The "tagset" and "other" features are special. All values are permitted.
    if($feature =~ m/^(tagset|other)$/)
    {
        return $value;
    }
    # If value is not an array, make it an array.
    my @values = ref($value) eq 'ARRAY' ? @{$value} : ($value);
    # Convert every permitted value to an array as well.
    my @permitted = keys(%{$permitted});
    if(!scalar(@permitted))
    {
        print STDERR ("Feature = $feature\n");
        print STDERR ("Value to replace = ", array_to_scalar_value($value), "\n");
        confess("Cannot select a replacement if no values are permitted.\n");
    }
    my %suitability;
    foreach my $p (@permitted)
    {
        # Warning: split converts empty values to empty array but we want array with one empty element.
        my @pvalues = split(/\|/, $p);
        $pvalues[0] = '' unless(@pvalues);
        # Get suitability evaluation for $p.
        $suitability{$p} = get_similarity_of_arrays($feature, \@values, \@pvalues);
    }
    # Return the most suitable permitted value.
    @permitted = sort {$suitability{$b} <=> $suitability{$a}} (@permitted);
    # If the replacement is an array, return a reference to it.
    my @repl = split(/\|/, $permitted[0]);
    if(scalar(@repl)==0)
    {
        return '';
    }
    elsif(scalar(@repl)==1)
    {
        return $repl[0];
    }
    else
    {
        return \@repl;
    }
}



#------------------------------------------------------------------------------
# Makes sure that a feature structure complies with the permitted combinations
# recorded in a trie. Replaces feature values if needed.
#------------------------------------------------------------------------------
sub enforce_permitted_values
{
    my $self = shift;
    my $trie = shift; # Lingua::Interset::Trie
    my $pointer = shift; # reference to a hash inside the trie, not necessarily the root hash
    if(!defined($pointer))
    {
        $pointer = $trie->root_hash();
    }
    my $features = $trie->features();
    my @features = @{$features};
    foreach my $feature (@features)
    {
        my $value = $self->get($feature);
        unless(exists($pointer->{$value}))
        {
            my $replacement = select_replacement($feature, $value, $pointer);
            $self->set($feature, $replacement);
            $value = $replacement;
        }
        $trie->advance_pointer($pointer, $feature, $value);
    }
}



###############################################################################
# GENERIC FEATURE STRUCTURE MANIPULATION
# The following section contains feature-structure-related static functions,
# not just methods (no $self parameter is expected).
###############################################################################



#------------------------------------------------------------------------------
# Compares two values, scalars or arrays, whether they are equal or not.
#------------------------------------------------------------------------------
sub iseq
{
    my $a = shift;
    my $b = shift;
    if(ref($a) ne ref($b))
    {
        return 0;
    }
    elsif(ref($a) eq 'ARRAY')
    {
        return array_to_scalar_value($a) eq array_to_scalar_value($b);
    }
    else
    {
        return $a eq $b;
    }
}



#------------------------------------------------------------------------------
# Converts array values to scalars. Sorts the array and combines all elements
# in one string, using the vertical bar as delimiter. Does not care about
# occurrences of vertical bars inside the elements (there should be none
# anyway).
#------------------------------------------------------------------------------
sub array_to_scalar_value
{
    my $value = shift;
    if(ref($value) eq 'ARRAY')
    {
        # The sorting helps to ensure that values from two arrays with the same
        # elements will be stringwise identical.
        $value = join('|', sort(@{$value}));
    }
    return $value;
}



#------------------------------------------------------------------------------
# Creates a deep copy of a feature structure. If there is a reference to an
# array of values, a copy of the array is created and the copy is referenced
# from the new structure, rather than just copying the reference to the old
# array. The same holds for the "other" feature, which can contain references
# to arrays and / or hashes nested in unlimited number of levels. In fact, this
# function could be used for any nested structures, not just feature
# structures.
#------------------------------------------------------------------------------
sub duplicate
{
    my $self = shift;
    my $srchash = $self->get_hash();
    my $tgthash = duplicate_recursive($srchash);
    my $duplicate = new Lingua::Interset::FeatureStructure();
    $duplicate->set_hash($tgthash);
    return $duplicate;
}
sub duplicate_recursive
{
    my $source = shift;
    my $duplicate;
    my $ref = ref($source);
    if($ref eq 'ARRAY')
    {
        my @new_array;
        foreach my $element (@{$source})
        {
            push(@new_array, duplicate_recursive($element));
        }
        $duplicate = \@new_array;
    }
    elsif($ref eq 'HASH')
    {
        my %new_hash;
        foreach my $key (keys(%{$source}))
        {
            $new_hash{$key} = duplicate_recursive($source->{$key});
        }
        $duplicate = \%new_hash;
    }
    else
    {
        $duplicate = $source;
    }
    return $duplicate;
}



1;

=over

=item Lingua::Interset::FeatureStructure

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

The C<FeatureStructure> class defines all morphosyntactic features and their values used
in DZ Interset.

=back

=cut

# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# This file is distributed under the GNU General Public License v3. See doc/COPYING.txt.
