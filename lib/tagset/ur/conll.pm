#!/usr/bin/perl
# Driver for Urdu tagset.
# Copyright © 2014 Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::ur::conll;
use utf8;
use Data::Dumper;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my %pos_map = (
		"CC"	=> 'conj',
		"DEM"	=> 'adj',
		"INJ"	=> 'int',
		"JJ"	=> 'adj',
		"JJC"	=> 'adj',
		"JJZ"	=> 'adj',
		"NEG"	=> 'part',
		"NN"	=> 'noun',
		"NNC"	=> 'noun',
		"NN-Ez"	=> 'noun',  # ????
		"NNP"	=> 'noun',
		"NNPC"	=> 'noun',
		"NNZ"	=> 'noun',
		"NST"	=> 'noun',
		"PRP"	=> 'noun',
		"QC"	=> 'num',
		"QF"	=> 'num',
		"QO"	=> 'num',
		"RB"	=> 'adv',
		"RBC"	=> 'adv',
		"RDP"	=> 'noun',
		"RP"	=> 'part',
		"SYM"	=> 'punc',
		"UNK"	=> 'noun',
		"VAUX"	=> 'verb',
		"VM"	=> 'verb',
		"VMC"	=> 'verb',
		"WQ"	=> 'noun',
);


#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "ur::conll";

    # three components: coarse-grained pos, fine-grained pos, features
    my ($cpos, $pos, $feat) = split(/\s+/, $tag);

	if (exists $pos_map{$pos}) {
		$f{pos} = $pos_map{$pos};	
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


# TODO
#
#  Only main POS has been converted .... Other features have to be mapped.
#
#