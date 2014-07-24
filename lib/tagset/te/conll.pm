#!/usr/bin/perl
# Driver for the CoNLL 2006 Telugu tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::te::conll;
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
    $f{tagset} = "te::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    
    # For telugu proper pos is stored in subpos.
    $pos = $subpos;
    
    # pos: ADJ ADV CD CNJ GR ITJ NAME N NT N P PreN PS PUNC PV UNIT VADJ VAUX VS V xxx

    # nouns
    if($pos =~ /^(NN|NNC|NNP|NNPC|NST|NSTC|PRP|PRPC|WQ|ECH|XC)$/)
    {
        $f{pos} = "noun";
        
        if ($pos =~ /^(NNP|NNPC)$/) {
            $f{subpos} = "prop";
        }
        
        if ($pos eq "PRP") {
            $f{prontype} = "prs";
        }
        elsif ($pos eq "WQ") {
            $f{prontype} = "int";
        }
   
    }
    # adjectives
    elsif($pos =~ /^(DEM|JJ|JJC|QF|QFC)$/)
    {
        $f{pos} = "adj";
        
        if ($pos eq "DEM") {
            $f{subpos} = "det";
        }
    }
    # numeral
    elsif($pos =~ /^(QC|QCC|QO)$/)
    {
        $f{pos} = "num";
        
        if ($pos eq "QC" || $pos eq "QCC") {
            $f{numtype} = "card";
        }
        
        if ($pos eq "QO") {
            $f{numtype} = "ord";            
        }
    }
    # v = verb
    elsif(($pos =~ /^(VM|VMC|VAUX)$/))
    {
        $f{pos} = "verb";

        if ($pos eq "VAUX") {
            $f{subpos} = "mod";
        }
    }
    # adverb
    elsif($pos eq "RB" || $pos eq "RBC" || $pos eq "RDP" || $pos eq "INTF" || $pos eq "NEG")
    {
        $f{pos} = "adv";
    }
    # postposition
    elsif($pos eq "PSP")
    {
        $f{pos} = "prep";
    }
    # conjunction
    elsif($pos eq "CC" | $pos eq "UT")
    {
        $f{pos} = "conj";
        
        if ($pos eq "UT") {
            $f{subpos} = "sub";
        }
    }
    # interjection
    elsif($pos eq "INJ")
    {
        $f{pos} = "int";
    }
    # punctuation
    elsif($pos eq "SYM")
    {
        $f{pos} = "punc";
    }
    elsif ($pos eq "RP") {
        $f{pos} = "part";
    }
    # ? = unknown tag "xxx"
    elsif($pos eq "UNK")
    {
        $f{pos} = "noun";
    }
    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my @ind = split /\-/, $feature;
        my $len = scalar(@ind);
        if ($len == 2) {
            if ($ind[0] eq "gend") {
                if ($ind[1] eq "m") {
                    $f{gender} = "masc";
                }
                elsif ($ind[1] eq "f") {
                    $f{gender} = "fem";
                }
                elsif ($ind[1] eq "n") {
                    $f{gender} = "neut";
                }
                else {
                    $f{gender} = "com";
                }
            }
            elsif ($ind[0] eq "num") {
                if ($ind[1] eq "sg") {
                    $f{number} = "sing";
                }
                elsif ($ind[1] eq "pl") {
                    $f{number} = "plu";
                }
                elsif ($ind[1] eq "dual") {
                    $f{number} = "dual";
                }
                else {
                    $f{number} = "dual";
                }
            }
            elsif ($ind[0] eq "pers") {
                if ($ind[1] eq "1") {
                    $f{person} = "1";
                }
                elsif ($ind[1] eq "2") {
                    $f{person} = "2";
                }
                elsif ($ind[1] eq "3") {
                    $f{person} = "3";
                }
                else {
                    $f{person} = "3";
                }
            }
            elsif ($ind[0] eq "voicetype") {
                if ($ind[1] eq "active") {
                    $f{voice} = "act";
                }
                elsif ($ind[1] eq "passive") {
                    $f{voice} = "pass";
                }                    
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
