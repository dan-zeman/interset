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
