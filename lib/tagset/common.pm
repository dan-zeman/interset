#!/usr/bin/perl
# Module with service functions for tagset drivers.
# (c) 2007 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::common;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



BEGIN
{
    # Complete the table of default replacement feature values.
    create_back_off();
}



#------------------------------------------------------------------------------
# Makes sure that all features have single values (as opposed to arrays).
# Should be called in the beginning of encode() of a driver that does not want
# to deal with multiple values. Whenever there is an array of values, this
# function will replace it by the first value from the array.
#------------------------------------------------------------------------------
sub single_values
{
    my $f = shift;
    # List of features that are allowed to keep multiple values.
    my @exceptions = @_;
    # Make a copy of the hash. Do not change the original, as the caller may need it later.
    my %copy;
    foreach my $key (keys(%{$f}))
    {
        my $reftype = ref($f->{$key});
        if($reftype eq "ARRAY")
        {
            if(grep{$_ eq $key}(@exceptions))
            {
                my @array_copy = @{$f->{$key}};
                $copy{$key} = \@array_copy;
            }
            else
            {
                $copy{$key} = $f->{$key}[0];
            }
        }
        elsif($reftype eq "")
        {
            $copy{$key} = $f->{$key};
        }
    }
    return \%copy;
}



#------------------------------------------------------------------------------
# Default orderings of feature values.
# $valord{$feature}[$first][$second]
# 1. Find the 2D array according to feature name.
# 2. Find the value to be replaced in the first dimension.
# 3. Try to find replacement in the second dimension (respect ordering).
# 4. If unsuccessful and the second dimension has more than one member, try to replace the last member (go back to step 2). Check loops!
# 5. In case of a loop go to next step and act as if there was only one member.
# 6. If unsuccessful and the second dimension has only one member (the value to replace), check empty value as replacement.
# 7. If unsuccessful, try to find replacement in the first dimension (respect ordering).
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# The order of the features specifies their priority. Features earlier in the
# list have higher priority. If there is a conflict of feature values during
# strict encoding, the feature with higher priority will retain its value.
#------------------------------------------------------------------------------
@features = ("pos", "subpos", "synpos", "poss", "reflex", "negativeness", "definiteness", "subjobj",
             "gender", "animateness", "number", "case", "compdeg",
             "person", "politeness", "possgender", "possnumber",
             "tense", "voice", "mood", "verbform", "aspect", "subtense",
             "foreign", "hyph", "style", "variant", "tagset", "other");
@values =
(
    "pos"          => ["noun", "adj", "det", "pron", "num", "verb", "adv", "prep", "inf", "conj", "part", "int", "punc"],
    "subpos"       => ["prop", "pdt", "pers", "clit", "recip", "digit", "roman", "card", "ord", "mult", "frac",
                       "aux", "mod", "intr", "tran", "verbconj", "man", "loc", "tim", "deg", "cau", "ex", "voc",
                       "preppron", "comprep", "coor", "sub", "emp", "sent"],
    "synpos"       => ["subst", "attr", "adv"],
    "poss"         => ["poss"],
    "reflex"       => ["reflex"],
    "negativeness" => ["pos", "neg"],
    "definiteness" => ["col", "ind", "def", "red", "wh", "int", "rel"],
    "subjobj"      => ["subj", "obj"],
    "foreign"      => ["foreign"],
    "gender"       => ["masc", "fem", "com", "neut"],
    "possgender"   => ["masc", "fem", "com", "neut"],
    "animateness"  => ["anim", "inan"],
    "number"       => ["sing", "dual", "plu"],
    "possnumber"   => ["sing", "dual", "plu"],
    "case"         => ["nom", "gen", "dat", "acc", "voc", "loc", "ins"],
    "compdeg"      => ["norm", "comp", "sup", "abs"],
    "person"       => ["1", "2", "3"],
    "politeness"   => ["inf", "pol"],
    "verbform"     => ["fin", "inf", "sup", "part", "trans", "ger"],
    "mood"         => ["ind", "imp", "sub", "jus"],
    "tense"        => ["past", "pres", "fut"],
    "subtense"     => ["aor", "imp"],
    "aspect"       => ["imp", "perf"],
    "voice"        => ["act", "pass"],
    "abbr"         => ["abbr"],
    "hyph"         => ["hyph"],
    "style"        => ["arch", "form", "norm", "coll"],
    "variant"      => ["short", "long", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    "tagset"       => [],
    "other"        => []
);
%defaults =
(
    "pos" =>
    [
        ["part"        ],
        ["noun", "verb"],
        ["verb"        ],
        ["punc"        ],
        ["pron", "noun"],
        ["adj",  "noun"],
        ["det",  "adj" ],
        ["num",  "adj" ],
        ["adv"         ],
        ["prep", "adv" ],
        ["conj", "prep"],
        ["inf",  "part"],
        ["int"         ]
    ],
    # No general back-off system can be defined for subpos because there are subpos values for various pos values.
    # From the back-off point of view, it might be more advantageous to drop the subpos feature completely and merge it with pos.
    # On the other hand, we do not want to have both pos=adv and pos=advloc.
    # It would violate the rule that no information (here, the information "this is adverb") can be encoded in more than one way.
    # Another possible solution is to split the subpos feature into multiple, pos-specific features.
    "subpos" =>
    [
        ["prop"],
        ["pdt"],
        ["pers"],
        ["clit"],
        ["recip"],
        ["digit", "card"],
        ["roman", "digit"],
        ["card", "", "ord"],
        ["ord", "", "card"],
        ["mult", "card"],
        ["frac", "card"],
        ["aux"],
        ["mod", "aux"],
        ["intr"],
        ["tran"],
        ["verbconj"],
        ["man"],
        ["loc"],
        ["tim"],
        ["deg"],
        ["cau"],
        ["ex"],
        ["voc"],
        ["preppron"],
        ["comprep"],
        ["coor"],
        ["sub"],
        ["emp"],
        ["sent"]
    ],
    "synpos" =>
    [
        ["subst"],
        ["attr"],
        ["adv"]
    ],
    "poss" =>
    [
        ["poss"]
    ],
    "reflex" =>
    [
        ["reflex"]
    ],
    "negativeness" =>
    [
        ["pos"],
        ["neg"]
    ],
    "definiteness" =>
    [
        ["ind"],
        ["def"],
        ["wh",  "int", "rel"],
        ["int", "wh",  "rel"],
        ["rel", "wh",  "int"],
        ["col"],
        ["red"]
    ],
    "subjobj" =>
    [
        ["subj"],
        ["obj"]
    ],
    "foreign" =>
    [
        ["foreign"]
    ],
    "gender" =>
    [
        ["com"],
        ["neut"],
        ["masc"],
        ["fem"]
    ],
    "possgender" =>
    [
        ["com"],
        ["neut"],
        ["masc"],
        ["fem"]
    ],
    "animateness" =>
    [
        ["anim"],
        ["inan"]
    ],
    "number" =>
    [
        ["sing"],
        ["dual", "plu"],
        ["plu"]
    ],
    "possnumber" =>
    [
        ["sing"],
        ["dual", "plu"],
        ["plu"]
    ],
    "case" =>
    [
        ["nom"],
        ["acc"],
        ["dat"],
        ["gen"],
        ["loc"],
        ["ins"],
        ["voc"]
    ],
    "compdeg" =>
    [
        ["norm"],
        ["comp"],
        ["sup"],
        ["abs"]
    ],
    "person" =>
    [
        ["3"],
        ["1"],
        ["2"]
    ],
    "politeness" =>
    [
        ["inf"],
        ["pol"]
    ],
    "verbform" =>
    [
        ["inf"],
        ["fin"],
        ["part"],
        ["sup"],
        ["trans"],
        ["ger"]
    ],
    "mood" =>
    [
        ["ind"],
        ["imp"],
        ["sub", "jus"],
        ["jus", "sub"]
    ],
    "tense" =>
    [
        ["pres"],
        ["fut"],
        ["past"]
    ],
    "subtense" =>
    [
        ["aor"],
        ["imp"]
    ],
    "aspect" =>
    [
        ["imp"],
        ["perf"]
    ],
    "voice" =>
    [
        ["act"],
        ["pass"]
    ],
    "abbr" =>
    [
        ["abbr"]
    ],
    "hyph" =>
    [
        ["hyph"]
    ],
    "style" =>
    [
        ["norm"],
        ["form"],
        ["arch"],
        ["coll"]
    ],
    "variant" =>
    [
        ["0"],
        ["1"],
        ["2"],
        ["3"],
        ["4"],
        ["5"],
        ["6"],
        ["7"],
        ["8"],
        ["9"],
        ["short"],
        ["long"]
    ]
);



#------------------------------------------------------------------------------
# For each feature value, constructs the complete list of back-off replacements
# Reads and writes to global variables.
#------------------------------------------------------------------------------
sub create_back_off
{
    # Loop over features.
    foreach my $feature (keys(%defaults))
    {
        # For each feature, there is an array of arrays.
        # The first member of each second-order array is the value to replace.
        # The rest (if any) are the preferred replacements for this particular value.
        # First of all, collect preferred replacements for all values of this feature.
        my %map;
        foreach my $valarray (@{$defaults{$feature}})
        {
            my $value = $valarray->[0];
            $map{$value}{$value}++;
            my @backoff;
            # Add all preferred replacements (if any) to the list.
            for(my $i = 1; $i<=$#{$valarray}; $i++)
            {
                push(@backoff, $valarray->[$i]);
                # Remember all values that have been added as replacements of $value.
                $map{$value}{$valarray->[$i]}++;
            }
            $defaults1{$feature}{$value} = \@backoff;
        }
        # If a value had preferred replacements, add replacements of the last preferred replacement. Check loops!
        # Loop over values again.
        foreach my $value (keys(%{$defaults1{$feature}}))
        {
            # Remember all visited values to prevent loops!
            my %visited;
            $visited{$value}++;
            # Find the last preferred replacement, if any.
            my $last;
            for(;;)
            {
                my $new_last;
                if(scalar(@{$defaults1{$feature}{$value}}))
                {
                    $last = $defaults1{$feature}{$value}[$#{$defaults1{$feature}{$value}}];
                }
                # Unless the last preferred replacement has been visited, try to find its replacements.
                if($last)
                {
                    unless($visited{$last})
                    {
                        $visited{$last}++;
                        my @replacements_of_last = @{$defaults1{$feature}{$last}};
                        # If $last has replacements that $value does not have, add them to $value.
                        foreach my $replacement (@replacements_of_last)
                        {
                            unless($map{$value}{$replacement})
                            {
                                push(@{$defaults1{$feature}{$value}}, $replacement);
                                $map{$value}{$replacement}++;
                                $new_last++;
                            }
                        }
                    }
                }
                # If no $last has been found or if it has been visited, break the loop.
                last unless($new_last);
            }
            # The empty value and all other unvisited values are the next replacements to consider.
            foreach my $valarray ("", @{$defaults{$feature}})
            {
                my $replacement = $valarray->[0];
                unless($map{$value}{$replacement})
                {
                    push(@{$defaults1{$feature}{$value}}, $replacement);
                    $map{$value}{$replacement}++;
                }
            }
            # Debugging: print the complete list of replacements.
#            print("$feature: $value:\t", join(", ", @{$defaults1{$feature}{$value}}), "\n");
        }
    }
}



#------------------------------------------------------------------------------
# Reads a list of tags, decodes each tag and remembers occurrences of feature
# values. Builds a list of permitted feature values for this tagset.
#------------------------------------------------------------------------------
sub get_permitted_values
{
    my $list = shift;
    my $decode = shift; # reference to the driver-specific decode function
    # Hash over features. For each feature there is a hash over values.
    # If $permitvals{$feature}{$value} != 0 then $value is permitted.
    my %permitvals;
    # Make sure that the list of possible tags is not empty.
    # If it is, probably the driver's list() function is not implemented.
    unless(scalar(@{$list}))
    {
        die("Cannot figure out the permitted values because the list of possible tags is empty.\n");
    }
    foreach my $tag (@{$list})
    {
        my $features = &{$decode}($tag);
        foreach my $feature (keys(%{$features}))
        {
            # If this is an array, all member values are permitted.
            if(ref($features{$feature}) eq "ARRAY")
            {
                foreach my $value (@{$features{$feature}})
                {
                    $permitvals{$feature}{$value}++;
                }
            }
            # If this is a single value, it is permitted.
            else
            {
                $permitvals{$feature}{$features{$feature}}++;
            }
        }
    }
    return \%permitvals;
}



#------------------------------------------------------------------------------
# Checks a feature value against the list of permitted values. If the value is
# not permitted, suggests a replacement.
#------------------------------------------------------------------------------
sub check_value
{
    my $feature = shift;
    my $value = shift;
    my $permitvals = shift;
    my $replacement = $value;
    # If the value is an empty array, make it an empty value.
    if(ref($replacement) eq "ARRAY" && scalar(@{$replacement})==0)
    {
        $replacement = "";
    }
    # If the value is an array, remove disallowed values from it.
    if(ref($replacement) eq "ARRAY")
    {
        # Make a copy of the array so we can remove elements.
        my @copy = @{$replacement};
        for(my $i = 0; $i<=$#copy; $i++)
        {
            unless($permitvals->{$feature}{$copy[$i]})
            {
                splice(@copy, $i, 1);
                $i--;
            }
        }
        # If the pruned array is empty, take the first element of the original array.
        if(scalar(@copy)==0)
        {
            $replacement = $value->[0];
        }
        else
        {
            $replacement = \@copy;
        }
    }
    # If the value is a scalar, check whether the value is permitted.
    if(ref($replacement) eq "" && !$permitvals->{$feature}{$replacement})
    {
        my $found = 0;
        foreach my $r (@{$defaults1{$feature}{$replacement}})
        {
            if($permitvals->{$feature}{$r})
            {
                $found = 1;
                $replacement = $r;
                last;
            }
        }
        unless($found)
        {
            print STDERR ("feature      = $feature\n");
            print STDERR ("value        = $replacement\n");
            print STDERR ("replacements = ", join(", ", @{$defaults1{$feature}{$replacement}}), "\n");
            die("Incomplete list of permitted replacement values!\n");
        }
    }
    return $replacement;
}



#------------------------------------------------------------------------------
# Check values of all features against the list of permitted values. Any
# unpermitted value is replaced by the replacement suggested by check_value().
#------------------------------------------------------------------------------
sub enforce_permitted_values
{
    my $fs = shift; # ref to hash with feature structure
    my $permitvals = shift;
    foreach my $feature (keys(%{$fs}))
    {
        $fs->{$feature} = check_value($feature, $fs->{$feature}, $permitvals);
    }
    return $fs;
}



1;
