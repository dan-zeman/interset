#!/usr/bin/perl
# Driver for the tagset of the Persian Dependency Treebank.
# Copyright © 2012 Dan Zeman
# License: GNU GPL

package tagset::fa::conll;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');



# Tagset documentation is at
# https://wiki.ufal.ms.mff.cuni.cz/_media/user:zeman:treebanks:persian-dependency-treebank-version-0.1-annotation-manual-and-user-guide.pdf

my %postable =
(
    # coarse ADJ
    'AJP'   => ['pos' => 'adj', 'degree' => 'pos'], # dígr, islámí, bzrg, jdíd, mxtlf
    'AJCM'  => ['pos' => 'adj', 'degree' => 'comp'], # bíštr, bíš, bhtr, bíštrí, kmtr
    'AJSUP' => ['pos' => 'adj', 'degree' => 'sup'], # bhtrín, mhmtrín, bzrgtrín, bíštrín, qwítrín
    '_'     => ['pos' => 'adj'], # wláyí, xúdsáxte, wárd, xúbí (undocumented)
    # coarse ADR: address term
    'PRADR'  => ['pos' => 'adj'], # í, yá, áháí (pre-noun morpheme to "make the noun the address of the speaker")
    'POSADR' => ['pos' => 'adj'], # á (post-noun morpheme to "make the noun the address of the speaker")
    # coarse ADV
    'SADV' => ['pos' => 'adv'], # hm, níz, htí, ne, xílí (genuine adverbs)
    'AVP'  => ['pos' => 'adv', 'degree' => 'pos'], # hm, tnhá, dígr, xúb, ps (positive adjectives modifying verbs)
    'AVCM' => ['pos' => 'adv', 'degree' => 'comp'], # bíštr, bíš, kmtr, bhtr, zúdtr (comparative adjectives modifying verbs)
    # coarse CL (undocumented)
    'MEAS' => ['pos' => 'noun'], # kílú (only one occurrence of this one word form) + one N MEAS: qášq
    # coarse CONJ
    'CONJ' => ['pos' => 'conj', 'subpos' => 'coor'], # w, yá, amá, wlí, ke
    # coarse IDEN
    'IDEN' => ['pos' => 'noun'], # imám, dktr, šhíd, síd, áytalláh (titles used with personal names)
    # coarse N
    'ANM'  => ['pos' => 'noun', 'animateness' => 'anim'], # xdá, ksí, ansán, xadáwand, nfr
    'IANM' => ['pos' => 'noun', 'animateness' => 'inan'], # sál, kár, írán, rúz, dst
    # coarse PART
    'PART' => ['pos' => 'part'], # áyá, ke, mgr, rá, dígr
    # coarse POSNUM
    'POSNUM' => ['pos' => 'num'], # awl, dúm, súm, čhárm, nxst (post-noun numeral)
    # coarse POSTP
    'POSTP' => ['pos' => 'prep', 'subpos' => 'post'], # rá, čún, az, rfte, mrá
    # coarse PR
    'SEPER' => ['pos' => 'noun', 'prontype' => 'prs'], # mn, tú, aw, má, šmá, ánhá (separate personal pronoun)
    'JOPER' => ['pos' => 'noun', 'prontype' => 'prs'], # m, t, š, mán, tán, šán (enclitic personal pronoun)
    'DEMON' => ['pos' => 'noun', 'prontype' => 'dem'], # án, ín, hmín, čnán, ánjá (demonstrative pronoun)
    'INTG'  => ['pos' => 'noun', 'prontype' => 'int'], # če, kjá, čgúne, čí, črá (interrogative pronoun)
    'CREFX' => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'reflex'], # xod, xwíš, hm, ykdígr, hmdígr (common reflexive pronoun)
    'UCREFX'=> ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'reflex'], # (noncommon reflexive pronoun: not present in data)
    'RECPR' => ['pos' => 'noun', 'prontype' => 'rcp'], # (reciprocal pronoun: not present in data)
    '_'     => ['pos' => 'noun', 'prontype' => 'prs'], # hm, ykdígr, hmdígr, xúdš, xúdšán ###!!! The '_' fine POS also occurs with adjectives!
    # coarse PREM (pre-modifier of nouns)
    'EXAJ'  => ['pos' => 'adj'], # če, čqdr, án, čnd, ajb (exclamatory: express speaker's surprise towards the modified noun)
    'QUAJ'  => ['pos' => 'adj', 'prontype' => 'int'], # če, kdám, čnd, kdámín (interrogative)
    'DEMAJ' => ['pos' => 'adj', 'prontype' => 'dem'], # ín, án, hmán, hmín, čnín (demonstrative)
    'AMBAJ' => ['pos' => 'adj'], # hr, čnd, híč, brxí, hme (ambiguous)
    # coarse PRENUM (pre-noun numeral)
    'PRENUM' => ['pos' => 'num'], # ek, do, se, úlín, čhár
    # coarse PREP
    'PREP' => ['pos' => 'prep'], # be, dr, az, bá, bráí
    'POST' => ['pos' => 'prep', 'subpos' => 'post'], # zmn
    # coarse PSUS (pseudo-sentence; instead of verb)
    'PSUS' => [], # káš, ne, angár, ya'aní, ble
    # coarse PUNC
    'PUNC' => ['pos' => 'punc'], # ., ,, ?, !, "
    # coarse V
    'ACT'  => ['pos' => 'verb', 'voice' => 'act'], # míknnd, hstnd, dárnd, mídhnd, mítwánnd
    'PASS' => ['pos' => 'verb', 'voice' => 'pass'], # míšúnd, šde, dádemíšúnd, zádemíšúnd, gdárdemíšúnd
    'MODL' => ['pos' => 'verb', 'subpos' => 'mod'], # báyd, nbáyd, mítwán, nmítwánd, míšúd
    # coarse SUBR (subordinating conjunction)
    'SUBR' => ['pos' => 'conj', 'subpos' => 'sub'], # ke, agr, tá, zírá, čún
);

my %featable =
(
    # attachment type
    # Orthographic words may have been broken into parts during tokenization in order to show syntactic relations between morphemes. Examples:
    # didämäš => didäm|äš (äš is object of the verb didäm)
    # mära => mä (contracted form of the personal pronoun män) | ra (postposition, could play object or complement adposition of the verb)
    # The attachment feature makes restoration of orthographic words possible.
    'attachment=ISO' => [], # isolated word
    'attachment=PRV' => [], # attached to the previous word
    'attachment=NXT' => [], # attached to the next word
    # person
    'person=1' => ['person' => 1], # mn, xúdm, án, má, xúdmán
    'person=2' => ['person' => 2], # tú, xúdt, šmá, xúdtán, šmáhá
    'person=3' => ['person' => 3], # ú, án, ín, ánhá, ánán
    # number
    'number=SING' => ['number' => 'sing'], # xdá, ksí, ansán, xdáwnd, nfr
    'number=PLUR' => ['number' => 'plu'], # mrdm, ksání, dígrán, afrád, znán
    # verb form, mood, tense and aspect (example verb xordän = to eat)
    'HA'    => ['verbform' => 'fin', 'mood' => 'imp'], # boxor
    'AY'    => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'fut'], # xahäm xord (indicative future)
    'GNES'  => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'], # mixordeäm (indicative imperfective perfect)
    'GBES'  => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'], # mixorde budäm (indicative imperfective pluperfect)
    'GES'   => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'], # mixordäm (indicative imperfective preterite)
    'GN'    => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'], # xordeäm (indicative perfect)
    'GB'    => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'], # xorde budäm (indicative pluperfect)
    'H'     => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'pres'], # mixoräm (indicative present)
    'GS'    => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'], # xordäm (indicative preterite)
    'GBESE' => ['verbform' => 'fin', 'mood' => 'sub', 'tense' => 'past'], # mixorde bude bašäm (subjunctive imperfective pluperfect)
    'GESEL' => ['verbform' => 'fin', 'mood' => 'sub', 'tense' => 'past'], # mixorde bašäm (subjunctive imperfective preterite)
    'GBEL'  => ['verbform' => 'fin', 'mood' => 'sub', 'tense' => 'past'], # xorde bude bašäm (subjunctive pluperfect)
    'HEL'   => ['verbform' => 'fin', 'mood' => 'sub', 'tense' => 'pres'], # boxoräm (subjunctive present)
    'GEL'   => ['verbform' => 'fin', 'mood' => 'sub', 'tense' => 'past'], # xorde bašäm (subjunctive preterite)
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f = ( tagset => 'fa::conll' );
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s/, $tag);
    my @features = split(/\|/, $features);
    my @assignments = @{$postable{$subpos}};
    map {push(@assignments, @{$featable{$_}})} (@features);
    for(my $i = 0; $i<=$#assignments; $i += 2)
    {
        $f{$assignments[$i]} = $assignments[$i+1];
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
# cat train.conll test.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 880
# 671 after cleaning and adding 'other'-resistant tags
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
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
    #$permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
