#!/usr/bin/perl
# Driver for the CoNLL 2007 Modern Greek.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::el::conll;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "el::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);

    # nouns
    if($pos =~ /^(No)$/)
    {
        $f{pos} = "noun";
        
        if ($subpos eq "NoPr") {
            $f{subpos} = "prop";
        }
    }
    elsif ($pos eq "Pn") {
        $f{pos} = "noun";
        
        if ($subpos eq "PnPe") {
            $f{prontype} = "prs";
        }
        elsif ($subpos eq "PnPo") {
            $f{prontype} = "prs";
        }
        elsif ($subpos eq "PnRe") {
            $f{prontype} = "rel";    
        }
        elsif ($subpos eq "PnRi") {
            $f{prontype} = "rel";    
        }
        elsif ($subpos eq "PnDm") {
            $f{prontype} = "dem";    
        }
        elsif ($subpos eq "PnIr") {
            $f{prontype} = "int";    
        }
        elsif ($subpos eq "PnId") {
            $f{prontype} = "ind";    
        }          
        
    }
    elsif ($pos eq "DIG") {
        $f{pos} = "noun";
        $f{numform} = "digit";
    }
    elsif ($pos eq "Rg") {
        $f{pos} = "noun";
    }
    # adjectives
    elsif($pos =~ /^(Aj)$/)
    {
        $f{pos} = "adj";
    }

    # numeral
    elsif($pos =~ /^(Nm)$/)
    {
        $f{pos} = "num";
        
        if ($subpos eq "NumCd") {
            $f{numtype} = "card";
        }        
        elsif ($subpos eq "NumOd") {
            $f{numtype} = "ord";            
        }
        elsif ($subpos eq "NumCt") {
            $f{numtype} = "gen";            
        }
        elsif ($subpos eq "NumMl") {
            $f{numtype} = "mult";            
        }        
    }
    
    # v = verb
    elsif(($pos =~ /^(Vb)$/))
    {
        $f{pos} = "verb";
    }
    
    # adverb
    elsif($pos eq "Ad")
    {
        $f{pos} = "adv";
    }
    # postposition
    elsif($pos eq "AsPp")
    {
        $f{pos} = "prep";
    }
    elsif($pos eq "At") {
        $f{pos} = "adj";
        if ($subpos eq "AtDf") {
            $f{subpos} = "art";
            $f{definiteness} = "def";
        }
        elsif ($subpos eq "AtId") {
            $f{subpos} = "art";
            $f{definiteness} = "ind";
        }        
    }
    
    # conjunction
    elsif($pos eq "Cj")
    {
        $f{pos} = "conj";
        
        if ($subpos eq "CjCo") {
            $f{subpos} = "coor";
        }
        elsif ($subpos eq "CjSb") {
            $f{subpos} = "sub";
        }        
    }

    # punctuation
    elsif($pos eq "PUNCT")
    {
        $f{pos} = "punc";
    }
    elsif ($pos eq "Pt") {
        $f{pos} = "part";
    }
    elsif ($pos =~ /^(DATE|ENUM)$/) {
        $f{pos} = "noun";
    }
    elsif ($pos =~ /^(COMP|INIT|LSPLIT)$/) {
        $f{pos} = "noun";
    }    

    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        # gender
        $f{gender} = "masc" if $feature eq "Ma";
        $f{gender} = "fem" if $feature eq "Fe";
        $f{gender} = "neut" if $feature eq "Ne";
        
        # person
        $f{person} = "1" if $feature eq "01";
        $f{person} = "2" if $feature eq "02";
        $f{person} = "3" if $feature eq "03";
        
        # number 
        $f{number} = "sing" if $feature eq "Sg";
        $f{number} = "plu" if $feature eq "Pl";
        
        # case features
        $f{case} = "nom" if $feature eq "Nm";
        $f{case} = "gen" if $feature eq "Ge";
        $f{case} = "acc" if $feature eq "Ac";
        $f{case} = "voc" if $feature eq "Vo";
        $f{case} = "dat" if $feature eq "Da";
        
        $f{degree} = "comp" if $feature eq "Cp";                        
        $f{degree} = "sup" if $feature eq "Su";
        
        # verb features
        $f{verbform} = "inf" if $feature eq "Nf";
        $f{verbform} = "part" if $feature eq "Pp";
        $f{mood} = "ind" if $feature eq "Id";
        $f{mood} = "imp" if $feature eq "Mp";                
        $f{tense} = "past" if $feature eq "Pa";
        $f{tense} = "pres" if $feature eq "Pr";
        
        # voice
        $f{voice} = "act" if $feature eq "Av";
        $f{voice} = "pass" if $feature eq "Pv";            

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
