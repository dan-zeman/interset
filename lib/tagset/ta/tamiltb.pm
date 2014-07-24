#!/usr/bin/perl
# Driver for the TamilTB.v0.1 Tamil tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::ta::tamiltb;
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
    $f{tagset} = "ta::tamiltb";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos_big, $features) = split(/\s+/, $tag);

    if (length($subpos_big) != 9) {
        print "Tag length should be 9\n";
        print "Error tag: $subpos_big\n";
        die;
    }
    
    # cut only the second character from the positional tag
    # 2-nd position corresponds to sub pos
    my $subpos = substr $subpos_big, 1, 1;

    # nouns
    if($pos eq "N")
    {
        $f{pos} = "noun";

        if ($subpos eq "E") {
            $f{subpos} = "prop";
        }
        elsif ($subpos eq "P") {
            
        }
        
    }

    # adj = adjectives
    elsif($pos eq "J")
    {
        $f{pos} = "adj";
        if ($subpos eq "d") {
            $f{verbform} = "part";
        }
    }
    
    # pron = pronoun # example: que, outro, ela, certo, o, algum, todo, nós
    elsif($pos eq "R")
    {
        $f{pos} = "noun";
        if ($subpos eq "B") {
            $f{prontype} = "ind";            
        }
        elsif ($subpos eq "h") {
            $f{reflex} = "reflex";
        }
        elsif ($subpos eq "i") {
            $f{prontype} = "int";
        }
        elsif ($subpos eq "p") {
            $f{prontype} = "prs";
        }
    }

    # determiner
    elsif($pos eq "D")
    {
        $f{pos} = "adj";
        
        if ($subpos eq "D") {
            $f{subpos} = "det";
        }
    }
    
    # num = number # example: 0,05, cento_e_quatro, cinco, setenta_e_dois, um, zero
    elsif($pos eq "U")
    {
        $f{pos} = "num";
        
        if ($subpos eq "x") {
            $f{numtype} = "card";
        }
        elsif ($subpos eq "y") {
            $f{numtype} = "ord";
        }
        elsif ($subpos eq '=') {
            $f{numform} = "digit";
        }
    }

    # v = verb
    elsif($pos eq "V")
    {
        $f{pos} = "verb";
        
        if ($subpos =~ /^(R|T|U|W|Z)/) {
            $f{subpoos} = "aux";            
        }
        
    }

    # adv
    elsif($pos eq "A")
    {
        $f{pos} = "adv";
    }

    # prp
    elsif($pos eq "P")
    {
        $f{pos} = "prep";
    }

    # conj
    elsif($pos eq "C")
    {
        $f{pos} = "conj";
        if ($subpos eq "C") {
            $f{subpos} = "coor";
        }
    }

    # in
    elsif($pos eq "I")
    {
        $f{pos} = "int";
    }
    
    # quantifiers
    elsif ($pos eq "Q") {
        $f{pos} = "adj";
    }

    # punc
    elsif($pos eq "Z")
    {
        $f{pos} = "punc";
        
        if ($subpos eq "#") {
            $f{punctype} = "peri";
        }        
    }
    
    # particles
    elsif ($pos eq "T") {
        $f{pos} = "part";        
        if ($subpos =~ /^(k|q|o|v|s|S|m|l)$/) {
            $f{subpos} = "emp";
        }
        elsif ($subpos =~  /^(t|d|n|z)$/) {
            $f{subpos} = "sub"
        }
        elsif ($subpos eq "b") {
            $f{subpos} = "comp";
        }
    }

    # unknown X 
    elsif($pos eq "X")
    {
        $f{pos} = "noun";
    }

    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my @feat_val = split /\s*=\s*/, $feature;
        
        if ($feat_val[0] eq "Gen") {
            if ($feat_val[1] eq "M") {
                $f{gender} = "masc";                
            }
            elsif ($feat_val[1] eq "F") {
                $f{gender} = "fem";                
            }
            elsif ($feat_val[1] eq "N") {
                $f{gender} = "neut";                
            }
            elsif ($feat_val[1] eq "A") {
                $f{gender} = "com";
                $f{animateness} = "anim";
            }
            elsif ($feat_val[1] eq "H") {
                $f{gender} = "com";                
            }            
        }
        elsif ($feat_val[0] eq "Num") {
            if ($feat_val[1] eq "S") {
                $f{number} = "sing";                
            }
            elsif ($feat_val[1] eq "P") {
                $f{number} = "plu";                
            }
            else {
                $f{number} = "coll";                                
            }            
        }
        elsif ($feat_val[0] eq "Per") {
            if ($feat_val[1] eq "1") {
                $f{person} = "1";                
            }
            elsif ($feat_val[1] eq "2") {
                $f{person} = "2";                
            }
            elsif ($feat_val[1] eq "3") {
                $f{person} = "3";                
            }
        }
        elsif ($feat_val[0] eq "Ten") {
            if ($feat_val[1] eq "P") {
                $f{tense} = "pres";                
            }
            elsif ($feat_val[1] eq "F") {
                $f{tense} = "fut";                
            }
            elsif ($feat_val[1] eq "D") {
                $f{tense} = "past";                
            }            
        }
        elsif ($feat_val[0] eq "Voi") {
            if ($feat_val[1] eq "A") {
                $f{voice} = "act";                
            }
            elsif ($feat_val[1] eq "P") {
                $f{voice} = "pass";                
            }
        }
        elsif ($feat_val[0] eq "Neg") {
            if ($feat_val[1] eq "A") {
                $f{negativeness} = "pos";                
            }
            elsif ($feat_val[1] eq "N") {
                $f{negativeness} = "neg";                
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
