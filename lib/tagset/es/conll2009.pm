#!/usr/bin/perl
# Driver for the CoNLL 2009 Spanish tagset.
# Originally Italian decoder written by Dan Zeman and Loganathan Ramasamy
# adapted for Spanish by Zdeněk Žabokrtský
# further developed by Dan Zeman
# License: GNU GPL

package tagset::es::conll2009;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# Tagset documentation is in /net/data/CoNLL/2009/es/doc/tagsets.pdf
# The global hashes %translate_name and %translate_value provide an approximate mapping between the tagset and Interset.
# However, this approach is too simplistic because there is no 1-1 mapping between features and values on both sides.
# The decode() function solves the rest.

my %translate_name =
(
    'gen' => 'gender',
    'num' => 'number',
    'possessornum' => 'possnumber',
);

my %translate_value =
(
    pos =>
    {
        n => 'noun',
        s => 'prep',
        d => 'adj',
        f => 'punc',
        v => 'verb',
        a => 'adj',
        p => 'noun',
        c => 'conj',
        r => 'adv',
        z => 'num',
        w => 'noun', # date, name of day in week
        i => 'int',
    },
    gender =>
    {
        m => 'masc',
        f => 'fem',
        c => 'com', # the common could also be represented as ['masc','fem] but it has its own value in Interset
    },
    number =>
    {
        s => 'sing',
        p => 'plu',
        c => '', # ??? common; there is no common number in Interset; could be either unset, or set to ['sing'|'plu']
    },
    person =>
    {
        1 => '1',
        2 => '2',
        3 => '3',
    },
    possessornum =>
    {
        s => 'sing',
        p => 'plu',
        c => '', # ??? common
    },
);

my %translate_feature =
(
    'postype' =>
    {
        'common'        => [], # common is the default type of noun
        'proper'        => ['subpos' => 'prop'],
        'personal'      => ['prontype' => 'prs'],
        'possessive'    => ['prontype' => 'prs', 'poss' => 'poss'],
        'article'       => ['subpos' => 'art'],
        'demonstrative' => ['prontype' => 'dem'],
        'interrogative' => ['prontype' => 'int'],
        'indefinite'    => ['prontype' => 'ind'],
        'relative'      => ['prontype' => 'rel'],
        # Exclamative pronoun: only one occurrence in the corpus, 'qué' in
        # hubiera sospechado siquiera qué lejos estaba Fermina_Daza
        # should at least suspect how long Fermina_Daza was
        # This does not seem to be enough evidence to create a new pronoun type.
        'exclamative'   => ['prontype' => 'rel'],
        'numeral'       => ['pos' => 'num', 'numtype' => 'card'],
        'main'          => [], # main is the default type of verb
        'auxiliary'     => ['subpos' => 'aux'], # haber
        'semiauxiliary' => ['subpos' => 'aux'], # ser; Interset cannot distinguish semiauxiliary from auxiliary
        'coordinating'  => ['subpos' => 'coor'],
        'subordinating' => ['subpos' => 'sub'],
        'negative'      => ['negativeness' => 'neg'], # no; main POS is adverb; in other tagsets it could be negative particle
        'preposition'   => [], # all prepositions (pos=s) have also postype=preposition; otherwise, it only occurs once with the adverb de_acuerdo
        'currency'      => ['pos' => 'noun'], # although subclass of number (pos=z), these are noun identifiers of currencies (pesetas, dólares, euros)
        'percentage'    => [], # Interset does not distinguish percentual from normal counts: 20_por_ciento, 20%
    },
    # posfunction = participle occurs with syntactic adjectives (and one noun) that are morphologically verb participles
    'posfunction' =>
    {
        'participle'    => ['verbform' => 'part']
    },
    # Spanish pronouns can be also marked for case!
    'case' =>
    {
        'nominative' => ['case' => 'nom'], # yo, tú
        'dative'     => ['case' => 'dat'], # le, se, les
        'accusative' => ['case' => 'acc'], # le, la, se, les, las, lo, los
        'oblique'    => ['prepcase' => 'pre'] # mí, conmigo, ti, contigo, sí, consigo
    },
    'mood' =>
    {
        'infinitive'    => ['verbform' => 'inf'],
        'indicative'    => ['verbform' => 'fin', 'mood' => 'ind'],
        'imperative'    => ['verbform' => 'fin', 'mood' => 'imp'],
        'subjunctive'   => ['verbform' => 'fin', 'mood' => 'sub'],
        'gerund'        => ['verbform' => 'ger'],
        'pastparticiple'=> ['verbform' => 'part', 'tense' => 'past']
    },
    'tense' =>
    {
        'past'          => ['tense' => 'past'],
        'imperfect'     => ['tense' => 'past', 'subtense' => 'imp'],
        'present'       => ['tense' => 'pres'],
        'future'        => ['tense' => 'fut'],
        'conditional'   => ['mood' => 'cnd']
    },
    'contracted' =>
    {
        # Contracted preposition with definite article: del, al, frente_al, a_partir_del
        # DZ Interset does not cover this yet, although it is planned.
        'yes'           => []
    },
    'punct' =>
    {
        'bracket'       => ['punctype' => 'brck'],
        'colon'         => ['punctype' => 'colo'],
        'comma'         => ['punctype' => 'comm'],
        'etc'           => ['pos' => 'conj', 'subpos' => 'coor'],
        'exclamationmark'=>['punctype' => 'excl'],
        'hyphen'        => ['punctype' => 'dash'],
        'mathsign'      => ['punctype' => 'symb'],
        'period'        => ['punctype' => 'peri'],
        'questionmark'  => ['punctype' => 'qest'],
        'quotation'     => ['punctype' => 'quot'],
        'semicolon'     => ['punctype' => 'semi'],
        'slash'         => ['punctype' => 'colo'] # no special value for slash in Interset
    },
    'punctenclose' =>
    {
        'open'          => ['puncside' => 'ini'],
        'close'         => ['puncside' => 'fin']
    }
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    # two components: part of speech, features
    my ($pos, $features) = split(/\s/, $tag);
    my %f = ( tagset => "es::conll2009" );
    if(defined $translate_value{pos}{$pos})
    {
        $f{pos} = $translate_value{pos}{$pos};
    }
    foreach my $feature (split(/\|/, $features))
    {
        my ( $old_name, $old_value ) = split /\s*=\s*/, $feature;
        my @assignments = @{$translate_feature{$old_name}{$old_value}};
        if(@assignments)
        {
            for(my $i = 0; $i<=$#assignments; $i += 2)
            {
                $f{$assignments[$i]} = $assignments[$i+1];
            }
        }
        else
        {
            my $new_name = $translate_name{$old_name} || $old_name;
            my $new_value = $translate_value{$new_name}{$old_value};
            if (defined $new_value)
            {
                $f{$new_name} = $new_value;
            }
        }
    }
    return \%f;
}



#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
    my $f0 = shift;
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    # Modify the feature structure so that it contains values expected by this
    # driver.
    my $f = tagset::common::enforce_permitted_joint($f0, $permitted);
    my %f = %{$f}; # This is not a deep copy but $f already refers to a deep copy of the original %{$f0}.
    my $tag;
    # pos and subpos
    # Add the features to the part of speech.
    my @features;
    my $features = join("|", @features);
    if($features eq "")
    {
        $features = "_";
    }
    $tag .= "\t$features";
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# cat train.conll dev.conll eval-blind.conll trial.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[4]\t$x[6]\n"' |\
#   sort -u | wc -l
# 324
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
a	_
a	postype=ordinal|gen=f|num=p
a	postype=ordinal|gen=f|num=s
a	postype=ordinal|gen=m|num=p
a	postype=ordinal|gen=m|num=s
a	postype=qualificative
a	postype=qualificative|gen=c|num=c
a	postype=qualificative|gen=c|num=p
a	postype=qualificative|gen=c|num=s
a	postype=qualificative|gen=f|num=p
a	postype=qualificative|gen=f|num=p|posfunction=participle
a	postype=qualificative|gen=f|num=s
a	postype=qualificative|gen=f|num=s|posfunction=participle
a	postype=qualificative|gen=m|num=c
a	postype=qualificative|gen=m|num=p
a	postype=qualificative|gen=m|num=p|posfunction=participle
a	postype=qualificative|gen=m|num=s
a	postype=qualificative|gen=m|num=s|posfunction=participle
c	postype=coordinating
c	postype=subordinating
d	postype=article|gen=c|num=c
d	postype=article|gen=c|num=s
d	postype=article|gen=f|num=p
d	postype=article|gen=f|num=s
d	postype=article|gen=m|num=c
d	postype=article|gen=m|num=p
d	postype=article|gen=m|num=s
d	postype=demonstrative|gen=c|num=p
d	postype=demonstrative|gen=c|num=s
d	postype=demonstrative|gen=f|num=p
d	postype=demonstrative|gen=f|num=s
d	postype=demonstrative|gen=m|num=p
d	postype=demonstrative|gen=m|num=s
d	postype=exclamative|gen=c|num=c
d	postype=indefinite|gen=c|num=p
d	postype=indefinite|gen=c|num=s
d	postype=indefinite|gen=f|num=p
d	postype=indefinite|gen=f|num=s
d	postype=indefinite|gen=m|num=p
d	postype=indefinite|gen=m|num=s
d	postype=interrogative|gen=c|num=c
d	postype=interrogative|gen=f|num=p
d	postype=interrogative|gen=f|num=s
d	postype=interrogative|gen=m|num=p
d	postype=interrogative|gen=m|num=s
d	postype=numeral|gen=c|num=p
d	postype=numeral|gen=c|num=s
d	postype=numeral|gen=f|num=p
d	postype=numeral|gen=f|num=s
d	postype=numeral|gen=m|num=p
d	postype=numeral|gen=m|num=s
d	postype=possessive|gen=c|num=p|person=1|possessornum=s
d	postype=possessive|gen=c|num=p|person=2|possessornum=s
d	postype=possessive|gen=c|num=p|person=3
d	postype=possessive|gen=c|num=s|person=1|possessornum=s
d	postype=possessive|gen=c|num=s|person=2|possessornum=s
d	postype=possessive|gen=c|num=s|person=3
d	postype=possessive|gen=f|num=p|person=1|possessornum=p
d	postype=possessive|gen=f|num=p|person=2|possessornum=p
d	postype=possessive|gen=f|num=s|person=1|possessornum=p
d	postype=possessive|gen=f|num=s|person=2|possessornum=p
d	postype=possessive|gen=f|num=s|person=3
d	postype=possessive|gen=m|num=p|person=1|possessornum=p
d	postype=possessive|gen=m|num=p|person=3
d	postype=possessive|gen=m|num=s|person=1|possessornum=p
d	postype=possessive|gen=m|num=s|person=1|possessornum=s
d	postype=possessive|gen=m|num=s|person=3
f	_
f	punct=bracket|punctenclose=close
f	punct=bracket|punctenclose=open
f	punct=colon
f	punct=comma
f	punct=etc
f	punct=exclamationmark|punctenclose=close
f	punct=exclamationmark|punctenclose=open
f	punct=hyphen
f	punct=mathsign
f	punct=period
f	punct=questionmark|punctenclose=close
f	punct=questionmark|punctenclose=open
f	punct=quotation
f	punct=semicolon
f	punct=slash
i	_
n	_
n	postype=common|gen=c|num=c
n	postype=common|gen=c|num=p
n	postype=common|gen=c|num=s
n	postype=common|gen=f|num=c
n	postype=common|gen=f|num=p
n	postype=common|gen=f|num=s
n	postype=common|gen=m|num=c
n	postype=common|gen=m|num=p
n	postype=common|gen=m|num=s
n	postype=common|gen=m|num=s|posfunction=participle
n	postype=main|gen=c|num=s
n	postype=proper|gen=c|num=c
n	postype=proper|gen=f|num=s
p	_
p	gen=c|num=c
p	gen=c|num=c|person=3
p	gen=c|num=p|person=1
p	gen=c|num=p|person=2
p	gen=c|num=s|person=1
p	gen=c|num=s|person=2
p	gen=m
p	postype=demonstrative|gen=c|num=p
p	postype=demonstrative|gen=c|num=s
p	postype=demonstrative|gen=f|num=p
p	postype=demonstrative|gen=f|num=s
p	postype=demonstrative|gen=m|num=p
p	postype=demonstrative|gen=m|num=s
p	postype=exclamative|gen=c|num=c
p	postype=indefinite|gen=c|num=c
p	postype=indefinite|gen=c|num=p
p	postype=indefinite|gen=c|num=s
p	postype=indefinite|gen=f|num=p
p	postype=indefinite|gen=f|num=s
p	postype=indefinite|gen=m|num=p
p	postype=indefinite|gen=m|num=s
p	postype=interrogative|gen=c|num=c
p	postype=interrogative|gen=c|num=p
p	postype=interrogative|gen=c|num=s
p	postype=interrogative|gen=f|num=p
p	postype=interrogative|gen=m|num=p
p	postype=interrogative|gen=m|num=s
p	postype=numeral|gen=c|num=p
p	postype=numeral|gen=c|num=s
p	postype=numeral|gen=f|num=p
p	postype=numeral|gen=f|num=s
p	postype=numeral|gen=m|num=p
p	postype=numeral|gen=m|num=s
p	postype=personal|gen=c|num=c|person=1
p	postype=personal|gen=c|num=c|person=3
p	postype=personal|gen=c|num=c|person=3|case=accusative
p	postype=personal|gen=c|num=c|person=3|case=oblique
p	postype=personal|gen=c|num=p|person=1
p	postype=personal|gen=c|num=p|person=2
p	postype=personal|gen=c|num=p|person=2|polite=yes
p	postype=personal|gen=c|num=p|person=3
p	postype=personal|gen=c|num=p|person=3|case=accusative
p	postype=personal|gen=c|num=p|person=3|case=dative
p	postype=personal|gen=c|num=s|person=1
p	postype=personal|gen=c|num=s|person=1|case=nominative
p	postype=personal|gen=c|num=s|person=1|case=oblique
p	postype=personal|gen=c|num=s|person=2
p	postype=personal|gen=c|num=s|person=2|case=nominative
p	postype=personal|gen=c|num=s|person=2|case=oblique
p	postype=personal|gen=c|num=s|person=2|polite=yes
p	postype=personal|gen=c|num=s|person=3
p	postype=personal|gen=c|num=s|person=3|case=accusative
p	postype=personal|gen=c|num=s|person=3|case=dative
p	postype=personal|gen=f|num=p|person=3
p	postype=personal|gen=f|num=p|person=3|case=accusative
p	postype=personal|gen=f|num=s|person=1
p	postype=personal|gen=f|num=s|person=3
p	postype=personal|gen=f|num=s|person=3|case=accusative
p	postype=personal|gen=m|num=p|person=1
p	postype=personal|gen=m|num=p|person=3
p	postype=personal|gen=m|num=p|person=3|case=accusative
p	postype=personal|gen=m|num=s|person=3
p	postype=personal|gen=m|num=s|person=3|case=accusative
p	postype=possessive|gen=c|num=s|person=3
p	postype=possessive|gen=f|num=p|person=1|possessornum=p
p	postype=possessive|gen=f|num=p|person=3
p	postype=possessive|gen=f|num=p|person=3|possessornum=c
p	postype=possessive|gen=f|num=s|person=1|possessornum=p
p	postype=possessive|gen=f|num=s|person=1|possessornum=s
p	postype=possessive|gen=f|num=s|person=2|possessornum=s
p	postype=possessive|gen=f|num=s|person=3
p	postype=possessive|gen=f|num=s|person=3|possessornum=c
p	postype=possessive|gen=m|num=p|person=1|possessornum=p
p	postype=possessive|gen=m|num=p|person=2
p	postype=possessive|gen=m|num=p|person=2|possessornum=s
p	postype=possessive|gen=m|num=p|person=3
p	postype=possessive|gen=m|num=p|person=3|possessornum=c
p	postype=possessive|gen=m|num=s|person=1|possessornum=p
p	postype=possessive|gen=m|num=s|person=1|possessornum=s
p	postype=possessive|gen=m|num=s|person=2|possessornum=s
p	postype=possessive|gen=m|num=s|person=3
p	postype=possessive|gen=m|num=s|person=3|possessornum=c
p	postype=relative
p	postype=relative|gen=c|num=c
p	postype=relative|gen=c|num=p
p	postype=relative|gen=c|num=s
p	postype=relative|gen=f|num=p
p	postype=relative|gen=f|num=s
p	postype=relative|gen=m|num=p
p	postype=relative|gen=m|num=s
r	_
r	postype=negative
r	postype=preposition|gen=c|num=c
s	postype=preposition
s	postype=preposition|gen=c|num=c
s	postype=preposition|gen=m|num=s|contracted=yes
v	postype=auxiliary|gen=c|num=c|mood=gerund
v	postype=auxiliary|gen=c|num=c|mood=infinitive
v	postype=auxiliary|gen=c|num=p|person=1|mood=indicative|tense=conditional
v	postype=auxiliary|gen=c|num=p|person=1|mood=indicative|tense=future
v	postype=auxiliary|gen=c|num=p|person=1|mood=indicative|tense=imperfect
v	postype=auxiliary|gen=c|num=p|person=1|mood=indicative|tense=past
v	postype=auxiliary|gen=c|num=p|person=1|mood=indicative|tense=present
v	postype=auxiliary|gen=c|num=p|person=1|mood=subjunctive|tense=imperfect
v	postype=auxiliary|gen=c|num=p|person=1|mood=subjunctive|tense=present
v	postype=auxiliary|gen=c|num=p|person=2|mood=indicative|tense=imperfect
v	postype=auxiliary|gen=c|num=p|person=2|mood=indicative|tense=present
v	postype=auxiliary|gen=c|num=p|person=3|mood=imperative
v	postype=auxiliary|gen=c|num=p|person=3|mood=indicative|tense=conditional
v	postype=auxiliary|gen=c|num=p|person=3|mood=indicative|tense=future
v	postype=auxiliary|gen=c|num=p|person=3|mood=indicative|tense=imperfect
v	postype=auxiliary|gen=c|num=p|person=3|mood=indicative|tense=past
v	postype=auxiliary|gen=c|num=p|person=3|mood=indicative|tense=present
v	postype=auxiliary|gen=c|num=p|person=3|mood=subjunctive|tense=imperfect
v	postype=auxiliary|gen=c|num=p|person=3|mood=subjunctive|tense=present
v	postype=auxiliary|gen=c|num=s|person=1|mood=indicative|tense=future
v	postype=auxiliary|gen=c|num=s|person=1|mood=indicative|tense=imperfect
v	postype=auxiliary|gen=c|num=s|person=1|mood=indicative|tense=past
v	postype=auxiliary|gen=c|num=s|person=1|mood=indicative|tense=present
v	postype=auxiliary|gen=c|num=s|person=1|mood=subjunctive|tense=imperfect
v	postype=auxiliary|gen=c|num=s|person=1|mood=subjunctive|tense=present
v	postype=auxiliary|gen=c|num=s|person=2|mood=imperative
v	postype=auxiliary|gen=c|num=s|person=2|mood=indicative|tense=future
v	postype=auxiliary|gen=c|num=s|person=2|mood=indicative|tense=imperfect
v	postype=auxiliary|gen=c|num=s|person=2|mood=indicative|tense=present
v	postype=auxiliary|gen=c|num=s|person=3|mood=imperative
v	postype=auxiliary|gen=c|num=s|person=3|mood=indicative|tense=conditional
v	postype=auxiliary|gen=c|num=s|person=3|mood=indicative|tense=future
v	postype=auxiliary|gen=c|num=s|person=3|mood=indicative|tense=imperfect
v	postype=auxiliary|gen=c|num=s|person=3|mood=indicative|tense=past
v	postype=auxiliary|gen=c|num=s|person=3|mood=indicative|tense=present
v	postype=auxiliary|gen=c|num=s|person=3|mood=subjunctive|tense=imperfect
v	postype=auxiliary|gen=c|num=s|person=3|mood=subjunctive|tense=present
v	postype=auxiliary|gen=m|num=p|mood=pastparticiple
v	postype=auxiliary|gen=m|num=s|mood=pastparticiple
v	postype=main|gen=c|num=c|mood=gerund
v	postype=main|gen=c|num=c|mood=infinitive
v	postype=main|gen=c|num=p|person=1|mood=imperative
v	postype=main|gen=c|num=p|person=1|mood=indicative|tense=conditional
v	postype=main|gen=c|num=p|person=1|mood=indicative|tense=future
v	postype=main|gen=c|num=p|person=1|mood=indicative|tense=imperfect
v	postype=main|gen=c|num=p|person=1|mood=indicative|tense=past
v	postype=main|gen=c|num=p|person=1|mood=indicative|tense=present
v	postype=main|gen=c|num=p|person=1|mood=subjunctive|tense=imperfect
v	postype=main|gen=c|num=p|person=1|mood=subjunctive|tense=present
v	postype=main|gen=c|num=p|person=2|mood=imperative
v	postype=main|gen=c|num=p|person=2|mood=indicative|tense=imperfect
v	postype=main|gen=c|num=p|person=2|mood=indicative|tense=present
v	postype=main|gen=c|num=p|person=2|mood=subjunctive|tense=present
v	postype=main|gen=c|num=p|person=3|mood=imperative
v	postype=main|gen=c|num=p|person=3|mood=indicative|tense=conditional
v	postype=main|gen=c|num=p|person=3|mood=indicative|tense=future
v	postype=main|gen=c|num=p|person=3|mood=indicative|tense=imperfect
v	postype=main|gen=c|num=p|person=3|mood=indicative|tense=past
v	postype=main|gen=c|num=p|person=3|mood=indicative|tense=present
v	postype=main|gen=c|num=p|person=3|mood=subjunctive|tense=imperfect
v	postype=main|gen=c|num=p|person=3|mood=subjunctive|tense=present
v	postype=main|gen=c|num=s|person=1|mood=indicative|tense=conditional
v	postype=main|gen=c|num=s|person=1|mood=indicative|tense=future
v	postype=main|gen=c|num=s|person=1|mood=indicative|tense=imperfect
v	postype=main|gen=c|num=s|person=1|mood=indicative|tense=past
v	postype=main|gen=c|num=s|person=1|mood=indicative|tense=present
v	postype=main|gen=c|num=s|person=1|mood=subjunctive|tense=imperfect
v	postype=main|gen=c|num=s|person=1|mood=subjunctive|tense=present
v	postype=main|gen=c|num=s|person=2|mood=imperative
v	postype=main|gen=c|num=s|person=2|mood=indicative|tense=conditional
v	postype=main|gen=c|num=s|person=2|mood=indicative|tense=future
v	postype=main|gen=c|num=s|person=2|mood=indicative|tense=imperfect
v	postype=main|gen=c|num=s|person=2|mood=indicative|tense=past
v	postype=main|gen=c|num=s|person=2|mood=indicative|tense=present
v	postype=main|gen=c|num=s|person=2|mood=subjunctive|tense=present
v	postype=main|gen=c|num=s|person=3|mood=imperative
v	postype=main|gen=c|num=s|person=3|mood=indicative|tense=conditional
v	postype=main|gen=c|num=s|person=3|mood=indicative|tense=future
v	postype=main|gen=c|num=s|person=3|mood=indicative|tense=imperfect
v	postype=main|gen=c|num=s|person=3|mood=indicative|tense=past
v	postype=main|gen=c|num=s|person=3|mood=indicative|tense=present
v	postype=main|gen=c|num=s|person=3|mood=subjunctive|tense=imperfect
v	postype=main|gen=c|num=s|person=3|mood=subjunctive|tense=present
v	postype=main|gen=c|person=3|mood=indicative|tense=present
v	postype=main|gen=f|num=p|mood=pastparticiple
v	postype=main|gen=f|num=s|mood=pastparticiple
v	postype=main|gen=m|num=p|mood=pastparticiple
v	postype=main|gen=m|num=s|mood=pastparticiple
v	postype=main|gen=m|num=s|person=3|mood=indicative|tense=present
v	postype=semiauxiliary|gen=c|num=c|mood=gerund
v	postype=semiauxiliary|gen=c|num=c|mood=infinitive
v	postype=semiauxiliary|gen=c|num=p|person=1|mood=indicative|tense=imperfect
v	postype=semiauxiliary|gen=c|num=p|person=1|mood=indicative|tense=present
v	postype=semiauxiliary|gen=c|num=p|person=1|mood=subjunctive|tense=present
v	postype=semiauxiliary|gen=c|num=p|person=3|mood=indicative|tense=conditional
v	postype=semiauxiliary|gen=c|num=p|person=3|mood=indicative|tense=future
v	postype=semiauxiliary|gen=c|num=p|person=3|mood=indicative|tense=imperfect
v	postype=semiauxiliary|gen=c|num=p|person=3|mood=indicative|tense=past
v	postype=semiauxiliary|gen=c|num=p|person=3|mood=indicative|tense=present
v	postype=semiauxiliary|gen=c|num=p|person=3|mood=subjunctive|tense=imperfect
v	postype=semiauxiliary|gen=c|num=p|person=3|mood=subjunctive|tense=present
v	postype=semiauxiliary|gen=c|num=s|person=1|mood=indicative|tense=conditional
v	postype=semiauxiliary|gen=c|num=s|person=1|mood=indicative|tense=future
v	postype=semiauxiliary|gen=c|num=s|person=1|mood=indicative|tense=imperfect
v	postype=semiauxiliary|gen=c|num=s|person=1|mood=indicative|tense=past
v	postype=semiauxiliary|gen=c|num=s|person=1|mood=indicative|tense=present
v	postype=semiauxiliary|gen=c|num=s|person=1|mood=subjunctive|tense=future
v	postype=semiauxiliary|gen=c|num=s|person=1|mood=subjunctive|tense=present
v	postype=semiauxiliary|gen=c|num=s|person=2|mood=imperative
v	postype=semiauxiliary|gen=c|num=s|person=2|mood=indicative|tense=conditional
v	postype=semiauxiliary|gen=c|num=s|person=2|mood=indicative|tense=imperfect
v	postype=semiauxiliary|gen=c|num=s|person=2|mood=indicative|tense=present
v	postype=semiauxiliary|gen=c|num=s|person=2|mood=subjunctive|tense=present
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=imperative
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=indicative|tense=conditional
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=indicative|tense=future
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=indicative|tense=imperfect
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=indicative|tense=past
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=indicative|tense=present
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=subjunctive|tense=future
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=subjunctive|tense=imperfect
v	postype=semiauxiliary|gen=c|num=s|person=3|mood=subjunctive|tense=present
v	postype=semiauxiliary|gen=m|num=s|mood=pastparticiple
w	_
w	postype=common|gen=m|num=s
z	_
z	postype=common|gen=m|num=p
z	postype=currency
z	postype=percentage
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



#------------------------------------------------------------------------------
# Create trie of permitted feature structures. This will be needed for strict
# encoding. This BEGIN block cannot appear before the definition of the list()
# function.
#------------------------------------------------------------------------------
BEGIN
{
    # Store the hash reference in a global variable.
    $permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
