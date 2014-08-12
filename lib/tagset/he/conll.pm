#!/usr/bin/perl
# Driver for the Hebrew tagset.
# Tagset described in Yoav Goldberg: Automatic Syntactic Processing of Modern
# Hebrew Automatic Syntactic Processing of Modern Hebrew (2011), p. 32.
# TODO: try to use the official (but not as easy to process) resource:
# BGU Computational Linguistics Group. Hebrew morphological tagging guidelines.
# Technical report, Ben Gurion University of the Negev, 2008.
# <http://www.cs.bgu.ac.il/~adlerm/tagging-guideline.pdf>
# Copyright © 2013 Rudolf Rosa <rosa@ufal.mff.cuni.cz>
# License: GNU GPL
# TODO: now only converts FROM he, not TO he!!!

package tagset::he::conll;
use utf8;

#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my $f = {}; # features
    $f->{tagset} = "he::conll";
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # $pos is determined by $subpos -> use only $subpos
    process_subpos($f, $subpos);
    if ( $features ne '_' ) {
        process_features($f, $features);
    }
    return $f;
}

# Subposes found in some documentation have a description comming from there;
# undocumented subposes have an occurence count instead...
# TODO set all necessary categories
my $conllsubpos = {
    # Adverb appearing as prefix
    # כ
    'ADVERB' => { 'pos' => "adv", },
    # AT (direct object) marker
    # תא
    'AT' => { 'pos' => "part", },
    # Beinoni (participle) form
    # רושק, ףסונ, עגונ, רבודמ
    'BN' => { 'pos' => "verb", verbform => 'part', },
    # Beinoni Form with a possessive suffix
    # היבשוי
    'BN_S_PP' => { 'pos' => "verb", verbform => 'part', "poss" => "poss", },
    # Construct-state Beinoni Form
    # עבטמ, הברמ, תלזוא, יליחנמ, יכומ
    'BNT' => { 'pos' => "verb", verbform => 'part', },
    # Conjunction
    # ש, דוגינב, לככ, יפכ
    'CC' => { 'pos' => "conj", },
    # Coordinating Conjunction other than ו
    # םג, םא, וא, לבא, קר
    'CC-COORD' => { 'pos' => "conj", 'subpos' => "coor", },
    # Relativizing Conjunction
    # רשא
    'CC-REL' => { 'pos' => "conj", },
    # Subordinating Conjunction
    # יכ, ידכ, רחאל, רשאכ, ומכ
    'CC-SUB' => { 'pos' => "conj", 'subpos' => "sub", },
    # Number
    # תחא, 1, 0
    'CD' => { 'pos' => "num", },
    # Construct Numeral
    # ינש, יתש, יפלא, תואמ, תורשע
    'CDT' => { 'pos' => "num", 'synpos' => "attr"},
    # The ו coordinating word
    # ו
    'CONJ' => { 'pos' => "conj", 'subpos' => "coor", },
    # Copula (present) and Auxiliaries (past and future)
    # היה, ויה, התיה, וניא, היהי
    'COP' => { 'pos' => "verb", },
    #89 COP-TOINFINITIVE
    'COP-TOINFINITIVE' => { 'pos' => "verb", },
    # H marker (the definite article prefix)
    # ה
    'DEF' => { 'pos' => "adj", 'subpos' => "det", 'synpos' => "attr", },
    #53 DEF@DT
    'DEF@DT' => { 'pos' => "adj", 'subpos' => "det", 'synpos' => "attr", },
    # Determiner
    # יהשוזיא, רחבמ, לכ
    'DT' => { 'pos' => "adj", 'subpos' => "det", 'synpos' => "attr", },
    # Construct-state Determiner
    # המכ, ותוא, םוש, הברה
    'DTT' => { 'pos' => "adj", 'subpos' => "det", 'synpos' => "attr", },
    # Existential
    # שי, ןיא, םנשי, היה
    'EX' => { 'pos' => "adv", 'subpos' => "ex", },
    # Preposition
    # לע, ל, םע, ןיב
    'IN' => { 'pos' => "prep", },
    # Interjection
    # סופ, ףוא, הלילח, אנ, יוא
    'INTJ' => { 'pos' => "int", },
    # Adjective
    # םירחא, םיבר, שדח, לודג, ימואל
    'JJ' => { 'pos' => "adj", },
    # Construct-state Adjective
    # רבודמ, יעדומ, ילוער, תרסח, יבורמ
    'JJT' => { 'pos' => "adj", },
    # Modal
    # רשפא, לוכי, ךירצ, הלוכי, לולע
    'MD' => { 'pos' => "verb", 'subpos' => "mod", },
    # Numerical Expression
    # 03.02, 00.02, 11.61, 28.6.6, 11.31
    'NCD' => { 'pos' => "num", },
    # Noun
    # הרטשמ, הלשממ, םוי, ץרא
    'NN' => { 'pos' => "noun", },
    # Proper Nouns
    # לארשי, םילשורי, אנהכ, ביבא
    'NNP' => { 'pos' => "noun", 'subpos' => "prop", },
    # Noun with a possessive suffix
    # ותומ, וירבד, וייח, ופוס, ומש
    'NN_S_PP' => { 'pos' => "noun", "poss" => "poss", },
    # Construct-state nouns
    # ידי, תעדוו
    'NNT' => { 'pos' => "noun", },
    # “Prefix” wordlets
    # יתלב, יא, ןיב, תת, יטנא
    'P' => { 'pos' => "part", },
    # Possessive
    # לש
    'POS' => { 'pos' => "part", 'poss' => "poss", },
    # Prefix-Prepositions
    # ב, ל, מ, כ, שכ
    'PREPOSITION' => { 'pos' => "prep", },
    # Pronouns TODO prontype?
    # אוה, הז, איה, םה, וז
    'PRP' => { 'pos' => "noun", "prontype" => "prs", },
    #222 PRP-DEM
    'PRP-DEM' => { 'pos' => "adj", "prontype" => "dem", },
    #2 PRP-IMP TODO prontype?
    'PRP-IMP' => { 'pos' => "noun", "prontype" => "prs", },
    # Punctuation
    # ,, ., ־
    'PUNC' => { 'pos' => "punc", },
    # QuestionWord
    # המ, ימ, םאה, מ, ןכיה
    'QW' => { 'pos' => "adj", 'subpos' => "det", "synpos" => "attr", "prontype" => "int" },
    # Adverbs
    # אל, רתוי, דוע, רבכ, לומתא
    'RB' => { 'pos' => "adv", },
    # Relativizer
    # ש
    'REL-SUBCONJ' => { 'pos' => "adj", "prontype" => "rel", },
    # Nominative suffix
    # suffמה, suffאוה, suffאיה
    'S_ANP' => { 'pos' => "part", 'case' => "nom", },
    # Pronomial suffix TODO prontype?
    # suffאוה, suffמה, suffאיה
    'S_PRN' => { 'pos' => "part", "prontype" => "prs", },
    # Temporal Suboordinating Conjunction
    # שכ, שמ
    'TEMP-SUBCONJ' => { 'pos' => "conj", 'subpos' => "sub", },
    # Titles
    # ר״ד, ד״וע, בצינ, רוספורפ, רמ
    'TTL' => { 'pos' => "noun", },
    # Verbs
    # רמא, רמוא, הארנ, עדוי
    'VB' => { 'pos' => "verb", },
    #1 VB-BAREINFINITIVE
    'VB-BAREINFINITIVE' => { 'pos' => "verb", 'verbform' => "inf", },
    # Infinitive Verbs
    # תושעל, םלשל, עונמל, תתל, עצבל
    'VB-TOINFINITIVE' => { 'pos' => "verb", 'verbform' => "inf", },
    #550 !!MISS!!
    # words that do not have a correct analysis in the morphological analyzer
    '!!MISS!!' => { 'pos' => "", },
    #6 !!SOME_!!
    '!!SOME_!!' => { 'pos' => "", },
    #520 !!UNK!!
    # Words that lack an analysis in the Morphological Analyzer
    '!!UNK!!' => { 'pos' => "", },
    #134 !!ZVL!!
    '!!ZVL!!' => { 'pos' => "", },
};

# Yoav Goldberg:
# The tagging conversion was done in a semi-automated process (a heuristic
# mapping between the tagsets, which accounts for the tree context, was
# defined and applied. Some hard cases were left unresolved in the automatic
# process and marked for manual annotation). Words that lack an analysis in
# the Morphological Analyzer are assigned the tag !!UNK!!, and words that do
# not have a correct analysis in the morphological analyzer are assigned the
# tag !!MISS!!

sub process_subpos {
    my ($f, $subpos) = @_;

    my $set = $conllsubpos->{$subpos};
    if ( defined $set ) {
        foreach my $key (keys %$set) {
            $f->{$key} = $set->{$key};
        }
    }
    else {
        warn "Unknown Hebrew subpos $subpos\n";
    }

    return $f;
}

# TODO: usually guessed (i.e. maybe wrong)
my $conllfeats = {

    # used usually with nouns. pronouns, numerals, verbs and adjectives
    S => { number => 'sing' },
    P => { number => 'plu' },
    M => { gender => 'masc' },
    F => { gender => 'fem' },
    # used with NN and BN
    suf_S => { number => 'sing' },
    suf_P => { number => 'plu' },
    suf_M => { gender => 'masc' },
    suf_F => { gender => 'fem' },

    # used with VB, COP, MD, BN; NN, PRP, S_PRP, S_ANP
    1 => { person => '1' },
    2 => { person => '2' },
    3 => { person => '3' },
    # used with NN and BN
    suf_1 => { person => '1' },
    suf_2 => { person => '2' },
    suf_3 => { person => '3' },

    # used with COP and VB
    PAST => { tense => 'past' },
    FUTURE => { tense => 'fut' },
    IMPERATIVE => { mood => 'imp' },
    BEINONI => { verbform => 'part' },

    # used with COP
    POSITIVE => { negativeness => 'pos' },
    NEGATIVE => { negativeness => 'neg' },

    # used with PRP
    PERS => { prontype => 'prs' },
    DEM => { prontype => 'dem' },

    # unknown word
    '!!MISS!!' => { },
    '!!UNK!!' => { },

    # TODO unknown features (to me)

    # some verb features yet unknown to me (maybe the paradigm?)
    # used with VB, BN and BNT
    PAAL => { },
    HIFIL => { },
    PIEL => { },
    NIFAL => { },
    HITPAEL => { },
    HUFAL => { },
    PUAL => { },
    # this one is used with VB, BN, BNT and MD
    A => { },

    # used with PRP -- imperative pronoun? and anyway, which prontype?
    IMP => { prontype => 'prs' },

    # used with CDT, CD and NN
    D => { },

    # used with NN
    suf_MF => { },
    DP => { },
};

sub process_features {
    my ($f, $features) = @_;

    my @feats = split /\|/, $features;
    foreach my $feat (@feats) {
        my $set = $conllfeats->{$feat};
        if ( defined $set ) {
            foreach my $key (keys %$set) {
                $f->{$key} = $set->{$key};
            }
        }
        else {
            warn "Unknown Hebrew feature $feat\n";
        }
    }

    return $f;
}

#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
# TODO all (not yet touched) !!!
#------------------------------------------------------------------------------
sub encode
{
    my $f = shift; # this is not a deep copy! We must not modify the contents!
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    my $tag = $f->{pos};
    ###!!! To be implemented!
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



1;
