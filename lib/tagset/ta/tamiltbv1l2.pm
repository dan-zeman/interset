#!/usr/bin/perl
# Driver for the TamilTB 1.0 
# Copyright © 2014 Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# TamilTB 1.0 shortened tags 
# License: GNU GPL

package tagset::ta::tamiltbv1l2;
use utf8;
use Data::Dumper;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# 1
my %pos_map = (
    A   =>  'adv',
    C   =>  'conj',
    D   =>  'adj',
    I   =>  'int',
    J   =>  'adj',
    N   =>  'noun',
    P   =>  'prep',
    Q   =>  'adj',
    R   =>  'noun',
    T   =>  'part', 
    U   =>  'num',
    V   =>  'verb',
    Z   =>  'punc',
);

# 2
my %subpos_map = (
    a   =>  'prop',
    C   =>  'coor',
    D   =>  'det',
    E   =>  'prop',
    R   =>  'aux',
    T   =>  'aux',
    U   =>  'aux',
    W   =>  'aux',
    Z   =>  'aux',
);


#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "ta::tamiltbv1l2";

    # three components: coarse-grained pos, fine-grained pos, features
    my ($cpos, $pos, $feat) = split(/\s+/, $tag);

    if ((length($pos) % 2) != 0)  {
        print "Tag length should be 2\n";
        print "Error in tag: $pos\n";
        die;
    }

    #print $pos . "\n";

    # position : 1
    my $mainpos = substr $pos, 0, 1;
    # position : 2 
    my $subpos = substr $pos, 1, 1;
  
    #print "$mainpos, $subpos, $gender, $case, $person, $tense  \n";

    if (exists $pos_map{$mainpos}) {
        $f{pos} = $pos_map{$mainpos};
    }

    if (exists $subpos_map{$subpos}) {
        $f{subpos} = $subpos_map{$subpos};
    }
    
    if ($subpos eq '#') {
        $f{punctype} = 'peri';
    }
    
    if ($subpos eq 'b') {
        $f{degree} = 'comp';
    }

    if ($subpos =~ /(d|k)/) {
        $f{verbform} = 'part';
    }

    if ($subpos eq 'i') {
        $f{prontype} = 'int';
    }
   
    if ($subpos eq 'j') {
        $f{mood} = 'imp';
    }

    if ($subpos eq 'm') {
        $f{abbr} = 'abbr';
    }

    if ($subpos eq 'n') {
        $f{numform} = 'digit';
    }

    if ($subpos eq 'o') {
        $f{numtype} = 'ord';
    }
    
    if ($subpos eq 'p') {
        $f{prontype} = 'prs';
    }

    if ($subpos eq 'q') {
        $f{foreign} = 'foreign';
    }

    if ($subpos eq 'r') {
        $f{verbform} = 'fin';
    }

    if ($subpos =~ /(u|w)/) {
        $f{verbform} = 'inf';
    }

    if ($subpos eq 'x') {
        $f{numform} = 'roman';
    }

    if ($subpos eq 'z') {
        $f{verbform} = 'ger';
    }

    if ($subpos eq 'D') {
        $f{prontype} = 'dem';
    }

    if ($subpos eq 'R') {
        $f{verbform} = 'fin';
    }

    if ($subpos eq 'U') {
        $f{verbform} = 'inf';
    }

    if ($subpos eq 'W') {
        $f{verbform} = 'inf';
    }
    
    if ($subpos eq 'Z') {
        $f{verbform} = 'ger';
    }

    #print Dumper(\%f);
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
