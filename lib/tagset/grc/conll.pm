#!/usr/bin/perl
# Driver for the CoNLL format Ancient Greek data
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::grc::conll;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



my %featable =
(
    'pos=n' => ['pos' => 'noun'],
    'pos=v' => ['pos' => 'verb'],
    'pos=t' => ['pos' => 'verb', 'verbform' => 'part'],
    'pos=a' => ['pos' => 'adj'],
    'pos=d' => ['pos' => 'adv'],
    'pos=l' => ['pos' => 'adj', 'subpos' => 'art'],
    'pos=g' => ['pos' => 'part'],
    'pos=c' => ['pos' => 'conj'],
    'pos=r' => ['pos' => 'prep'],
    'pos=p' => ['pos' => 'noun', 'prontype' => 'prs'],
    'pos=m' => ['pos' => 'num'],
    'pos=i' => ['pos' => 'int'], # interjection
    'pos=e' => ['pos' => 'int'], # exclamation
    'pos=u' => ['pos' => 'punc'],
    'per=1' => ['person' => 1],
    'per=2' => ['person' => 2],
    'per=3' => ['person' => 3],
    'num=s' => ['number' => 'sing'],
    'num=p' => ['number' => 'plu'],
    'num=d' => ['number' => 'dual'],
    'ten=p' => ['tense' => 'pres'], # present
    'ten=i' => ['tense' => 'past', 'subtense' => 'imp', 'aspect' => 'imp'], # imperfect
    'ten=r' => ['tense' => 'past', 'aspect' => 'perf'], # perfect
    'ten=l' => ['tense' => 'past', 'subtense' => 'pqp'], # pluperfect
    'ten=t' => ['tense' => 'fut', 'aspect' => 'perf'], # future perfect
    'ten=f' => ['tense' => 'fut'], # future
    'ten=a' => ['tense' => 'past', 'subtense' => 'aor'], # aorist
    'mod=i' => ['verbform' => 'fin', 'mood' => 'ind'],
    'mod=s' => ['verbform' => 'fin', 'mood' => 'sub'],
    'mod=o' => ['verbform' => 'fin'], ###!!! optative
    'mod=n' => ['verbform' => 'inf'],
    'mod=m' => ['verbform' => 'fin', 'mood' => 'imp'],
    'mod=p' => ['verbform' => 'part'],
    'mod=d' => ['verbform' => 'ger'], ###!!! gerund
    'mod=g' => ['verbform' => 'ger'], ###!!! gerundive
    'voi=a' => ['voice' => 'act'],
    'voi=p' => ['voice' => 'pass'],
    'voi=m' => ['voice' => ''], ###!!! middle voice
    'voi=e' => ['voice' => 'pass'], ###!!! medio-passive
    'gen=m' => ['gender' => 'masc'],
    'gen=f' => ['gender' => 'fem'],
    'gen=n' => ['gender' => 'neut'],
    'cas=n' => ['case' => 'nom'],
    'cas=g' => ['case' => 'gen'],
    'cas=d' => ['case' => 'dat'],
    'cas=a' => ['case' => 'acc'],
    'cas=v' => ['case' => 'voc'],
    'cas=l' => ['case' => 'loc'],
    'deg=c' => ['degree' => 'comp'],
    'deg=s' => ['degree' => 'sup'],
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "grc::conll";
    # The Ancient Greek Dependency Treebank has been converted from the native XML format to CoNLL 2006.
    # The CPOS and POS columns are redundant because their values are also repeated in the FEAT column.
    # The original 9-character positional tags have been split and their features named, e.g.
    # v1spia--- => pos=v|per=1|num=s|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
    my ($cpos, $pos, $features) = split(/\s+/, $tag);
    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my @assignments = @{$featable{$feature}};
        for(my $i = 0; $i<=$#assignments; $i += 2)
        {
            $f{$assignments[$i]} = $assignments[$i+1];
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
# cat train.conll test.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 880
# 671 after cleaning and adding 'other'-resistant tags
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
-	-	pos=-|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
-	-	pos=-|per=-|num=-|ten=a|mod=-|voi=-|gen=-|cas=-|deg=-
-	-	pos=-|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
-	-	pos=-|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
-	-	pos=-|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
-	-	pos=-|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
-	-	pos=-|per=2|num=s|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
-	-	pos=-|per=3|num=p|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
-	-	pos=-|per=3|num=p|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
-	-	pos=-|per=3|num=p|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
-	-	pos=-|per=3|num=s|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
a	a	pos=a|per=-|num=-|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=-|cas=a|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=n|deg=s
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=n|deg=c
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
a	a	pos=a|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=d|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=g|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=g|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=-|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=g|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=v|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=-|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=-|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=v|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=d|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=g|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=a|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=d|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=g|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=g|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=-|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=-|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=-|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=v|deg=s
c	c	pos=c|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
c	c	pos=c|per=2|num=s|ten=a|mod=-|voi=p|gen=-|cas=-|deg=-
d	d	pos=d|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
d	d	pos=d|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=c
d	d	pos=d|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=s
e	e	pos=e|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
g	g	pos=g|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
l	l	pos=l|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
l	l	pos=l|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
l	l	pos=l|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
l	l	pos=l|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
l	l	pos=l|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
l	l	pos=l|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
l	l	pos=l|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
m	m	pos=m|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
n	n	pos=n|per=-|num=-|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
n	n	pos=n|per=-|num=-|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
n	n	pos=n|per=-|num=-|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
n	n	pos=n|per=-|num=-|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=-|cas=a|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
n	n	pos=n|per=-|num=d|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=g|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=g|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=v|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
p	p	pos=p|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
p	p	pos=p|per=-|num=-|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=-|cas=a|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=-|cas=g|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
p	p	pos=p|per=-|num=d|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=a|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=g|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=a|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=g|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=v|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
r	r	pos=r|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
t	t	pos=t|per=-|num=-|ten=-|mod=p|voi=-|gen=-|cas=-|deg=-
t	t	pos=t|per=-|num=-|ten=p|mod=p|voi=-|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=-|ten=p|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=-|ten=p|mod=p|voi=e|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=-|ten=p|mod=p|voi=e|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=-|ten=p|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=-|ten=r|mod=p|voi=e|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=m|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=p|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=a|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=f|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=e|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=e|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=e|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=p|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=r|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=d|ten=r|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=r|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=d|ten=r|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=-|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=-|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=-|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=f|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=e|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=m|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=a|mod=p|voi=p|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=-|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=-|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=-|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=m|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=m|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=m|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=m|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=-|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=-|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=-|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=-|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=-|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=e|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=m|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=m|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=m|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=m|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=m|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=p|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=p|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=p|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=-|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=-|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=e|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=m|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=m|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=-|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=-|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=-|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=-|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=-|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=-|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=f|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=e|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=e|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=e|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=m|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=a|mod=p|voi=p|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=-|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=-|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=-|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=m|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=-|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=-|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=-|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=-|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=-|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=f|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=e|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=m|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=p|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=p|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=-|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=-|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=e|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=m|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=m|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=m|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=m|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=n|cas=n|deg=-
u	u	pos=u|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=-|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=a|mod=n|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=a|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=a|mod=n|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=a|mod=n|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=a|mod=n|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=f|mod=n|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=f|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=f|mod=n|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=f|mod=n|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=p|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=p|mod=n|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=p|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=p|mod=n|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=p|mod=n|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=p|mod=n|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=r|mod=n|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=r|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=r|mod=n|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=r|mod=n|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=r|mod=n|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=t|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=t|mod=n|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=p|ten=-|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=s|ten=a|mod=m|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=-|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=-|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=d|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=o|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=o|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=s|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=a|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=f|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=f|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=f|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=f|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=f|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=i|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=i|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=l|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=l|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=l|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=r|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=r|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=r|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=t|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=t|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=-|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=o|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=o|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=s|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=a|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=i|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=i|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=l|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=l|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=t|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=a|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=a|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=a|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=f|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=f|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=i|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=l|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=p|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=p|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=p|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=p|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=p|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=d|ten=r|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=m|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=m|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=m|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=o|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=o|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=a|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=f|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=f|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=i|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=i|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=m|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=m|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=-|mod=-|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=-|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=m|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=m|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=m|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=o|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=o|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=s|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=a|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=i|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=i|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=i|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=l|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=l|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=-|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=-|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=m|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=m|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=o|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=m|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=t|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=t|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=-|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=-|ten=i|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=-|ten=r|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=a|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=a|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=a|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=f|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=i|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=i|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=l|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=l|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=l|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=p|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=p|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=p|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=d|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=m|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=o|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=o|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=a|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=l|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=l|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=l|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=l|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=s|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=-|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=-|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=-|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=m|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=m|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=o|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=o|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=s|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=a|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=f|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=f|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=f|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=f|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=l|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=l|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=l|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=l|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=-|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=m|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=m|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=o|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=o|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=o|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=s|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=s|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=s|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=m|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=o|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=t|mod=i|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=t|mod=i|voi=e|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=t|mod=i|voi=m|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=t|mod=i|voi=p|gen=-|cas=-|deg=-
x	x	pos=x|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
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
