#!/usr/bin/perl
# Driver for the CoNLL 2007 Turkish
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::tr::conll;
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
    $f{tagset} = "tr::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);

    # nouns
    if($pos eq 'Noun')
    {
        $f{pos} = "noun";
        
        if ($subpos eq "NFutPart") {
            $f{verbform} = "part";
            $f{tense} = "fut";
        }
        elsif ($subpos eq "NPastPart") {
            $f{verbform} = "part";
            $f{tense} = "past";
        }
        elsif ($subpos eq "NPresPart") {
            $f{verbform} = "part";
            $f{tense} = "pres";
        }
        elsif ($subpos eq "NInf") {
            $f{verbform} = "inf";
        }        
        elsif ($subpos eq "Prop") {
            $f{subpos} = "prop";
        }
        
    }
    elsif ($pos eq 'Dup') {
        $f{pos} = 'noun';
    }
    # Question
    elsif ($pos eq 'Ques') {
        $f{pos} = 'noun';
        $f{prontype} = 'int';
    }
    
    # pronouns
    elsif ($pos eq 'Pron') {
        $f{pos} = 'noun';
        
        if ($subpos eq 'DemonsP') {
            $f{prontype} = 'dem';
        }
        elsif ($subpos eq 'PersP') {
            $f{prontype} = 'prs';
        }
        elsif ($subpos eq 'QuesP') {
            $f{prontype} = 'int';
        }
        elsif ($subpos eq 'ReflexP') {
            $f{reflex} = 'reflex';
        }        
    }
    
    # adjectives
    elsif($pos eq 'adj')
    {
        $f{pos} = "adj";
        
        if ($subpos eq "AFutPart") {
            $f{verbform} = "part";
            $f{tense} = "fut";
        }
        elsif ($subpos eq "APastPart") {
            $f{verbform} = "part";
            $f{tense} = "past";
        }
        elsif ($subpos eq "APresPart") {
            $f{verbform} = "part";
            $f{tense} = "pres";
        }        
    }
    # determiners
    elsif ($pos eq 'det') {
        $f{pos} = 'adj';
        $f{subpos} = 'det';
    }

    # numeral
    elsif($pos eq 'Num')
    {
        $f{pos} = "num";
        
        if ($subpos eq 'Card') {
            $f{numtype} = "card";
        }        
        elsif ($subpos eq 'Ord') {
            $f{numtype} = "ord";            
        }
        elsif ($subpos eq "Real") {
            $f{numform} = "digit";            
        }
        elsif ($subpos eq "Range") {
            $f{numform} = "digit";            
        }        
    }
    
    # v = verb
    elsif ($pos eq 'Verb')
    {
        $f{pos} = "verb";
    }
    
    # adverb
    elsif($pos eq "Adv")
    {
        $f{pos} = "adv";
    }
    
    # postposition
    elsif($pos eq 'Postp')
    {
        $f{pos} = "prep";
    }
    
    # conjunction
    elsif($pos eq "Conj")
    {
        $f{pos} = "conj";
    }
    
    # interjection
    elsif($pos eq "Interj")
    {
        $f{pos} = "int";
    }
    
    # punctuation
    elsif($pos eq "Punc")
    {
        $f{pos} = "punc";
    }


    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        # subordinating conjunctions
        $f{subpos} = 'sub' if $feature eq 'When';
        $f{subpos} = 'sub' if $feature eq 'AfterDoingSo';
        $f{subpos} = 'sub' if $feature eq 'SinceDoingSo';
        $f{subpos} = 'sub' if $feature eq 'As';
        $f{subpos} = 'sub' if $feature eq 'ByDoingSo';
        $f{subpos} = 'sub' if $feature eq 'While';
        $f{subpos} = 'sub' if $feature eq 'AsIf';
        $f{subpos} = 'sub' if $feature eq 'WithoutHavingDoneSo';
        $f{subpos} = 'sub' if $feature eq 'Since';        
        
        # gender
        $f{gender} = "masc" if $feature eq "Ma";
        $f{gender} = "fem" if $feature eq "Fe";
        $f{gender} = "neut" if $feature eq "Ne";
        
        # person
        $f{person} = "1" if ($feature =~ /^[AP]1(sg|pl)$/);
        $f{person} = "2" if ($feature =~ /^[AP]2(sg|pl)$/);
        $f{person} = "3" if ($feature =~ /^[AP]3(sg|pl)$/);
        
        # number 
        $f{number} = "sing" if ($feature =~ /^[AP](1|2|3)sg$/);
        $f{number} = "plu" if ($feature =~ /^[AP](1|2|3)pl$/);
        
        # case features
        $f{case} = "nom" if $feature eq "Nom";
        $f{case} = "gen" if $feature eq "Gen";
        $f{case} = "acc" if $feature eq "Acc";
        $f{case} = "abl" if $feature eq "Abl";
        $f{case} = "dat" if $feature eq "Dat";
        $f{case} = "loc" if $feature eq "Loc";
        $f{case} = "ins" if $feature eq "Ins";        
        
        $f{degree} = "comp" if $feature eq "Cp";                        
        $f{degree} = "sup" if $feature eq "Su";
        
        # auxiliary & verb features
        $f{subpos} = "aux" if $feature eq "Caus";
        $f{subpos} = "aux" if $feature eq "Able";
        $f{subpos} = "aux" if $feature eq "Repeat";
        $f{subpos} = "aux" if $feature eq "Start";
        $f{subpos} = "aux" if $feature eq "Hastily";
        $f{subpos} = "aux" if $feature eq "Stay";
        $f{subpos} = "aux" if $feature eq "EverSince";
        $f{subpos} = "aux" if $feature eq "Almost";
        
        # desire / wish
        $f{subpos} = "aux" if $feature eq "Desr";
        $f{subpos} = "aux" if $feature eq "Neces";
        $f{subpos} = "aux" if $feature eq "Prog1";
        $f{subpos} = "aux" if $feature eq "Prog2";
        $f{subpos} = "aux" if $feature eq "Opt";                
        
        $f{mood} = "cnd" if $feature eq "Cond";
        $f{mood} = "imp" if $feature eq "Imp";                
        $f{tense} = "past" if $feature eq "Past";
        $f{tense} = "past" if $feature eq "Narr";
        $f{subtense} = "aor" if $feature eq "Aor";
        $f{tense} = "pres" if $feature eq "Pres";
        $f{tense} = "fut" if $feature eq "Fut";        
        
        # negativeness
        $f{negativeness} = "pos" if $feature eq "Pos";;
        $f{negativeness} = "neg" if $feature eq "Neg";;        
        
        # voice
        $f{voice} = "pass" if $feature eq "Pass";            

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
