# ABSTRACT: Definition of morphosyntactic features and their values.
# Copyright © 2008-2016 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::FeatureStructure;
use strict;
use warnings;
our $VERSION = '3.003';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use MooseX::SemiAffordanceAccessor; # attribute x is written using set_x($value) and read using x()
# Allow the user to import static functions into their namespace by stating
# use Lingua::Interset::FeatureStructure qw(feature_valid value_valid);
use Exporter::Easy ( OK => [ 'feature_valid', 'value_valid' ] );
use Carp; # confess()
use List::MoreUtils qw(any);



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
# 2.2. Print order of values, e.g. we want to print 'sing' before 'plur' although alphabetical order says otherwise
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
    'pos' =>
    {
        'priority' => 10,
        'values'   => ['noun', 'adj', 'num', 'verb', 'adv', 'adp', 'conj', 'part', 'int', 'punc', 'sym', ''],
        'replacements' =>
        [
            ['part'        ],
            ['noun', 'verb'],
            ['verb'        ],
            ['sym', 'punc' ],
            ['punc', 'sym' ],
            ['adj',  'noun'],
            ['num',  'adj' ],
            ['adv'         ],
            ['adp',  'adv' ],
            ['conj', 'adp' ],
            ['int'         ]
        ],
    },
    # Special type of noun if applicable and if known.
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
        'uname' => 'NounType'
    },
    # Named entity type. Typically used together with nountype = 'prop'.
    'nametype' =>
    {
        'priority' => 85,
        'values' => ['geo', 'prs', 'giv', 'sur', 'nat', 'com', 'pro', 'oth', 'col', 'sci', 'che', 'med', 'tec', 'cel', 'gov', 'jus', 'fin', 'env', 'cul', 'spo', 'hob', ''],
        'replacements' =>
        [
            ['geo'],
            ['prs', 'giv', 'sur'],
            ['giv', 'prs'],
            ['sur', 'prs'],
            ['nat', 'prs'],
            ['com', 'pro'],
            ['pro', 'com'],
            ['oth'],
            ['col'],
            ['sci'],
            ['che', 'sci'],
            ['med'],
            ['tec'],
            ['cel', 'tec'],
            ['gov'],
            ['jus'],
            ['fin'],
            ['env'],
            ['cul'],
            ['spo'],
            ['hob']
        ],
        'uname' => 'NameType'
    },
    # Special type of adjective if applicable and if known.
    'adjtype' =>
    {
        'priority' => 90,
        'values' => ['pdt', ''],
        'replacements' =>
        [
            ['pdt']
        ],
        'uname' => 'AdjType'
    },
    # Pronominality and its type for nouns (pronouns), adjectives (determiners), numerals, adverbs etc.
    'prontype' =>
    {
        'priority' => 100,
        'values' => ['prn', 'prs', 'rcp', 'art', 'int', 'rel', 'exc', 'dem', 'emp', 'neg', 'ind', 'tot', ''],
        'replacements' =>
        [
            ['prn'],
            ['ind'],
            ['dem'],
            ['prs'],
            ['rcp', 'prs'],
            ['int', 'rel', 'exc'],
            ['rel', 'int'],
            ['exc', 'int'],
            ['emp', 'dem'],
            ['neg', 'ind'],
            ['tot', 'ind'],
            ['art']
        ],
        'uname' => 'PronType'
    },
    # Numeral types.
    # Note that it is not guaranteed that pos eq 'num'. Typically only cardinal numbers
    # get 'num'. Others may have pos 'adj' (e.g. ordinal numerals) or 'adv' while their
    # numtype value indicates that they have something to do with numbers.
    'numtype' =>
    {
        'priority' => 110,
        'values' => ['card', 'ord', 'mult', 'frac', 'sets', 'dist', 'range', ''],
        'replacements' =>
        [
            ['card', '', 'ord'],
            ['ord', '', 'card'],
            ['mult'],
            ['frac', 'card'],
            ['sets', 'card'],
            ['dist', 'card'],
            ['range', 'card']
        ],
        'uname' => 'NumType'
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
        'uname' => 'NumForm'
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
        'uname' => 'NumValue'
    },
    # Special type of verb if applicable and if known.
    'verbtype' =>
    {
        'priority' => 140,
        'values' => ['aux', 'cop', 'mod', 'light', 'verbconj', ''],
        'replacements' =>
        [
            ['aux'],
            ['cop', 'aux'],
            ['mod', 'aux'],
            ['light'],
            ['verbconj'],
        ],
        'uname' => 'VerbType'
    },
    # Semantic type of adverb.
    'advtype' =>
    {
        'priority' => 150,
        'values' => ['man', 'loc', 'tim', 'sta', 'deg', 'cau', 'mod', 'adadj', 'ex', ''],
        'replacements' =>
        [
            ['man'],
            ['loc'],
            ['tim'],
            ['sta'],
            ['deg'],
            ['cau'],
            ['mod'],
            ['adadj'],
            ['ex']
        ],
        'uname' => 'AdvType'
    },
    # Special type of adposition if applicable and if known.
    'adpostype' =>
    {
        'priority' => 155,
        'values' => ['prep', 'post', 'circ', 'voc', 'preppron', 'comprep', ''],
        'replacements' =>
        [
            ['prep'],
            ['post'],
            ['circ'],
            ['voc', 'prep'],
            ['preppron'],
            ['comprep']
        ],
        'uname' => 'AdpType'
    },
    # Conjunction type.
    'conjtype' =>
    {
        'priority' => 160,
        'values' => ['coor', 'sub', 'comp', 'oper', ''],
        'replacements' =>
        [
            ['coor'],
            ['sub'],
            ['comp'],
            ['oper']
        ],
        'uname' => 'ConjType'
    },
    # Particle type.
    'parttype' =>
    {
        'priority' => 165,
        'values' => ['mod', 'emp', 'res', 'inf', 'vbp', ''],
        'replacements' =>
        [
            ['mod'],
            ['emp'],
            ['res'],
            ['inf'],
            ['vbp']
        ],
        'uname' => 'PartType'
    },
    # Punctuation type.
    'punctype' =>
    {
        'priority' => 170,
        'values' => ['peri', 'qest', 'excl', 'quot', 'brck', 'comm', 'colo', 'semi', 'dash', 'root', ''],
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
            ['root']
        ],
        'uname' => 'PunctType'
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
        'uname' => 'PunctSide'
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
    # Morphological part of speech.
    # A word's morphological paradigm may behave like a different part of speech than the word is assigned to.
    # For example, Slovak noun vstupné “admission (fee)” behaves syntactically as noun, is tagged as noun,
    # but it originates from an adjective and retains adjectival paradigm. The paradigm feature of the sk::snk
    # tagset maps to this Interset feature.
    'morphpos' =>
    {
        'priority' => 205,
        'values' => ['noun', 'adj', 'pron', 'num', 'adv', 'mix', 'def', ''],
        'replacements' =>
        [
            ['mix'],
            ['noun'],
            ['adj'],
            ['pron'],
            ['num'],
            ['adv'],
            ['def']
        ],
        'uname' => 'MorphPos'
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
        'uname' => 'Poss'
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
        'uname' => 'Reflex'
    },
    # Foreign word? (Not a loanword but a quotation from a foreign language.)
    'foreign' =>
    {
        'priority' => 400,
        'values' => ['foreign', ''],
        'replacements' =>
        [
            ['foreign']
        ],
        'uname' => 'Foreign'
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
        'uname' => 'Abbr'
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
        'uname' => 'Hyph'
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
        'uname' => 'Typo'
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
        'uname' => 'Echo'
    },
    # Polarity (do not confuse with negative pro-forms).
    # Note: this feature was called 'negativeness' until Interset 2.052.
    'polarity' =>
    {
        'priority' => 240,
        'values' => ['pos', 'neg', ''],
        'replacements' =>
        [
            ['pos'],
            ['neg']
        ],
        'uname' => 'Polarity'
    },
    # Definiteness (or state in Arabic).
    'definite' =>
    {
        'priority' => 250,
        'values' => ['ind', 'def', 'cons', 'com', ''],
        'replacements' =>
        [
            ['ind'],
            ['def'],
            ['cons', 'def'],
            ['com', 'cons', 'def']
        ],
        'uname' => 'Definite'
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
        'uname' => 'Gender'
    },
    # Animacy (considered part of gender in some tagsets, but still orthogonal).
    'animacy' =>
    {
        'priority' => 310,
        'values' => ['anim', 'hum', 'nhum', 'inan', ''],
        'replacements' =>
        [
            ['anim'],
            ['hum', 'anim'],
            ['nhum', 'anim', 'inan'],
            ['inan']
        ],
        'uname' => 'Animacy'
    },
    # Grammatical number.
    'number' =>
    {
        'priority' => 320,
        'values' => ['sing', 'dual', 'plur', 'ptan', 'coll', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plur'],
            ['plur'],
            ['ptan', 'plur'],
            ['coll', 'sing']
        ],
        'uname' => 'Number'
    },
    # Grammatical case.
    'case' =>
    {
        'priority' => 330,
        'values' => ['nom', 'gen', 'dat', 'acc', 'voc', 'loc', 'ins',
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
        'uname' => 'Case'
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
        'uname' => 'PrepCase'
    },
    # Degree of comparison.
    'degree' =>
    {
        'priority' => 230,
        'values' => ['pos', 'cmp', 'sup', 'abs', 'dim', 'aug', ''],
        'replacements' =>
        [
            ['pos'],
            ['cmp'],
            ['sup', 'cmp'],
            ['abs', 'sup'],
            ['dim'],
            ['aug']
        ],
        'uname' => 'Degree'
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
        'uname' => 'Person'
    },
    # Politeness, formal vs. informal word forms.
    'polite' =>
    {
        'priority' => 350,
        'values' => ['infm', 'form', 'elev', 'humb', ''],
        'replacements' =>
        [
            ['infm'],
            ['form', 'elev', 'humb'],
            ['elev', 'form', 'humb'],
            ['humb', 'form', 'elev']
        ],
        'uname' => 'Polite'
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
        'uname' => 'Gender[psor]'
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
        'uname' => 'Person[psor]'
    },
    # Possessor's number.
    'possnumber' =>
    {
        'priority' => 380,
        'values' => ['sing', 'dual', 'plur', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plur'],
            ['plur']
        ],
        'uname' => 'Number[psor]'
    },
    # Possession's number.
    # In Hungarian, it is possible (though rare) that a noun has three numbers:
    # 1. its own grammatical number; 2. number of its possessor; 3. number of its possession.
    'possednumber' =>
    {
        'priority' => 390,
        'values' => ['sing', 'dual', 'plur', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plur'],
            ['plur']
        ],
        'uname' => 'Number[psee]'
    },
    # Person of the absolutive argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'absperson' =>
    {
        'priority' => 400,
        'values' => ['1', '2', '3', ''],
        'replacements' =>
        [
            ['3'],
            ['1'],
            ['2']
        ],
        'uname' => 'Person[abs]'
    },
    # Person of the ergative argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'ergperson' =>
    {
        'priority' => 401,
        'values' => ['1', '2', '3', ''],
        'replacements' =>
        [
            ['3'],
            ['1'],
            ['2']
        ],
        'uname' => 'Person[erg]'
    },
    # Person of the dative argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'datperson' =>
    {
        'priority' => 402,
        'values' => ['1', '2', '3', ''],
        'replacements' =>
        [
            ['3'],
            ['1'],
            ['2']
        ],
        'uname' => 'Person[dat]'
    },
    # Number of the absolutive argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'absnumber' =>
    {
        'priority' => 403,
        'values' => ['sing', 'dual', 'plur', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plur'],
            ['plur']
        ],
        'uname' => 'Number[abs]'
    },
    # Number of the ergative argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'ergnumber' =>
    {
        'priority' => 404,
        'values' => ['sing', 'dual', 'plur', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plur'],
            ['plur']
        ],
        'uname' => 'Number[erg]'
    },
    # Number of the dative argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'datnumber' =>
    {
        'priority' => 405,
        'values' => ['sing', 'dual', 'plur', ''],
        'replacements' =>
        [
            ['sing'],
            ['dual', 'plur'],
            ['plur']
        ],
        'uname' => 'Number[dat]'
    },
    # Politeness of the absolutive argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'abspolite' =>
    {
        'priority' => 406,
        'values' => ['infm', 'form', 'elev', 'humb', ''],
        'replacements' =>
        [
            ['infm'],
            ['form', 'elev', 'humb'],
            ['elev', 'form', 'humb'],
            ['humb', 'form', 'elev']
        ],
        'uname' => 'Polite[abs]'
    },
    # Politeness of the ergative argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'ergpolite' =>
    {
        'priority' => 407,
        'values' => ['infm', 'form', 'elev', 'humb', ''],
        'replacements' =>
        [
            ['infm'],
            ['form', 'elev', 'humb'],
            ['elev', 'form', 'humb'],
            ['humb', 'form', 'elev']
        ],
        'uname' => 'Polite[erg]'
    },
    # Politeness of the dative argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'datpolite' =>
    {
        'priority' => 408,
        'values' => ['infm', 'form', 'elev', 'humb', ''],
        'replacements' =>
        [
            ['infm'],
            ['form', 'elev', 'humb'],
            ['elev', 'form', 'humb'],
            ['humb', 'form', 'elev']
        ],
        'uname' => 'Polite[dat]'
    },
    # Gender of the ergative argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'erggender' =>
    {
        'priority' => 409,
        'values' => ['masc', 'fem', 'com', 'neut', ''],
        'replacements' =>
        [
            ['neut'],
            ['com', 'masc', 'fem'],
            ['masc', 'com'],
            ['fem', 'com']
        ],
        'uname' => 'Gender[erg]'
    },
    # Gender of the dative argument of the verb.
    # Used with synthetic verbs in Basque. They agree with multiple arguments in person and number.
    'datgender' =>
    {
        'priority' => 410,
        'values' => ['masc', 'fem', 'com', 'neut', ''],
        'replacements' =>
        [
            ['neut'],
            ['com', 'masc', 'fem'],
            ['masc', 'com'],
            ['fem', 'com']
        ],
        'uname' => 'Gender[dat]'
    },
    # Position / usage of adjectives, determiners, participles etc.
    'position' =>
    {
        'priority' => 411,
        'values' => ['prenom', 'postnom', 'nom', 'free', ''],
        'replacements' =>
        [
            ['prenom'],
            ['postnom'],
            ['nom'],
            ['free']
        ],
        'uname' => 'Position'
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
        'uname' => 'Subcat'
    },
    # Verb form.
    ###!!! Combine this feature with mood? Non-empty mood seems to always imply verbform=fin.
    ###!!! On the other hand, we may want to make some verb forms self-standing parts of speech:
    # part (participle, properties of both verbs and adjectives)
    # ger (gerund, properties of both verbs and nouns)
    # gdv (gerundive, properties of both verbs and adjectives)
    # conv (converb, properties of both verbs and adverbs)
    'verbform' =>
    {
        'priority' => 60,
        'values' => ['fin', 'inf', 'sup', 'part', 'conv', 'ger', 'gdv', ''],
        'replacements' =>
        [
            ['inf'],
            ['fin'],
            ['part'],
            ['ger'],
            ['gdv', 'part'],
            ['sup'],
            ['conv']
        ],
        'uname' => 'VerbForm'
    },
    # Mood.
    'mood' =>
    {
        'priority' => 70,
        'values' => ['ind', 'imp', 'cnd', 'pot', 'sub', 'jus', 'opt', 'des', 'nec', 'qot', ''],
        'replacements' =>
        [
            ['ind'],
            ['imp', 'nec'],
            ['cnd', 'sub'],
            ['pot', 'cnd'],
            ['sub', 'cnd', 'jus', 'opt'],
            ['jus', 'sub', 'opt'],
            ['opt', 'jus'],
            ['des', 'jus'],
            ['nec', 'imp'],
            ['qot', 'ind']
        ],
        'uname' => 'Mood'
    },
    # Tense.
    'tense' =>
    {
        'priority' => 270,
        'values' => ['pres', 'fut', 'past', 'aor', 'imp', 'nar', 'pqp', ''],
        'replacements' =>
        [
            ['pres'],
            ['fut'],
            ['past', 'aor', 'imp', 'nar'],
            ['aor', 'past'],
            ['imp', 'past'],
            ['nar', 'past'],
            ['pqp', 'past']
        ],
        'uname' => 'Tense'
    },
    # Voice.
    'voice' =>
    {
        'priority' => 280,
        'values' => ['act', 'mid', 'pass', 'rcp', 'cau', 'int', ''],
        'replacements' =>
        [
            ['act'],
            ['mid'],
            ['pass'],
            ['rcp'],
            ['cau'],
            ['int']
        ],
        'uname' => 'Voice'
    },
    # Aspect (lexical or grammatical; but see also the 'imp' tense).
    'aspect' =>
    {
        'priority' => 290,
        'values' => ['imp', 'perf', 'prosp', 'prog', ''],
        'replacements' =>
        [
            ['imp'],
            ['perf'],
            ['prosp'],
            ['prog']
        ],
        'uname' => 'Aspect'
    },
    ###!!! Experimental for ro::multext and its conversion to UD!
    ###!!! Not yet fully accepted and documented!
    'strength' =>
    {
        'priority' => 437,
        'values' => ['weak', 'strong'],
        'replacements' =>
        [
            ['weak'],
            ['strong']
        ],
        'uname' => 'Strength'
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
        'uname' => 'Variant'
    },
    # Style.
    # Either lexical category of the lemma, or grammatical
    # (e.g. standard and colloquial suffix of the same lemma, cf. Czech "zelený" vs. "zelenej").
    'style' =>
    {
        'priority' => 420,
        'values' => ['arch', 'rare', 'form', 'poet', 'norm', 'coll', 'vrnc', 'slng', 'expr', 'derg', 'vulg', ''],
        'replacements' =>
        [
            ['norm'],
            ['form'],
            ['rare', 'arch', 'form'],
            ['arch', 'rare', 'form'],
            ['coll'],
            ['poet'],
            ['vrnc'],
            ['slng'],
            ['derg', 'coll'],
            ['expr', 'coll'],
            ['vulg', 'derg']
        ],
        'uname' => 'Style'
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
# The list of replacements (defaults) will be derived from the above matrix.
# Same as the matrix, it will be a class-static variable that will not depend on any particular object.
# It will be created lazily on the first demand, using the function _preprocess_list_of_replacements();
# to ensure the lazy creation, it should be accessed using get_replacements().
my $replacements = undef;



# Define the features as Moose attributes.
my $meta = __PACKAGE__->meta();
foreach my $feature (keys(%matrix))
{
    unless($feature eq 'other')
    {
        # Multivalues are internally implemented as arrays and a feature value is either a scalar or an array reference.
        # This is unhandy for the users. For them it would be better if they knew they would always get a scalar (or always an array).
        # Therefore we want to define attribute setters and getters that will do simple conversion in addition to just setting/getting the hybrid value.
        # We do this using meta() from Class::MOP::Class. The $feature attribute is defined as 'bare' because we will create the accessor methods ourselves.
        has $feature => (is => 'bare', default => '');
        # The setter will accept scalars, scalars with multivalues ('fem|masc'), array references and lists.
        $meta->add_method(qq/set_$feature/, sub
        {
            my $self = shift;
            my @values = @_;
            return $self->set($feature, @values);
        });
        # A specialized setter that sets the empty value: the clearer.
        $meta->add_method(qq/clear_$feature/, sub
        {
            my $self = shift;
            return $self->clear($feature);
        });
        # The getter will always return a scalar and multivalues will be serialized ('fem|masc').
        # The user can call get_list() if they want a list.
        $meta->add_method(qq/$feature/, sub
        {
            my $self = shift;
            return $self->get_joined($feature);
        });
    }
}
# The 'other' feature will have a standard setter/getter that will just take/return anything. Usually a hash reference.
###!!! In future we may want to limit the values of 'other' to be references to hashes of scalar-valued subfeatures.
###!!! Then we will probably define new methods for subfeatures and a serialization method. And the standard getter will be redefined to return strings only.
has 'other' => (is => 'rw', default => '');



#------------------------------------------------------------------------------
# Static function. Returns the list of known features (in print order).
#------------------------------------------------------------------------------
=func known_features()

Returns the list of known feature names in print order.

=cut
sub known_features
{
    return @features_in_print_order;
}



#------------------------------------------------------------------------------
# Static function. Returns the list of features according to their priority
# (used when enforcing permitted feature-value combinations during strict
# encoding).
#------------------------------------------------------------------------------
=func priority_features()

Returns the list of known features ordered according to their default priority.
The priority is used in L<Lingua::Interset::Trie> when one looks for the closest
matching permitted structure.

=cut
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
=func known_values()

Returns the list of known values of a feature, in print order.
Dies if asked about an unknown feature.

=cut
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
=func feature_valid()

Takes a string and returns a nonzero value if the string is a name of a known
feature.

=cut
sub feature_valid
{
    my $feature = shift;
    return exists($matrix{$feature}) ? 1 : 0;
}



#------------------------------------------------------------------------------
# Static function. Tells for a given feature-value pair whether both the
# feature and the value are known and valid. References to lists of valid
# values are also valid. Does not die when the feature is not valid.
#------------------------------------------------------------------------------
=func value_valid()

Takes two scalars, C<$feature> and C<$value>. Tells whether they are a valid
(known) pair of feature name and value. A reference to a list of valid values
is also a valid value. This function does not die when the feature is not valid.

=cut
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
        return $value =~ m/^([a-z]+::[a-z0-9]+)?$/;
    }
    # Other known features all have their lists of values (including the empty string).
    else
    {
        return 0 unless(feature_valid($feature));
        my @known_values = known_values($feature);
        # If the value is a list of values, each of them must be valid.
        # This method recognizes array references and serialized arrays using '|' as the separator.
        my $ref = ref($value);
        my @myarray;
        if($ref eq '' && $value =~ m/\|/)
        {
            @myarray = split(/\|/, $value);
            $value = \@myarray;
            $ref = ref($value);
        }
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
# This method ensures backwards compatibility of features and values that have
# been renamed. If the feature-value pair is valid, the value is returned. If
# the feature/value is not valid in the current version of Interset but it is
# known to have existed in the past, the closest match is returned. If it is
# unknown and no mapping is available, we return undef. This method does not
# throw exceptions.
#------------------------------------------------------------------------------
sub _get_compatible_value
{
    my $self = shift;
    my $feature = shift;
    my $value = shift;
    if(value_valid($feature, $value))
    {
        return $value;
    }
    else
    {
        # If the list of renamed values grows longer (hopefully not!) we may want to put this into a separate hash.
        return 'plur'    if($feature eq 'number' && $value eq 'plu'); # renamed in fall 2014
        return 'cmp'     if($feature eq 'degree' && $value eq 'comp'); # renamed in Interset 2.049, 2015-09-29
        return 'prosp'   if($feature eq 'aspect' && $value eq 'pro'); # renamed in UD v2, 2016-12-01
        return 'conv'    if($feature eq 'verbform' && $value eq 'trans'); # renamed in UD v2, 2016-12-01
        return 'infm'    if($feature =~ m/^(abs|dat|erg)?polite/ && $value eq 'inf'); # renamed in UD v2, 2016-12-01
        return 'form'    if($feature =~ m/^(abs|dat|erg)?polite/ && $value eq 'pol'); # renamed in UD v2, 2016-12-01
        return 'foreign' if($feature eq 'foreign' && $value eq 'fscript'); # value removed in UD v2, 2016-12-01
        return 'foreign' if($feature eq 'foreign' && $value eq 'tscript'); # value removed in UD v2, 2016-12-01
        return 'mult'    if($feature eq 'numtype' && $value eq 'gen'); # value removed in UD v2, 2016-12-01
        # If we are here, the feature-value pair is unknown and we do not know where to map it to.
        return undef;
    }
}



#------------------------------------------------------------------------------
# This method is called from several places in the set() method where it is
# necessary to deal with unknown values of features. It may throw exceptions!
# The method takes two arguments besides $self, $feature and $value. Only
# single values are expected, no arrayrefs and no serialized lists (the set()
# method takes care of lists before calling this). The method calls the
# _get_compatible_value() method. It differs in that it throws an exception if
# the value is invalid and cannot be replaced.
#------------------------------------------------------------------------------
sub _validate_value
{
    my $self = shift;
    my $feature = shift;
    my $value = shift;
    my $value2 = $self->_get_compatible_value($feature, $value);
    if(defined($value2))
    {
        return $value2;
    }
    else
    {
        confess("Unknown value '$value' of feature '$feature'");
    }
}



#------------------------------------------------------------------------------
# Named setters for each feature are nice but we also need a generic setter
# that takes both the feature name and value.
#------------------------------------------------------------------------------
=method set()

A generic setter for any feature. These two statements do the same thing:

  $fs->set ('pos', 'noun');
  $fs->set_pos ('noun');

If you want to set multiple values of a feature, there are several ways to do it:

  $fs->set ('tense', ['pres', 'fut']);
  $fs->set ('tense', 'pres', 'fut');
  $fs->set ('tense', 'pres|fut');

All of the above mean that the word is either in present or in future tense.

Note that the 'other' feature behaves differently.
Its value can be structured, C<set()> will keep the structure and will not try to interpret it.

Using generic C<set()> is more flexible than using specialized setters such as C<set_pos()>.
Even if flexibility is not needed it is recommended to avoid the specialized setters and
use the generic C<set()> method. If multiple values are set using an array reference,
the specialized setters will not create a deep copy of the array, they will only copy
the reference. Generic C<set()> will create a deep copy. The array will thus not be shared
among several feature structures. If someone later retrieves the array reference
via C<get()>, and decides to modify the array, they will probably expect to
change only that particular feature structure and not others that happen to
use the same array.

=cut
sub set
{
    my $self = shift;
    my $feature = shift;
    if(!feature_valid($feature))
    {
        ###!!! Since there are old files with Interset-based data, we need backward compatibility.
        ###!!! In the future we may need a separate method.
        ###!!! Features that had existed and were removed.
        if($feature eq 'subpos')
        {
            print STDERR ("Ignoring deprecated Interset feature 'subpos'.\n");
            return;
        }
        ###!!! Features that were renamed.
        elsif($feature eq 'abspoliteness')
        {
            $feature = 'abspolite';
        }
        elsif($feature eq 'animateness')
        {
            $feature = 'animacy';
        }
        elsif($feature eq 'datpoliteness')
        {
            $feature = 'datpolite';
        }
        elsif($feature eq 'definiteness')
        {
            $feature = 'definite';
        }
        elsif($feature eq 'ergpoliteness')
        {
            $feature = 'ergpolite';
        }
        elsif($feature eq 'negativeness')
        {
            $feature = 'polarity';
        }
        elsif($feature eq 'politeness')
        {
            $feature = 'polite';
        }
        else
        {
            confess("Unknown feature '$feature'");
        }
    }
    my @values = grep {defined($_) && $_ ne ''} @_;
    # Undefined value means that we want to clear the feature.
    if(scalar(@values)==0)
    {
        return $self->clear($feature);
    }
    # The interpretation of the @values if different if the feature is 'other'.
    if($feature eq 'other')
    {
        $self->{$feature} = _duplicate_recursive($values[0]);
        return 1;
    }
    my @values1;
    my %values; # map values and do not add the same value twice
    foreach my $value (@values)
    {
        if(ref($value) eq 'ARRAY')
        {
            foreach my $subvalue (@{$value})
            {
                # No unlimited recursion. Referenced arrays are not supposed to contain subarrays.
                confess('Plain scalar expected') unless(ref($subvalue) eq '');
                $subvalue = $self->_validate_value($feature, $subvalue);
                push(@values1, $subvalue) unless($values{$subvalue});
                $values{$subvalue}++;
            }
        }
        elsif($value =~ m/\|/)
        {
            my @subvalues = split(/\|/, $value);
            foreach my $subvalue (@subvalues)
            {
                $subvalue = $self->_validate_value($feature, $subvalue);
                push(@values1, $subvalue) unless($values{$subvalue});
                $values{$subvalue}++;
            }
        }
        else
        {
            $value = $self->_validate_value($feature, $value);
            push(@values1, $value) unless($values{$value});
            $values{$value}++;
        }
    }
    # Current Interset convention is that multi-values are stored as array references.
    # The above copying solves three problems:
    # 1. multiple ways for the user to provide the values
    # 2. if the user provides array reference, the array will not be shared but copied
    # 3. repeated occurrence of one value will not be allowed
    my $value;
    if(scalar(@values1)>1)
    {
        $value = \@values1;
    }
    elsif(scalar(@values1)==1)
    {
        $value = $values1[0];
    }
    else
    {
        confess('Missing value');
    }
    $self->{$feature} = $value;
}



#------------------------------------------------------------------------------
# Sets several features at once. Takes list of value assignments, i.e. an array
# of an even number of elements (feature1, value1, feature2, value2...)
# This is useful when defining decoders from physical tagsets. Typically, one
# wants to define a table of assignments for each part of speech or input
# feature:
# 'CC' => ['pos' => 'conj', 'conjtype' => 'coor']
#------------------------------------------------------------------------------
=method add()

  $fs->add ('pos' => 'conj', 'conjtype' => 'coor');

Sets several features at once.
Takes a list of value assignments, i.e. an array of an even number of elements
(feature1, value1, feature2, value2, ...)
This is useful when defining decoders from physical tagsets.
Typically, one wants to define a table of assignments for each part of speech or input feature:

  'CC' => ['pos' => 'conj', 'conjtype' => 'coor']

=cut
sub add
{
    my $self = shift;
    my @assignments = @_;
    for(my $i = 0; $i<=$#assignments; $i += 2)
    {
        my $feature = $assignments[$i];
        my $value = $assignments[$i+1];
        # Support for hashes of subfeatures in 'other'.
        # We want to merge the two hashes, not to replace the current hash by the new one.
        if($feature eq 'other' && ref($value) eq 'HASH')
        {
            my $current = $self->other();
            if(ref($current) eq 'HASH')
            {
                foreach my $subfeature (keys(%{$value}))
                {
                    # Do not concern about deep copying now. It will be taken care of in set().
                    $current->{$subfeature} = $value->{$subfeature};
                }
                $value = $current;
            }
        }
        $self->set($feature, $value);
    }
}



#------------------------------------------------------------------------------
# Takes a reference to a hash of features and their values. Sets the values of
# the features in $self. Unknown features and values are ignored. Known
# features that are not set in the hash will be (re-)set to empty values in
# $self.
#------------------------------------------------------------------------------
=method set_hash()

  my %hash = ('pos' => 'noun', 'number' => 'plur');
  $fs->set_hash (\%hash);

Takes a reference to a hash of features and their values.
Sets the values of the features in this C<FeatureStructure>.
Unknown features are ignored.
Known features that are not set in the hash will be (re-)set to empty values.

=cut
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
# Takes a reference to a hash of features and their values. Sets the values of
# the features in $self; does not touch values of features not mentioned in the
# hash.
#------------------------------------------------------------------------------
=method merge_hash_hard()

  my %hash = ('pos' => 'noun', 'number' => 'plur');
  $fs->merge_hash_hard (\%hash);

Takes a reference to a hash of features and their values.
Sets the values of the features in this C<FeatureStructure>.
Unknown features are ignored.
Known features that are not set in the hash will be left untouched;
this is the difference from C<set_hash()>.
However, if the current value of a feature is non-empty and the hash contains
a different non-empty value, the current value will be replaced by the one from
the hash.

=cut
sub merge_hash_hard
{
    my $self = shift;
    my $fs = shift;
    foreach my $feature ($self->known_features())
    {
        if(exists($fs->{$feature}) && defined($fs->{$feature}) && $fs->{$feature} ne '')
        {
            $self->set($feature, $fs->{$feature});
        }
    }
}



#------------------------------------------------------------------------------
# Takes a reference to a hash of features and their values. Sets the values of
# the features in $self; does not touch values of features not mentioned in the
# hash.
#------------------------------------------------------------------------------
=method merge_hash_soft()

  my %hash = ('pos' => 'noun', 'number' => 'plur');
  $fs->merge_hash_soft (\%hash);

Takes a reference to a hash of features and their values.
Sets the values of the features in this C<FeatureStructure>.
Unknown features are ignored.
Known features that are not set in the hash will be left untouched;
this is the difference from C<set_hash()>.
Known features that are set both in the hash and in this feature structure
will be merged into a list of values (any single value will occur at most once).
This is the difference from C<merge_hash_hard()>.

=cut
sub merge_hash_soft
{
    my $self = shift;
    my $fs = shift;
    foreach my $feature ($self->known_features())
    {
        if(exists($fs->{$feature}) && defined($fs->{$feature}) && $fs->{$feature} ne '')
        {
            my @current_values = $self->get_list($feature);
            if(scalar(@current_values)>1 || scalar(@current_values)==1 && $current_values[0] ne '')
            {
                # The new value(s) may be given in multiple ways and the set() method has mechanisms to distinguish them.
                # Let's normalize the input values by running them through set() first.
                $self->set($feature, $fs->{$feature});
                my @new_values = $self->get_list($feature);
                # Merge the two lists of values.
                my %map;
                my @values = ();
                foreach my $value (@current_values, @new_values)
                {
                    push(@values, $value) unless($map{$value});
                    $map{$value}++;
                }
                $self->set($feature, \@values);
            }
            else # no previous value found
            {
                $self->set($feature, $fs->{$feature});
            }
        }
    }
}



#------------------------------------------------------------------------------
# Generic setter that clears the value of a feature, i.e. removes the feature.
#------------------------------------------------------------------------------
=method clear()

A generic setter that clears the value of a feature, i.e. removes the feature
from the feature structure. All the following statements do the same thing:

  $fs->clear ('pos');
  $fs->clear_pos();
  $fs->set ('pos', '');
  $fs->set ('pos', undef);
  $fs->set_pos ('');
  $fs->set_pos (undef);

We can also clear several features at once:

  $fs->clear ('pos', 'prontype', 'gender');

=cut
sub clear
{
    my $self = shift;
    my @features = grep {defined($_)} @_;
    confess() if(!@features);
    foreach my $feature (@features)
    {
        delete($self->{$feature});
    }
}



#------------------------------------------------------------------------------
# Returns a list of names of (known) features whose values are not empty.
#------------------------------------------------------------------------------
=method get_nonempty_features()

Returns a list of names of features whose values are not empty.

  my @features = $fs->get_nonempty_features();
  my @values   = map { $fs->get_joined ($_) } @features;

The features are returned in a pre-defined (but not alphabetical) order.

=cut
sub get_nonempty_features
{
    my $self = shift;
    return grep {defined($self->{$_}) && $self->{$_} ne ''} known_features();
}



#------------------------------------------------------------------------------
# get() is a generic feature value getter.
#------------------------------------------------------------------------------
=method get()

A generic getter for any feature. These two statements do the same thing:

  $pos = $fs->get ('pos');
  $pos = $fs->pos();

Be warned that B<you can get an array reference> if the feature has multiple
values. It is probably better to use one of the alternative C<get...()> functions
where it is better defined what you can get.

=cut
sub get
{
    my $self = shift;
    my $feature = shift;
    confess() if(!defined($feature));
    return defined($self->{$feature}) ? _duplicate_recursive($self->{$feature}) : '';
}



#------------------------------------------------------------------------------
# Similar to get but always returns scalar. If there is an array of disjoint
# values, it does not pick just one. Instead, it sorts all values and joins
# them using the vertical bar. Example: 'fem|masc'.
#------------------------------------------------------------------------------
=method get_joined()

Similar to C<get()> but always returns scalar.
If there is an array of disjoint values, it sorts them alphabetically and
joins them using the vertical bar. Example: C<'fem|masc'>.
The sorting makes comparisons easier;
it is assumed that the actual ordering is not significant
and that C<'fem|masc'> is identical to C<'masc|fem'>.

=cut
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
=method get_list()

Similar to get but always returns list of values.
If there is an array of disjoint values, this is the list.
If there is a single value (empty or not), this value will be the only member of the list.

Unlike in C<get_joined()>, this method does I<not sort> the list before returning it.

=cut
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
=method get_hash()

  my $hashref = $fs->get_hash();

Creates a hash of all non-empty features and their values.
The values are identical to what the C<get($feature)> method would return;
in particular, the value may be a reference to an array.

Returns a reference to the hash.

=cut
sub get_hash
{
    my $self = shift;
    my %fs;
    foreach my $feature ($self->known_features())
    {
        my $value = $self->get($feature);
        if(defined($value) && $value ne '')
        {
            $fs{$feature} = $value;
        }
    }
    return \%fs;
}



#------------------------------------------------------------------------------
# Tests tagset + other features.
#------------------------------------------------------------------------------
=method get_other_for_tagset()

  my $other = $fs->get_other_for_tagset ('cs::pdt');

Takes a tagset id.
If it matches the value of the C<tagset> feature, returns the value of the
C<other> feature (it returns a deep copy, which the caller may freely modify).
If the tagset id does not match, the method returns an empty string.

=cut
sub get_other_for_tagset
{
    my $self = shift;
    my $tagset = shift;
    # We normally set the tagset feature even if there is no other feature.
    # However, it is not required that it is defined. (And sometimes we clear the tagset, e.g. during certain tests.)
    # Calling this method without defining $tagset makes much less sense but it is not fatal either.
    if(defined($self->tagset()) && defined($tagset) && $self->tagset() eq $tagset && defined($self->other()))
    {
        return _duplicate_recursive($self->other());
    }
    else
    {
        return '';
    }
}



#------------------------------------------------------------------------------
# If other is a reference to a hash of subfeatures, this method adds (replaces)
# a value of one subfeature. If other is undefined, empty or non-hash, this
# method replaces the current value of other by a reference to a new hash, then
# adds the subfeature.
#------------------------------------------------------------------------------
=method set_other_subfeature()

  $fs->set_other_subfeature ('my_weird_feature', 'my_weird_value');

Takes a non-Interset feature and its value and stores it as a subfeature of
the feature C<other>. If C<other> is currently undefined, empty or anything
else than a hash reference, the method will first create a new hash and store
its reference in C<other>, overwriting its previous value (if any).

If C<other> is a reference to a hash of subfeatures, the method will add the
new subfeature and its value to the hash. If there has been a subfeature of the
same name, its value will be overwritten.

Only simple scalar values of subfeatures are assumed. It is not verified but
no deep copy will be made if the value is a reference. Both the feature name
and the value must be defined and non-empty, otherwise the method will do
nothing.

Note that the function does not check the current value of the C<tagset>
feature. It is silently assumed that if you put anything in C<other>, you know
that this is “your” feature structure.

=cut
sub set_other_subfeature
{
    my $self = shift;
    my $subfeature = shift;
    my $value = shift;
    return unless(defined($subfeature) && defined($value) && $subfeature ne '' && $value ne '');
    # This will just return the hash reference (provided it is a hashref), no deep copying takes place.
    my $other = $self->other();
    if(!defined($other) || ref($other) ne 'HASH')
    {
        my %other;
        $other = \%other;
        # This will just set the hash reference as the value, no deep copying takes place.
        # (Unlike $self->set('other', $other), which would deep-copy the hash.)
        $self->set_other($other);
    }
    $other->{$subfeature} = $value;
}



#------------------------------------------------------------------------------
# If tagset matches and if other is a hash, this method returns the value of
# a subfeature, i.e. a value stored in the hash under a particular key.
#------------------------------------------------------------------------------
=method get_other_subfeature()

  my $value = $fs->get_other_subfeature ('cs::pdt', 'my_weird_feature');

Takes a tagset id and name of a non-Interset feature, stored as a subfeature of
C<other>. The C<other> feature may have arbitrary values ranging from plain
scalars to references to multi-level nested structures of hashes and arrays.
This method focuses on the case that C<other> contains a single-level hash.
The hash keys can be seen as names of additional features that are otherwise
not available in Interset. These additional features are subfeatures of
C<other> and their values are strings. This is one of the most useful ways of
deploying the C<other> feature.

If the given tagset id matches the value of the C<tagset> feature,
and the value of C<other> is a hash reference,
the method uses the subfeature name as a key to the hash.
If there is a value stored under the hash, it returns the value.
(In case the value is not a string but a reference, a deep copy is created.)
Otherwise it returns the empty string.

=cut
sub get_other_subfeature
{
    my $self = shift;
    my $tagset = shift;
    my $subfeature = shift;
    my $other = $self->other();
    if(defined($self->tagset()) && $tagset eq $self->tagset() && defined($other) && ref($other) eq 'HASH' && exists($other->{$subfeature}))
    {
        # This method was created because of simple hashes whose values are strings.
        # But there is no guarantee that the value is not a reference and thus we must return a deep copy.
        return _duplicate_recursive($other->{$subfeature});
    }
    return '';
}



#------------------------------------------------------------------------------
# Tests tagset + other features. Instead of returning a deep copy of the
# possibly structured value (see get_other_for_tagset()), this method only
# queries whether the other feature has/contains one particular scalar value.
#------------------------------------------------------------------------------
=method is_other()

  if ($fs->is_other ('cs::pdt', 'my_weird_tag') ||
      $fs->is_other ('cs::pdt', 'my_weird_feature', 'much_weirder_value'))
  {
      ...
  }

Takes a tagset id.
If it does not match the value of the C<tagset> feature, returns an empty string.
If the tagset ids do match, the method queries the value of the C<other>
feature. Unlike C<get_other_for_tagset()>, it does not create a deep copy of the
possibly structured value. Instead, it only checks whether the feature has or
contains one particular scalar value.

There are no a priori restrictions on the values of the C<other> feature.
The value can be a multi-level nested structure of hashes and arrays if necessary.
However, most of the time it will be either a scalar value, or a flat (one-level)
hash of feature-value pairs that cannot be stored using standard Interset features.

Besides the tagset id, this method takes one or two additional arguments.
If the current value of C<other> is scalar, the method checks whether it equals
to Argument 1. If the current value is an array reference, the method checks
whether the array contains Argument 1. If the current value is a hash reference,
the method interprets Argument 1 as hash key and checks whether the value
stored under that key equals to Argument 2.

It returns 1 when a match is found and 0 otherwise.

=cut
sub is_other
{
    my $self = shift;
    my $tagset = shift;
    my $arg1 = shift;
    my $arg2 = shift;
    $arg1 = '' if(!defined($arg1));
    $arg2 = '' if(!defined($arg2));
    if($self->tagset() eq $tagset)
    {
        my $other = $self->other();
        $other = '' if(!defined($other));
        my $ref = ref($other);
        if($ref eq '' && $other eq $arg1)
        {
            return 1;
        }
        elsif($ref eq 'ARRAY' && any { $_ eq $arg1 } (@{$other}))
        {
            return 1;
        }
        elsif($ref eq 'HASH' && exists($other->{$arg1}))
        {
            my $value = $other->{$arg1};
            $value = '' if(!defined($value));
            if($value eq $arg2)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}



#------------------------------------------------------------------------------
# Tests whether values of a feature contain one particular value. Useful if we
# know that a feature may have array of values.
#------------------------------------------------------------------------------
=method contains()

  $fs->set ('prontype', 'int|rel');
  if($fs->contains ('prontype', 'int'))
  {
      print("One of the possible pronominal classes for this word is 'interrogative'.\n");
  }

Takes a feature and a value.
Tests whether the given value is one of the current values of the feature.
This function can be used instead of simple C<< if($fs->prontype() eq 'int') >>
whenever we believe that arrays of values could occur.

=cut
sub contains
{
    my $self = shift;
    my $feature = shift;
    my $value = shift;
    return any { $_ eq $value } ($self->get_list($feature));
}



#==============================================================================
# Methods for the universal part-of-speech tags and the universal features as
# defined in October 2014 for the Universal Dependencies
# (http://universaldependencies.github.io/docs/).
#==============================================================================
use Lingua::Interset::Tagset::MUL::Upos;
has '_upos_driver' => ( isa => 'Lingua::Interset::Tagset::MUL::Upos', is => 'ro', builder => '_create_upos_driver', lazy => 1 );
sub _create_upos_driver { return new Lingua::Interset::Tagset::MUL::Upos; }
has '_map_from_uf' => ( isa => 'HashRef', is => 'ro', builder => '_create_map_from_uf', lazy => 1 );
sub _create_map_from_uf
{
    # A reverse hash will help translate Universal Features to Interset features.
    my %map_from_uf;
    foreach my $feature (keys(%matrix))
    {
        if(defined($matrix{$feature}{uname}) && !defined($map_from_uf{$matrix{$feature}{uname}}))
        {
            $map_from_uf{$matrix{$feature}{uname}} = $feature;
        }
    }
    # Backward compatibility with UD v1:
    $map_from_uf{Negative} = 'polarity';
    return \%map_from_uf;
}



#------------------------------------------------------------------------------
# Sets feature values according to a universal part-of-speech tag as defined in
# 2014 for the Universal Dependencies
# (http://universaldependencies.github.io/docs/).
#------------------------------------------------------------------------------
=method set_upos()

Sets feature values according to a universal part-of-speech tag as defined in 2014
for the Universal Dependencies
(L<http://universaldependencies.github.io/docs/>).

=cut
sub set_upos
{
    my $self = shift;
    my $upos = shift;
    # We will use the mul::upos driver to decode the tag. However, the driver
    # may destroy the current value of prontype: it may replace it by a generic
    # value 'prn'. Save the current prontype if the new one is 'prn'.
    my $old_prontype = $self->prontype();
    my $driver = $self->_upos_driver();
    $driver->decode_and_merge_hard($upos, $self);
    my $new_prontype = $self->prontype();
    if($new_prontype eq 'prn' && $old_prontype ne '' && $old_prontype ne 'prn')
    {
        $self->set('prontype', $old_prontype);
    }
}



#------------------------------------------------------------------------------
# Returns the universal part-of-speech tag as defined in 2014 for the Universal
# Dependencies (http://universaldependencies.github.io/docs/).
#------------------------------------------------------------------------------
=method get_upos(), upos()

Returns the universal part-of-speech tag as defined in 2014
for the Universal Dependencies
(L<http://universaldependencies.github.io/docs/>).

=cut
sub get_upos
{
    my $self = shift;
    my $driver = $self->_upos_driver();
    return $driver->encode($self);
}
sub upos { return get_upos(@_); }



#------------------------------------------------------------------------------
# Takes a list of feature=value pairs in the format prescribed by the
# Universal Dependencies (http://universaldependencies.github.io/docs/), i.e.
# identifiers are capitalized, some features are renamed and all pairs are
# ordered alphabetically. Sets our feature values accordingly.
#------------------------------------------------------------------------------
=method add_ufeatures()

  $fs->add_ufeatures ('Case=Nom', 'Gender=Masc,Neut');

Takes a list of feature-value pairs in the format prescribed by the
Universal Dependencies (L<http://universaldependencies.org/>), i.e.
all features and values are capitalized, some features are renamed and all
feature-value pairs are ordered alphabetically.
Sets our feature values accordingly.
Values of our features that are not mentioned in the input list will be left untouched.

This method does not complain about unknown features or values.
They will be silently ignored.
Hence it is possible to read the input even if it contains language-specific
extensions that are not yet known to Interset.

=cut
sub add_ufeatures
{
    my $self = shift;
    my @pairs = @_;
    my $map = $self->_map_from_uf();
    foreach my $pair (@pairs)
    {
        if($pair =~ m/^(.+)=(.+)$/)
        {
            my $ufeature = $1;
            my $uvalue = $2;
            my $feature = $map->{$ufeature};
            next if(!defined($feature));
            my $value = lc($uvalue);
            # Interset uses for boolean features the value identical to feature name while universal features use "Yes".
            $value = $feature if($value eq 'yes');
            # Universal Features use comma to join multi-values but we use the vertical bar.
            $value =~ s/,/\|/g;
            # Backward compatibility: if this is an old value that has been renamed, get the new value.
            # If the value has never been known, we will get back an undefined value.
            $value = $self->_get_compatible_value($feature, $value);
            if(defined($feature) && defined($value))
            {
                $self->set($feature, $value);
            }
        }
    }
}



#------------------------------------------------------------------------------
# Returns the list of feature=value pairs in the format prescribed by the
# Universal Dependencies (http://universaldependencies.github.io/docs/), i.e.
# identifiers are capitalized, some features are renamed and all pairs are
# ordered alphabetically.
#------------------------------------------------------------------------------
=method get_ufeatures()

  my @ufpairs = $fs->get_ufeatures();
  print (join ('|', @ufpairs));

Returns the list of feature-value pairs in the format prescribed by the
Universal Dependencies (L<http://universaldependencies.github.io/docs/>), i.e.
all features and values are capitalized, some features are renamed and all
feature-value pairs are ordered alphabetically.

=cut
sub get_ufeatures
{
    my $self = shift;
    my $fh = $self->get_hash();
    # The Universal Features must be sorted alphabetically, that is, lowercase letters equal to uppercase
    # and 'Number' < 'NumType'.
    my @features = sort {lc($matrix{$a}{uname}) cmp lc($matrix{$b}{uname})} (grep {defined($matrix{$_}{uname})} (keys(%{$fh})));
    my @pairs;
    foreach my $feature (@features)
    {
        my $uname = $matrix{$feature}{uname};
        my @values = grep {defined($_) && $_ ne ''} $self->get_list($feature);
        next unless(@values);
        # Sort multivalues alphabetically and capitalize them.
        @values = sort {lc($a) cmp lc($b)} (map {my $x = $_; $x =~ s/^(.)/\u$1/; $x} (@values));
        # Join values using comma (unlike in get_joined(), with Universal Features we cannot use the vertical bar).
        my $value = join(',', @values);
        # Interset uses for boolean features the value identical to feature name while universal features use "Yes".
        # Exception: Foreign used to be boolean, now it has three values but foreign=foreign is still one of them.
        $value = 'Yes' if($value eq $uname);
        my $pair = "$uname=$value";
        # Some values of some features became obsolete because the distinction was moved to the POS tag level.
        next if($pair =~ m/^(PronType=Prn|ConjType=(Coor|Sub)|NounType=(Com|Prop)|VerbType=Aux|Variant=[0-9])$/);
        push(@pairs, $pair);
    }
    return @pairs;
}



#------------------------------------------------------------------------------
# Tests multiple Interset features simultaneously. Input is a list of feature-
# value pairs, return value is 1 if the node matches all these values. This
# function is an abbreviation for a series of get_iset() calls in an if
# statement:
#
# if($node->match_iset('pos' => 'noun', 'gender' => 'masc')) { ... }
#------------------------------------------------------------------------------
=method matches()

  if ($fs->matches ('pos' => 'noun', 'gender' => '!masc', 'number' => '~(dual|plur)'))
  {
      ...
  }

Tests multiple features simultaneously.
Input is a list of feature-value pairs, return value is 1 if the structure matches all these values.
This function is an abbreviation for a series of C<get_joined()> calls in an if statement.

If the expected value is preceded by "!", the actual value must not be equal to the expected value.
If the expected value is preceded by "~", then it is a regular expression which the actual value must match.
If the expected value is preceded by "!~", then it is a regular expression which the actual value must not match.

=cut
sub matches
{
    my $self = shift;
    my @req  = @_;
    for ( my $i = 0; $i <= $#req; $i += 2 )
    {
        my $feature  = $req[$i];
        my $expected = $req[$i+1];
        confess("Undefined feature") unless ($feature);
        my $value = $self->get_joined($feature);
        my $comp =
            $expected =~ s/^\!\~// ? 'nr' :
            $expected =~ s/^\!//   ? 'ne' :
            $expected =~ s/^\~//   ? 're' : 'eq';
        if (
            $comp eq 'eq' && $value ne $expected ||
            $comp eq 'ne' && $value eq $expected ||
            $comp eq 're' && $value !~ m/$expected/  ||
            $comp eq 'nr' && $value =~ m/$expected/
           )
        {
            return 0;
        }
    }
    return 1;
}



#------------------------------------------------------------------------------
# Generates text from contents of feature structure so it can be printed.
#------------------------------------------------------------------------------
=method as_string()

Generates a textual representation of the feature structure so it can be printed.
Features are in a predefined (but not alphabetical) order. Complex values of
the C<other> feature are serialized in depth. If a feature has multiple values,
they are sorted alphabetically and delimited by the vertical bar character.
What follows is a sample output for the C<cs::pdt> tags C<NNMS1-----A---->,
C<Ck-P1----------> and C<VpQW---XR-AA--->:

  [pos="noun", polarity="pos", gender="masc", animacy="anim", number="sing", case="nom", tagset="cs::pdt"]
  [pos="adj", numtype="ord", number="plur", case="nom", tagset="cs::pdt", other={"numtype" => "suffix"}]
  [pos="verb", polarity="pos", gender="fem|neut", number="plur|sing", verbform="part", tense="past", voice="act", tagset="cs::pdt"]

=cut
sub as_string
{
    my $self = shift;
    my @features = $self->get_nonempty_features();
    my @assignments = map
    {
        my $f = $_;
        my $v;
        if($f eq 'other')
        {
            $v = structure_to_string($self->{$f});
        }
        else
        {
            $v = '"'.$self->get_joined($f).'"';
        }
        "$f=$v";
    }
    (@features);
    return "[".join(', ', @assignments)."]";
}



#------------------------------------------------------------------------------
# Generates text from contents of feature structure in the form used in the
# FEATS column of the CoNLL-X file format. The tagset and other features will
# be omitted. Multivalues will be separated by a comma because the vertical bar
# separates features.
#------------------------------------------------------------------------------
=method as_string_conllx()

Generates a textual representation of the feature structure in the form used in
the FEATS column of the CoNLL-X file format. The C<tagset> and C<other>
features are omitted. Features are in predefined (but not alphabetical) order.
If a feature has multiple values, they are sorted alphabetically and delimited
by comma (because the vertical bar is used to separate features).
What follows is a sample output for the C<cs::pdt> tags C<NNMS1-----A---->,
C<Ck-P1----------> and C<VpQW---XR-AA--->:

  pos=noun|polarity=pos|gender=masc|animacy=anim|number=sing|case=nom
  pos=adj|numtype=ord|number=plur|case=nom
  pos=verb|polarity=pos|gender=fem,neut|number=plur,sing|verbform=part|tense=past|voice=act

If the values of all features (including C<pos>) are empty, the method
returns the underscore character. Thus the result is never undefined or empty.

=cut
sub as_string_conllx
{
    my $self = shift;
    my @features = grep {$_ ne 'tagset' && $_ ne 'other' && defined($self->{$_}) && $self->{$_} ne ''} known_features();
    my @assignments = map
    {
        my $f = $_;
        my $v = $self->get_joined($f);
        $v =~ s/\|/,/g;
        "$f=$v";
    }
    (@features);
    return (scalar(@assignments) > 0) ? join('|', @assignments) : '_';
}



#------------------------------------------------------------------------------
# Recursively converts a structure to string describing a Perl constant.
# Useful for using eval.
#------------------------------------------------------------------------------
=func structure_to_string()

Recursively converts a structure to a string.
The string uses Perl syntax for constant structures, so it can be used in eval.

=cut
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
        $string = '' if(!defined($string));
        $string =~ s/([\\"\$\@])/\\$1/g; # "
        $string = "\"$string\"";
    }
    return $string;
}



###############################################################################
# Shortcuts for some frequent tests people want to do against Interset.
###############################################################################

#------------------------------------------------------------------------------
=method is_noun()
Also returns 1 if the C<pos> feature has multiple values and one of them is C<noun>, e.g.
if C<get_joined('pos') eq 'noun|adj'>. Note that pronouns also have C<pos=noun>.
If you want to exclude pronouns, test C<is_noun() && !is_pronominal()>.
=cut
sub is_noun {my $self = shift; return $self->contains('pos', 'noun');}

#------------------------------------------------------------------------------
=method is_abbreviation()
=cut
sub is_abbreviation {my $self = shift; return $self->abbr() eq 'abbr';}

#------------------------------------------------------------------------------
=method is_abessive()
=cut
sub is_abessive {my $self = shift; return $self->contains('case', 'abe');}

#------------------------------------------------------------------------------
=method is_ablative()
=cut
sub is_ablative {my $self = shift; return $self->contains('case', 'abl');}

#------------------------------------------------------------------------------
=method is_absolute_superlative()
=cut
sub is_absolute_superlative {my $self = shift; return $self->contains('degree', 'abs');}

#------------------------------------------------------------------------------
=method is_absolutive()
=cut
sub is_absolutive {my $self = shift; return $self->contains('case', 'abs');}

#------------------------------------------------------------------------------
=method is_accusative()
=cut
sub is_accusative {my $self = shift; return $self->contains('case', 'acc');}

#------------------------------------------------------------------------------
=method is_active()
=cut
sub is_active {my $self = shift; return $self->contains('voice', 'act');}

#------------------------------------------------------------------------------
=method is_additive()
=cut
sub is_additive {my $self = shift; return $self->contains('case', 'add');}

#------------------------------------------------------------------------------
=method is_adessive()
=cut
sub is_adessive {my $self = shift; return $self->contains('case', 'ade');}

#------------------------------------------------------------------------------
=method is_adjective()
=cut
sub is_adjective {my $self = shift; return $self->contains('pos', 'adj');}

#------------------------------------------------------------------------------
=method is_adposition()
=cut
sub is_adposition {my $self = shift; return $self->contains('pos', 'adp');}

#------------------------------------------------------------------------------
=method is_adverb()
=cut
sub is_adverb {my $self = shift; return $self->contains('pos', 'adv');}

#------------------------------------------------------------------------------
=method is_affirmative()
=cut
sub is_affirmative {my $self = shift; return $self->contains('negativeness', 'pos');}

#------------------------------------------------------------------------------
=method is_allative()
=cut
sub is_allative {my $self = shift; return $self->contains('case', 'all');}

#------------------------------------------------------------------------------
=method is_animate()
=cut
sub is_animate {my $self = shift; return $self->contains('animacy', 'anim');}

#------------------------------------------------------------------------------
=method is_aorist()
=cut
sub is_aorist {my $self = shift; return $self->contains('tense', 'aor');}

#------------------------------------------------------------------------------
=method is_archaic()
=cut
sub is_archaic {my $self = shift; return $self->contains('style', 'arch');}

#------------------------------------------------------------------------------
=method is_article()
=cut
sub is_article {my $self = shift; return $self->contains('prontype', 'art');}

#------------------------------------------------------------------------------
=method is_associative()
=cut
sub is_associative {my $self = shift; return $self->contains('case', 'com');}

#------------------------------------------------------------------------------
=method is_augmentative()
=cut
sub is_augmentative {my $self = shift; return $self->contains('degree', 'aug');}

#------------------------------------------------------------------------------
=method is_auxiliary()
=cut
sub is_auxiliary {my $self = shift; return $self->contains('verbtype', 'aux');}

#------------------------------------------------------------------------------
=method is_benefactive()
=cut
sub is_benefactive {my $self = shift; return $self->contains('case', 'ben');}

#------------------------------------------------------------------------------
=method is_cardinal()
=cut
sub is_cardinal {my $self = shift; return $self->contains('numtype', 'card');}

#------------------------------------------------------------------------------
=method is_colloquial()
=cut
sub is_colloquial {my $self = shift; return $self->contains('style', 'coll');}

#------------------------------------------------------------------------------
=method is_comitative()
=cut
sub is_comitative {my $self = shift; return $self->contains('case', 'com');}

#------------------------------------------------------------------------------
=method is_common_gender()
=cut
sub is_common_gender {my $self = shift; return $self->contains('gender', 'com');}

#------------------------------------------------------------------------------
=method is_comparative()
=cut
sub is_comparative {my $self = shift; return $self->contains('degree', 'cmp');}

#------------------------------------------------------------------------------
=method is_conditional()
=cut
sub is_conditional {my $self = shift; return $self->contains('mood', 'cnd');}

#------------------------------------------------------------------------------
=method is_conjunction()
=cut
sub is_conjunction {my $self = shift; return $self->contains('pos', 'conj');}

#------------------------------------------------------------------------------
=method is_conjunctive()
=cut
sub is_conjunctive {my $self = shift; return $self->contains('mood', 'sub');}

#------------------------------------------------------------------------------
=method is_construct()
=cut
sub is_construct {my $self = shift; return $self->contains('definite', 'cons');}

#------------------------------------------------------------------------------
=method is_converb()
=cut
sub is_converb {my $self = shift; return $self->contains('verbform', 'conv');}

#------------------------------------------------------------------------------
=method is_coordinator()
=cut
sub is_coordinator {my $self = shift; return $self->is_conjunction() && $self->conjtype() eq 'coor';}

#------------------------------------------------------------------------------
=method is_dative()
=cut
sub is_dative {my $self = shift; return $self->contains('case', 'dat');}

#------------------------------------------------------------------------------
=method is_definite()
=cut
sub is_definite {my $self = shift; return $self->contains('definite', 'def');}

#------------------------------------------------------------------------------
=method is_delative()
=cut
sub is_delative {my $self = shift; return $self->contains('case', 'del');}

#------------------------------------------------------------------------------
=method is_demonstrative()
=cut
sub is_demonstrative {my $self = shift; return $self->contains('prontype', 'dem');}

#------------------------------------------------------------------------------
=method is_desiderative()
=cut
sub is_desiderative {my $self = shift; return $self->contains('mood', 'des');}

#------------------------------------------------------------------------------
=method is_destinative()
=cut
sub is_destinative {my $self = shift; return $self->contains('case', 'ben');}

#------------------------------------------------------------------------------
=method is_determiner()
=cut
sub is_determiner {my $self = shift; return $self->is_pronominal() && $self->is_adjective();}

#------------------------------------------------------------------------------
=method is_diminutive()
=cut
sub is_diminutive {my $self = shift; return $self->contains('degree', 'dim');}

#------------------------------------------------------------------------------
=method is_distributive()
=cut
sub is_distributive {my $self = shift; return $self->contains('case', 'dis');}

#------------------------------------------------------------------------------
=method is_dual()
=cut
sub is_dual {my $self = shift; return $self->contains('number', 'dual');}

#------------------------------------------------------------------------------
=method is_elative()
=cut
sub is_elative {my $self = shift; return $self->contains('case', 'ela');}

#------------------------------------------------------------------------------
=method is_elevating()
=cut
sub is_elevating {my $self = shift; return $self->contains('polite', 'elev');}

#------------------------------------------------------------------------------
=method is_ergative()
=cut
sub is_ergative {my $self = shift; return $self->contains('case', 'erg');}

#------------------------------------------------------------------------------
=method is_essive()
=cut
sub is_essive {my $self = shift; return $self->contains('case', 'ess');}

#------------------------------------------------------------------------------
=method is_exclamative()
=cut
sub is_exclamative {my $self = shift; return $self->contains('prontype', 'exc');}

#------------------------------------------------------------------------------
=method is_factive()
=cut
sub is_factive {my $self = shift; return $self->contains('case', 'tra');}

#------------------------------------------------------------------------------
=method is_feminine()
=cut
sub is_feminine {my $self = shift; return $self->contains('gender', 'fem');}

#------------------------------------------------------------------------------
=method is_finite_verb()
=cut
sub is_finite_verb {my $self = shift; return $self->contains('verbform', 'fin');}

#------------------------------------------------------------------------------
=method is_first_person()
=cut
sub is_first_person {my $self = shift; return $self->contains('person', '1');}

#------------------------------------------------------------------------------
=method is_foreign()
=cut
sub is_foreign {my $self = shift; return $self->foreign() eq 'foreign';}

#------------------------------------------------------------------------------
=method is_formal()
=cut
sub is_formal {my $self = shift; return $self->contains('polite', 'form');}

#------------------------------------------------------------------------------
=method is_future()
=cut
sub is_future {my $self = shift; return $self->contains('tense', 'fut');}

#------------------------------------------------------------------------------
=method is_genitive()
=cut
sub is_genitive {my $self = shift; return $self->contains('case', 'gen');}

#------------------------------------------------------------------------------
=method is_gerund()
=cut
sub is_gerund {my $self = shift; return $self->contains('verbform', 'ger');}

#------------------------------------------------------------------------------
=method is_gerundive()
=cut
sub is_gerundive {my $self = shift; return $self->contains('verbform', 'gdv');}

#------------------------------------------------------------------------------
=method is_human()
=cut
sub is_human {my $self = shift; return $self->contains('animacy', 'hum');}

#------------------------------------------------------------------------------
=method is_humbling()
=cut
sub is_humbling {my $self = shift; return $self->contains('polite', 'humb');}

#------------------------------------------------------------------------------
=method is_hyph()
=cut
sub is_hyph {my $self = shift; return $self->hyph() eq 'hyph';}

#------------------------------------------------------------------------------
=method is_illative()
=cut
sub is_illative {my $self = shift; return $self->contains('case', 'ill');}

#------------------------------------------------------------------------------
=method is_imperative()
=cut
sub is_imperative {my $self = shift; return $self->contains('mood', 'imp');}

#------------------------------------------------------------------------------
=method is_imperfect()
=cut
sub is_imperfect {my $self = shift; return $self->contains('tense', 'imp') && $self->contains('aspect', 'imp');}

#------------------------------------------------------------------------------
=method is_inanimate()
=cut
sub is_inanimate {my $self = shift; return $self->contains('animacy', 'inan');}

#------------------------------------------------------------------------------
=method is_indefinite()
=cut
sub is_indefinite {my $self = shift; return $self->contains('prontype', 'ind') || $self->contains('definite', 'ind');}

#------------------------------------------------------------------------------
=method is_indicative()
=cut
sub is_indicative {my $self = shift; return $self->contains('mood', 'ind');}

#------------------------------------------------------------------------------
=method is_inessive()
=cut
sub is_inessive {my $self = shift; return $self->contains('case', 'ine');}

#------------------------------------------------------------------------------
=method is_infinitive()
=cut
sub is_infinitive {my $self = shift; return $self->contains('verbform', 'inf');}

#------------------------------------------------------------------------------
=method is_informal()
=cut
sub is_informal {my $self = shift; return $self->contains('polite', 'infm');}

#------------------------------------------------------------------------------
=method is_instructive()
=cut
sub is_instructive {my $self = shift; return $self->contains('case', 'ins');}

#------------------------------------------------------------------------------
=method is_instrumental()
=cut
sub is_instrumental {my $self = shift; return $self->contains('case', 'ins');}

#------------------------------------------------------------------------------
=method is_interjection()
=cut
sub is_interjection {my $self = shift; $self->contains('pos', 'int');}

#------------------------------------------------------------------------------
=method is_interrogative()
=cut
sub is_interrogative {my $self = shift; $self->contains('prontype', 'int');}

#------------------------------------------------------------------------------
=method is_intransitive()
=cut
sub is_intransitive {my $self = shift; return $self->contains('subcat', 'intr');}

#------------------------------------------------------------------------------
=method is_jussive()
=cut
sub is_jussive {my $self = shift; return $self->contains('mood', 'jus');}

#------------------------------------------------------------------------------
=method is_lative()
=cut
sub is_lative {my $self = shift; return $self->contains('case', 'lat');}

#------------------------------------------------------------------------------
=method is_locative()
=cut
sub is_locative {my $self = shift; return $self->contains('case', 'loc');}

#------------------------------------------------------------------------------
=method is_masculine()
=cut
sub is_masculine {my $self = shift; return $self->contains('gender', 'masc');}

#------------------------------------------------------------------------------
=method is_mediopassive()
=cut
sub is_mediopassive {my $self = shift; return $self->is_middle_voice() && $self->is_passive();}

#------------------------------------------------------------------------------
=method is_middle_voice()
=cut
sub is_middle_voice {my $self = shift; return $self->contains('voice', 'mid');}

#------------------------------------------------------------------------------
=method is_modal()
=cut
sub is_modal {my $self = shift; return $self->contains('verbtype', 'mod');}

#------------------------------------------------------------------------------
=method is_motivative()
=cut
sub is_motivative {my $self = shift; return $self->contains('case', 'cau');}

#------------------------------------------------------------------------------
=method is_multiplicative()
=cut
sub is_multiplicative {my $self = shift; return $self->contains('numtype', 'mult');}

#------------------------------------------------------------------------------
=method is_narrative()
=cut
sub is_narrative {my $self = shift; return $self->contains('tense', 'nar');}

#------------------------------------------------------------------------------
=method is_necessitative()
=cut
sub is_necessitative {my $self = shift; return $self->contains('mood', 'nec');}

#------------------------------------------------------------------------------
=method is_negative()
=cut
sub is_negative {my $self = shift; return $self->contains('negativeness', 'neg') || $self->prontype() eq 'neg';} # prontype: don't use contains() here, we don't want true on 'ind|tot|neg'

#------------------------------------------------------------------------------
=method is_nominative()
=cut
sub is_nominative {my $self = shift; return $self->contains('case', 'nom');}

#------------------------------------------------------------------------------
=method is_nonhuman()
=cut
sub is_nonhuman {my $self = shift; return $self->contains('animacy', 'nhum');}

#------------------------------------------------------------------------------
=method is_neuter()
=cut
sub is_neuter {my $self = shift; return $self->contains('gender', 'neut');}

#------------------------------------------------------------------------------
=method is_numeral()
=cut
sub is_numeral {my $self = shift; return $self->contains('pos', 'num') || $self->numtype() ne '';}

#------------------------------------------------------------------------------
=method is_optative()
=cut
sub is_optative {my $self = shift; return $self->contains('mood', 'opt');}

#------------------------------------------------------------------------------
=method is_ordinal()
=cut
sub is_ordinal {my $self = shift; return $self->contains('numtype', 'ord');}

#------------------------------------------------------------------------------
=method is_participle()
=cut
sub is_participle {my $self = shift; return $self->contains('verbform', 'part');}

#------------------------------------------------------------------------------
=method is_particle()
=cut
sub is_particle {my $self = shift; return $self->contains('pos', 'part');}

#------------------------------------------------------------------------------
=method is_partitive()
=cut
sub is_partitive {my $self = shift; return $self->contains('case', 'par');}

#------------------------------------------------------------------------------
=method is_passive()
=cut
sub is_passive {my $self = shift; return $self->contains('voice', 'pass');}

#------------------------------------------------------------------------------
=method is_past()
=cut
sub is_past {my $self = shift; return $self->contains('tense', 'past');}

#------------------------------------------------------------------------------
=method is_perfect()
=cut
sub is_perfect {my $self = shift; return $self->contains('aspect', 'perf');}

#------------------------------------------------------------------------------
=method is_personal()
=cut
sub is_personal {my $self = shift; return $self->contains('prontype', 'prs');}

#------------------------------------------------------------------------------
=method is_personal_pronoun()
=cut
sub is_personal_pronoun {my $self = shift; return $self->contains('prontype', 'prs');}

#------------------------------------------------------------------------------
=method is_pluperfect()
=cut
sub is_pluperfect {my $self = shift; return $self->contains('tense', 'pqp');}

#------------------------------------------------------------------------------
=method is_plural()
=cut
sub is_plural {my $self = shift; return $self->contains('number', 'plur');}

#------------------------------------------------------------------------------
=method is_polite()
=cut
sub is_polite {my $self = shift; return $self->contains('polite', 'form');}

#------------------------------------------------------------------------------
=method is_positive()
=cut
sub is_positive {my $self = shift; return $self->contains('degree', 'pos');}

#------------------------------------------------------------------------------
=method is_possessive()
=cut
sub is_possessive {my $self = shift; return $self->poss() eq 'poss';}

#------------------------------------------------------------------------------
=method is_potential()
=cut
sub is_potential {my $self = shift; return $self->contains('mood', 'pot');}

#------------------------------------------------------------------------------
=method is_present()
=cut
sub is_present {my $self = shift; return $self->contains('tense', 'pres');}

#------------------------------------------------------------------------------
=method is_prolative()
=cut
sub is_prolative {my $self = shift; return $self->contains('case', 'ess');}

#------------------------------------------------------------------------------
=method is_pronominal()
=cut
sub is_pronominal {my $self = shift; return $self->prontype() ne '';}

#------------------------------------------------------------------------------
=method is_pronoun()
=cut
sub is_pronoun {my $self = shift; return $self->is_pronominal() && $self->is_noun();}

#------------------------------------------------------------------------------
=method is_proper_noun()
=cut
sub is_proper_noun {my $self = shift; return $self->contains('nountype', 'prop');}

#------------------------------------------------------------------------------
=method is_progressive()
=cut
sub is_progressive {my $self = shift; return $self->contains('aspect', 'prog');}

#------------------------------------------------------------------------------
=method is_prospective()
=cut
sub is_prospective {my $self = shift; return $self->contains('aspect', 'prosp');}

#------------------------------------------------------------------------------
=method is_punctuation()
=cut
sub is_punctuation {my $self = shift; return $self->contains('pos', 'punc');}

#------------------------------------------------------------------------------
=method is_quotative()
=cut
sub is_quotative {my $self = shift; return $self->contains('mood', 'qot');}

#------------------------------------------------------------------------------
=method is_rare()
=cut
sub is_rare {my $self = shift; return $self->contains('style', 'rare');}

#------------------------------------------------------------------------------
=method is_reciprocal()
=cut
sub is_reciprocal {my $self = shift; return $self->contains('prontype', 'rcp') || $self->contains('voice', 'rcp');}

#------------------------------------------------------------------------------
=method is_reflexive()
=cut
sub is_reflexive {my $self = shift; return $self->reflex() eq 'reflex';}

#------------------------------------------------------------------------------
=method is_relative()
=cut
sub is_relative {my $self = shift; $self->contains('prontype', 'rel');}

#------------------------------------------------------------------------------
=method is_second_person()
=cut
sub is_second_person {my $self = shift; return $self->contains('person', '2');}

#------------------------------------------------------------------------------
=method is_singular()
=cut
sub is_singular {my $self = shift; return $self->contains('number', 'sing');}

#------------------------------------------------------------------------------
=method is_subjunctive()
=cut
sub is_subjunctive {my $self = shift; return $self->contains('mood', 'sub');}

#------------------------------------------------------------------------------
=method is_sublative()
=cut
sub is_sublative {my $self = shift; return $self->contains('case', 'sub');}

#------------------------------------------------------------------------------
=method is_subordinator()
=cut
sub is_subordinator {my $self = shift; return $self->is_conjunction() && $self->conjtype() eq 'sub';}

#------------------------------------------------------------------------------
=method is_superessive()
=cut
sub is_superessive {my $self = shift; return $self->contains('case', 'sup');}

#------------------------------------------------------------------------------
=method is_superlative()
=cut
sub is_superlative {my $self = shift; return $self->contains('degree', 'sup');}

#------------------------------------------------------------------------------
=method is_supine()
=cut
sub is_supine {my $self = shift; return $self->contains('verbform', 'sup');}

#------------------------------------------------------------------------------
=method is_symbol()
=cut
sub is_symbol {my $self = shift; return $self->contains('pos', 'sym');}

#------------------------------------------------------------------------------
=method is_temporal()
=cut
sub is_temporal {my $self = shift; return $self->contains('case', 'tem');}

#------------------------------------------------------------------------------
=method is_terminative()
=cut
sub is_terminative {my $self = shift; return $self->contains('case', 'ter');}

#------------------------------------------------------------------------------
=method is_third_person()
=cut
sub is_third_person {my $self = shift; return $self->contains('person', '3');}

#------------------------------------------------------------------------------
=method is_total()
=cut
sub is_total {my $self = shift; return $self->contains('prontype', 'tot');}

#------------------------------------------------------------------------------
=method is_transgressive()
=cut
sub is_transgressive {my $self = shift; return $self->contains('verbform', 'conv');}

#------------------------------------------------------------------------------
=method is_transitive()
=cut
sub is_transitive {my $self = shift; return $self->contains('subcat', 'tran');}

#------------------------------------------------------------------------------
=method is_translative()
=cut
sub is_translative {my $self = shift; return $self->contains('case', 'tra');}

#------------------------------------------------------------------------------
=method is_typo()
=cut
sub is_typo {my $self = shift; return $self->typo() eq 'typo';}

#------------------------------------------------------------------------------
=method is_verb()
=cut
sub is_verb {my $self = shift; return $self->contains('pos', 'verb');}

#------------------------------------------------------------------------------
=method is_vocative()
=cut
sub is_vocative {my $self = shift; return $self->contains('case', 'voc');}

#------------------------------------------------------------------------------
=method is_wh()
=cut
sub is_wh {my $self = shift; return any {m/^(int|rel)$/} ($self->get_list('prontype'));}



###############################################################################
# ENFORCING PERMITTED (EXPECTED) VALUES IN FEATURE STRUCTURES
###############################################################################



#------------------------------------------------------------------------------
# Returns the set of replacement values for the case a feature value is not
# permitted in a given context. The set is derived from the feature matrix
# above. It is a hash{feature}{value0}, leading to a list of values that can be
# used to replace the value0, ordered by priority.
#------------------------------------------------------------------------------
=func get_replacements()

  my $replacements = Lingua::Interset::FeatureStructure->get_replacements();
  my $rep_adverb = $replacements->{pos}{adv};
  foreach my $r (@{$rep_adverb})
  {
      if(...)
      {
          # This replacement matches our constraints, let's use it.
          return $r;
      }
  }

Returns the set of replacement values for the case a feature value is not
permitted in a given context.
It is a hash{feature}{value0}, leading to a list of values that can be
used to replace the value0, ordered by priority.

=cut
sub get_replacements
{
    if(!defined($replacements))
    {
        $replacements = _preprocess_list_of_replacements();
    }
    return $replacements;
}



#------------------------------------------------------------------------------
# Preprocesses the lists of replacement values defined above in the %matrix.
# In the original tagset::common module, this code was in the BEGIN block and
# it created the global hash %defaults1 from %defaults.
#------------------------------------------------------------------------------
sub _preprocess_list_of_replacements
{
    # This is a lazy attribute and the builder can be called anytime, even
    # from map() or grep(). Avoid damaging the caller's $_!
    local $_;
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
        foreach my $valarray (@{$matrix{$feature}{replacements}})
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
                        if(ref($defaults1{$feature}{$last}) ne 'ARRAY')
                        {
                            confess("Something went wrong when preparing replacement values for feature '$feature' and value '$last'");
                        }
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
            foreach my $valarray ([''], @{$matrix{$feature}{replacements}})
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
    my $defaults = get_replacements();
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
    my ($p, $r);
    $p = $score/$n_srch if($n_srch);
    $r = $score/$n_eval if($n_eval);
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
=method enforce_permitted_values()

  $fs->enforce_permitted_values ($permitted_trie);

Makes sure that a feature structure complies with the permitted combinations
recorded in a trie.
Takes a L<Lingua::Interset::Trie> object as a parameter.
Replaces feature values if needed.
(Note that even the empty value may or may not be permitted.)

=cut
sub enforce_permitted_values
{
    my $self = shift;
    my $trie = shift; # Lingua::Interset::Trie
    my $pointer = shift; # reference to a hash inside the trie, not necessarily the root hash
    if(!defined($pointer))
    {
        $pointer = $trie->root_hash();
    }
    my $debug = 0;
    my $features = $trie->features();
    my @features = @{$features};
    foreach my $feature (@features)
    {
        my $value = $self->get($feature);
        print("$feature: ", join(', ', map {"'$_' => '$pointer->{$_}'"} sort keys(%{$pointer})), "\n") if($debug);
        unless(exists($pointer->{$value}))
        {
            my $replacement = select_replacement($feature, $value, $pointer);
            print("$feature: '$value' => '$replacement'\n") if($debug);
            $self->set($feature, $replacement);
            $value = $replacement;
        }
        elsif($debug)
        {
            print("$feature: '$value' is ok\n");
        }
        $pointer = $trie->advance_pointer($pointer, $feature, $value);
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
=func iseq()

  if (Lingua::Interset::FeatureStructure->iseq ($a, $b)) { ... }

Compares two values, scalars or arrays, whether they are equal or not.
Takes two parameters.
Each of them can be a scalar or an array reference.

=cut
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
=func array_to_scalar_value()

Converts array values to scalars. Sorts the array and combines all elements
in one string, using the vertical bar as delimiter. Does not care about
occurrences of vertical bars inside the elements (there should be none
anyway).

Takes an array reference as parameter.
If the parameter turns out to be a plain scalar, the function just returns it.

=cut
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
=method duplicate()

Returns a new C<Lingua::Interset::FeatureStructure> object that is
a duplicate of the current structure.
Makes sure that a deep copy is constructed if there are any complex feature values.

=cut
sub duplicate
{
    my $self = shift;
    my $srchash = $self->get_hash();
    my $tgthash = _duplicate_recursive($srchash);
    my $duplicate = new Lingua::Interset::FeatureStructure();
    $duplicate->set_hash($tgthash);
    return $duplicate;
}
sub _duplicate_recursive
{
    my $source = shift;
    my $duplicate;
    my $ref = ref($source);
    if($ref eq 'ARRAY')
    {
        my @new_array;
        foreach my $element (@{$source})
        {
            push(@new_array, _duplicate_recursive($element));
        }
        $duplicate = \@new_array;
    }
    elsif($ref eq 'HASH')
    {
        my %new_hash;
        foreach my $key (keys(%{$source}))
        {
            $new_hash{$key} = _duplicate_recursive($source->{$key});
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

=head1 SYNOPSIS

  use Lingua::Interset::FeatureStructure;

  print(Lingua::Interset::FeatureStructure->known_features(), "\n");

=head1 DESCRIPTION

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

The C<FeatureStructure> class defines all morphosyntactic features and their values used
in DZ Interset. An object of this class represents a morphosyntactic tag
for a natural language word.

More information is given at the DZ Interset project page,
L<https://wiki.ufal.ms.mff.cuni.cz/user:zeman:interset:features>.

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>

=cut
