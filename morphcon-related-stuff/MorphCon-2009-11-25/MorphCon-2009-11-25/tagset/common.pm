#!/usr/bin/perl
# Module with service functions for tagset drivers.
# (c) 2007-2008 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::common;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Carp; # confess()



#------------------------------------------------------------------------------
# List of known features and values in display order.
#------------------------------------------------------------------------------
BEGIN
{
    @known_features =
    (
        "pos", "subpos", "prontype", "numform", "punctype", "puncside", "synpos", "poss", "reflex", "negativeness", "definiteness",
        "gender", "animateness", "number", "case", "prepcase", "degree",
        "person", "politeness", "possgender", "possnumber",
        "subcat", "verbform", "mood", "tense", "subtense", "voice", "aspect",
        "foreign", "abbr", "hyph", "style", "typo", "variant",
        "tagset", "other"
    );
    %known_values =
    (
        "pos"          => ["noun", "adj", "num", "verb", "adv", "prep", "conj", "part", "int", "punc"],
        "subpos"       => ["prop", "class", "pdt", "det", "art", "pers", "clit", "recip", "card", "ord", "mult", "frac",
                           "aux", "cop", "mod", "verbconj", "man", "loc", "tim", "deg", "cau", "mod", "ex", "voc", "post", "circ", "preppron", "comprep",
                           "coor", "sub", "comp", "emp", "res", "inf", "vbp"],
        "prontype"     => ["prs", "rcp", "int", "rel", "dem", "neg", "ind", "tot"],
        "numform"      => ["word", "digit", "roman"],
        "punctype"     => ["peri", "qest", "excl", "quot", "brck", "comm", "colo", "semi", "dash", "symb", "root"],
        "puncside"     => ["ini", "fin"],
        "synpos"       => ["subst", "attr", "adv", "pred"],
        "poss"         => ["poss"],
        "reflex"       => ["reflex"],
        "negativeness" => ["pos", "neg"],
        "definiteness" => ["ind", "def", "red"],
        "gender"       => ["masc", "fem", "com", "neut"],
        "animateness"  => ["anim", "inan"],
        "number"       => ["sing", "dual", "plu"],
        "case"         => ["nom", "gen", "dat", "acc", "voc", "loc", "ins"],
        "prepcase"     => ["npr", "pre"],
        "degree"       => ["pos", "comp", "sup", "abs"],
        "person"       => [1, 2, 3],
        "politeness"   => ["inf", "pol"],
        "possgender"   => ["masc", "fem", "com", "neut"],
        "possnumber"   => ["sing", "dual", "plu"],
        "subcat"       => ["intr", "tran"],
        "verbform"     => ["fin", "inf", "sup", "part", "trans", "ger"],
        "mood"         => ["ind", "imp", "cnd", "sub", "jus"],
        "tense"        => ["past", "pres", "fut"],
        "subtense"     => ["aor", "imp", "ppq"],
        "aspect"       => ["imp", "perf"],
        "voice"        => ["act", "pass"],
        "foreign"      => ["foreign"],
        "abbr"         => ["abbr"],
        "hyph"         => ["hyph"],
        "style"        => ["arch", "form", "norm", "coll"],
        "typo"         => ["typo"],
        "variant"      => ["short", "long", 0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "tagset"       => [""],
        "other"        => [""],
    );
    # Create a map of known feature-value pairs to make checking easier.
    %known;
    foreach my $f (@known_features)
    {
        if(!exists($known_values{$f}))
        {
            die("Missing list of known values for the feature \"$f\".\n");
        }
        foreach my $v (@{$known_values{$f}})
        {
            $known{$f}{$v} = 1;
        }
    }
}



#------------------------------------------------------------------------------
# This other list of features specifies their priority. Features earlier in the
# list have higher priority. If there is a conflict of feature values during
# strict encoding, the feature with higher priority will retain its value.
#------------------------------------------------------------------------------
BEGIN
{
    # General rule: features that specify which other features are relevant
    # should get high priority. If they didn't, we could end up with a tag for
    # abbreviation just because the source tag lacked some mophological
    # features.
    @features =
    (
        "pos", "abbr", "hyph", "subcat", "verbform", "mood", "prontype", "numform", "punctype", "puncside", "subpos", "synpos",
        "poss", "reflex", "degree", "negativeness", "definiteness",
        "person", "tense", "voice", "aspect", "subtense",
        "gender", "animateness", "number", "case", "prepcase",
        "politeness", "possgender", "possnumber",
        "foreign", "style", "typo", "variant", "tagset", "other"
    );
    # Security check: all known features should be on the priority list, and
    # all features on the priority list should be known.
    my %map;
    foreach my $f (@features)
    {
        if(!exists($known_values{$f}))
        {
            die("Unknown feature \"$f\" on the priority list.\n");
        }
        if($map{$f})
        {
            die("Feature \"$f\" appears more than once in the priority list.\n");
        }
        $map{$f}++;
    }
    foreach my $f (keys(%known_values))
    {
        if(!$map{$f})
        {
            die("Feature \"$f\" is missing from the priority list.\n");
        }
    }
}



#------------------------------------------------------------------------------
# For each feature value, constructs the complete list of back-off replacements
# Reads and writes to global variables.
#------------------------------------------------------------------------------
BEGIN
{
    # What follows is an attempt to describe the system of value replacements
    # in an easily readable and maintainable way. The algorithm to process it
    # may be complicated but the human interpretation should (hopefully) be simple.

    # Rule 1: Values of each feature are ordered. This is the order of priority
    #         when searching for replacement of an empty value.
    # Rule 2: A non-empty value is replaced by empty value in the first place.
    #         If the empty value is not permitted, it is replaced according to
    #         Rule 1.
    # Rule 3: Some values of some features have customized replacement sequences.
    #         They contain replacements that are used prior to the default empty value.
    #         For instance, if we have pos=det (determiner), we want to try
    #         pos=adj (adjective) first, and only if this value is not permitted,
    #         we default to the empty value.
    #         Customized replacement sequences, if present, are specified
    #         immediately next to the value being replaced (in one array).
    #         The last element is a link: if we pass this value, we proceed to
    #         its own customized replacement sequence. If the value does not
    #         have a customized replacement sequence or if the link constitutes
    #         a loop, proceed as if replacing an empty value according to Rule 1.

    # The empty value does not need to be specified in the main (top-down) list
    # of values of a feature. However, should a customized replacement sequence
    # (left-to-right list) contain an empty value, it must explicitely state it.

    # The algorithm:
    # $valord{$feature}[$first][$second]
    # 1. Find the 2D array according to feature name.
    # 2. Find the value to be replaced in the first dimension.
    # 3. Try to find replacement in the second dimension (respect ordering).
    # 4. If unsuccessful and the second dimension has more than one member, try to replace the last member (go back to step 2). Check loops!
    # 5. In case of a loop go to next step and act as if there was only one member.
    # 6. If unsuccessful and the second dimension has only one member (the value to replace), check empty value as replacement.
    # 7. If unsuccessful, try to find replacement in the first dimension (respect ordering).

    my %defaults =
    (
        "pos" =>
        [
            ["part"        ],
            ["noun", "verb"],
            ["verb"        ],
            ["punc"        ],
            ["adj",  "noun"],
            ["num",  "adj" ],
            ["adv"         ],
            ["prep", "adv" ],
            ["conj", "prep"],
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
            ["det"],
            ["art", "det"],
            ["pers"],
            ["clit"],
            ["recip"],
            ["card", "", "ord"],
            ["ord", "", "card"],
            ["mult", "card"],
            ["frac", "card"],
            ["aux"],
            ["cop", "aux"],
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
            ["post"],
            ["circ"],
            ["preppron"],
            ["comprep"],
            ["coor"],
            ["sub"],
            ["comp"],
            ["emp"],
            ["res"],
            ["inf"],
            ["vbp"]
        ],
        "numform" =>
        [
            ["word"],
            ["digit", "roman"],
            ["roman", "digit"]
        ],
        "punctype" =>
        [
            ["colo"],
            ["comm", "colo"],
            ["peri", "colo"],
            ["qest", "peri"],
            ["excl", "peri"],
            ["quot", "brck"],
            ["brck", "quot"],
            ["semi", "comm"],
            ["dash", "colo"],
            ["symb"],
            ["root"]
        ],
        "puncside" =>
        [
            ["ini"],
            ["fin"]
        ],
        "synpos" =>
        [
            ["subst"],
            ["attr"],
            ["adv"],
            ["pred"]
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
            ["red", "def"]
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
        "prepcase" =>
        [
            ["npr"],
            ["pre"]
        ],
        "degree" =>
        [
            ["pos"],
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
            ["cnd", "sub"],
            ["sub", "cnd", "jus"],
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
            ["imp"],
            ["ppq"]
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
        "typo" =>
        [
            ["typo"]
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
    # Loop over features.
    my @keys = keys(%defaults);
    foreach my $feature (@keys)
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
        # The primary list of values constitutes the sequence of replacements for the empty value.
        foreach my $valarray (@{$defaults{$feature}})
        {
            my $replacement = $valarray->[0];
            unless($map{""}{$replacement} || $replacement eq "")
            {
                push(@{$defaults1{$feature}{""}}, $replacement);
                $map{""}{$replacement}++;
            }
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
                            unless($map{$value}{$replacement} || $replacement eq $value)
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
                unless($map{$value}{$replacement} || $replacement eq $value)
                {
                    push(@{$defaults1{$feature}{$value}}, $replacement);
                    $map{$value}{$replacement}++;
                }
            }
            # Debugging: print the complete list of replacements.
#            print STDERR ("$feature: $value:\t", join(", ", @{$defaults1{$feature}{$value}}), "\n");
        }
    }
}



###############################################################################
# COLLECTING PERMITTED FEATURE VALUES OF A TAGSET
###############################################################################



#------------------------------------------------------------------------------
# Reads a list of tags, decodes each tag, converts all array values to scalars
# (by sorting and joining them), remembers permitted feature structures in a
# trie. Returns a reference to the trie.
#------------------------------------------------------------------------------
sub get_permitted_structures_joint
{
    my $list = shift; # reference to array
    my $decode = shift; # reference to driver-specific decoding function
    my %trie;
    # Make sure that the list of possible tags is not empty.
    # If it is, the driver's list() function is probably not implemented.
    unless(scalar(@{$list}))
    {
        die("Cannot figure out the permitted values because the list of possible tags is empty.\n");
    }
    foreach my $tag (@{$list})
    {
        my $fs = &{$decode}($tag);
        # Loop over known features (in the order of feature priority).
        my $pointer = \%trie;
        foreach my $f (@features)
        {
            # Make sure the value is not an array.
            my $v = array_to_scalar_value($fs->{$f});
            $pointer = add_value_to_trie($f, $v, $pointer, $tag);
        }
    }
    return \%trie;
}



#------------------------------------------------------------------------------
# Reads a list of tags, decodes each tag and remembers occurrences of feature
# values. Builds a list of permitted feature values for this tagset.
#------------------------------------------------------------------------------
sub get_permitted_values
{
    my $list = shift;
    my $decode = shift; # reference to the driver-specific decode function
    my $permitted_values = shift; # hash reference
    my $permitted_combinations = shift; # hash (trie root) reference
    # Make sure that the list of possible tags is not empty.
    # If it is, probably the driver's list() function is not implemented.
    unless(scalar(@{$list}))
    {
        die("Cannot figure out the permitted values because the list of possible tags is empty.\n");
    }
    foreach my $tag (@{$list})
    {
        my $fs = &{$decode}($tag);
        permit_feature_value_recursion($fs, 0, $permitted_values, $permitted_combinations, $tag);
    }
}



#------------------------------------------------------------------------------
# Remembers the value(s) of the first feature as permitted and recursively
# calls itself for subsequent values. The recursion is needed for the case that
# one feature has an array of values.
# In that case, values of subsequent features must be recorded in combination
# with each value from the array. The function uses the global list of feature
# names, @features.
# Hash of permitted values: $hash{$feature}{$value} exists, is non-empty and
# non-zero iff the given feature-value pair exists for a tag in the tag set.
# Trie of permitted value combinations: $trie{$value0}{$value1}...{$value_n}
# exists, is non-empty and non-zero iff for a tag in the tag set the feature
# no. 0 (first in the @features global array) has $value0, the feature no. 1
# has $value1 etc. This function does not expect the reference to the root of
# the trie. Instead, it expects the reference to the hash under the value
# previously set.
#------------------------------------------------------------------------------
sub permit_feature_value_recursion
{
    my $fs = shift; # feature structure (hash reference)
    my $i = shift; # index of feature (in @features) to process
    my $permitvals = shift; # hash reference
    my $permitcombs = shift; # pointer into trie (hash reference)
    my $tag_example = shift;
    # Check the upper bound on the feature index.
    return if($i>$#features);
    # If this is an array, all member values are permitted.
    my $feature = $features[$i];
    my @values;
    if(ref($fs->{$feature}) eq "ARRAY")
    {
        @values = @{$fs->{$feature}};
    }
    else
    {
        @values = ($fs->{$feature});
    }
    foreach my $value (@values)
    {
        $permitvals->{$feature}{$value}++;
        # Recursively call itself for the next feature.
        if($i<$#features)
        {
            unless(ref($permitcombs->{$value}) eq "HASH")
            {
                my %next_level_empty_hash;
                $permitcombs->{$value} = \%next_level_empty_hash;
            }
            permit_feature_value_recursion($fs, $i+1, $permitvals, $permitcombs->{$value}, $tag_example);
        }
        else
        {
            if($tag_example ne "" && $permitcombs->{$value} eq "")
            {
                $permitcombs->{$value} = $tag_example;
            }
            else
            {
                $permitcombs->{$value}++;
            }
        }
    }
}



###############################################################################
# ENFORCING PERMITTED (EXPECTED) VALUES IN FEATURE STRUCTURES
###############################################################################



#------------------------------------------------------------------------------
# Compares two arrays of values. Prefers precision over recall. Accepts that
# value X can serve as replacement of value Y, and counts it as 1/N occurrences
# of Y. Replacements are retrieved from the global hash %defaults1.
#------------------------------------------------------------------------------
sub get_similarity_of_arrays
{
    my $feature = shift; # feature name needed to find default values
    my $srch = shift; # array reference
    my $eval = shift; # array reference
    # For each scalar searched, get replacement array (beginning with the scalar itself).
    my @menu; # 2-dimensional matrix
    for(my $i = 0; $i<=$#{$srch}; $i++)
    {
        push(@{$menu[$i]}, $srch->[$i]);
        push(@{$menu[$i]}, @{$defaults1{$feature}{$srch->[$i]}});
    }
    # Look for menu values in array being evaluated. If not found, look for replacements.
    my @found; # srch values matched to something in eval
    my @used; # eval values identified as something searched for
    my $n_found = 0; # how many srch values have been found
    my $n_used = 0; # how many eval values have been used
    my $n_srch = scalar(@{$srch});
    my $n_eval = scalar(@{$eval});
    my $score = 0; # number of hits, weighed (replacement is not a full hit, original value is)
    if(@menu)
    {
        # Loop over levels of replacement.
        for(my $i = 0; $i<=$#{$menu[0]} && $n_found<$n_srch && $n_used<$n_eval; $i++)
        {
            # Loop over searched values.
            for(my $j = 0; $j<=$#menu && $n_found<$n_srch && $n_used<$n_eval; $j++)
            {
                next if($found[$j]);
                # Look for i-th replacement of j-th value in the evaluated array.
                for(my $k = 0; $k<=$#{$eval}; $k++)
                {
                    if(!$used[$k] && $eval->[$k] eq $menu[$j][$i])
                    {
                        $found[$j]++;
                        $used[$k]++;
                        $n_found++;
                        $n_used++;
                        # Add reward for this level of replacement.
                        # (What fraction of an occurrence are we going to count for this?)
                        $score += 1/($i+1);
                        last;
                    }
                }
            }
        }
    }
    # Use the score to compute precision and recall.
    my $p = $score/$n_srch if($n_srch);
    my $r = $score/$n_eval if($n_eval);
    # Prefer precision over recall.
    my $result = (2*$p+$r)/3;
    return $result;
}



#------------------------------------------------------------------------------
# Selects the most suitable replacement. Can deal with arrays of values.
#------------------------------------------------------------------------------
sub select_replacement
{
    my $feature = shift; # feature name needed to get default replacements of a value
    my $value = shift; # scalar or array reference
    my $permitted = shift; # hash reference; keys are permitted values; array values joint
    # The "tagset" and "other" features are special. All values are permitted.
    if($feature =~ m/^(tagset|other)$/)
    {
        return $value;
    }
    # If value is not an array, make it an array.
    my @values = ref($value) eq "ARRAY" ? @{$value} : ($value);
    # Convert every permitted value to an array as well.
    my @permitted = keys(%{$permitted});
    if(!scalar(@permitted))
    {
        print STDERR ("Feature = $feature\n");
        print STDERR ("Value to replace = ", array_to_scalar_value($value), "\n");
        confess("Cannot select a replacement if no values are permitted.\n");
    }
    my %suitability;
    foreach my $p (@permitted)
    {
        # Warning: split converts empty values to empty array but we want array with one empty element.
        my @pvalues = split(/\|/, $p);
        $pvalues[0] = "" unless(@pvalues);
        # Get suitability evaluation for $p.
        $suitability{$p} = get_similarity_of_arrays($feature, \@values, \@pvalues);
    }
    # Return the most suitable permitted value.
    @permitted = sort {$suitability{$b} <=> $suitability{$a}} (@permitted);
    # If the replacement is an array, return a reference to it.
    my @repl = split(/\|/, $permitted[0]);
    if(scalar(@repl)==0)
    {
        return "";
    }
    elsif(scalar(@repl)==1)
    {
        return $repl[0];
    }
    else
    {
        return \@repl;
    }
}



#------------------------------------------------------------------------------
# Selects the most suitable replacement. Can deal with arrays of values.
#------------------------------------------------------------------------------
sub select_replacement_0
{
    my $feature = shift; # feature name needed to get default replacements of a value
    my $value = shift; # scalar or array reference
    my $permitted = shift; # hash reference; keys are permitted values; array values joint
    # The "tagset" and "other" features are special. All values are permitted.
    if($feature =~ m/^(tagset|other)$/)
    {
        return $value;
    }
    my @permitted = keys(%{$permitted});
    if(!scalar(@permitted))
    {
        print STDERR ("Feature = $feature\n");
        print STDERR ("Value to replace = ", array_to_scalar_value($value), "\n");
        confess("Cannot select a replacement if no values are permitted.\n");
    }
    # Evaluate suitability of each permitted value as a replacement of the original value.
    # The most suitable replacement is the original value itself, if permitted.
    # If both the original and the replacement are single values, the suitability
    # decreases with the position of the replacement in the list of defaults for the original.
    # The suitability of arrays is derived from the suitability of their elements.
    # Note that suitability is not a symmetric relation!
    my %suitability;
    # We want to know for each single value, which permitted values contain it.
    # Create an index that will tell us. The index is a hash, its keys are
    # single values that have occurred in one or more permitted values. The
    # values of the index are arrays of permitted values in which the key
    # single value has occurred.
    my %index;
    # Also record the number of elements of each permitted value.
    # We are going to need it in suitability computations.
    my %n_members;
    foreach my $p (@permitted)
    {
        # Warning: split converts empty values to empty array but we want array with one empty element.
        my @pvalues = split(/\|/, $p);
        $pvalues[0] = "" unless(@pvalues);
        foreach my $v (@pvalues)
        {
            push(@{$index{$v}}, $p);
        }
        $n_members{$p} = scalar(@pvalues);
    }
    # If the original value is not an array, make one of it.
    my @orig = ref($value) eq "ARRAY" ? @{$value} : ($value);
    foreach my $o (@orig)
    {
        # Loop over the default replacements. The further in the list, the less suitable.
        my @replacements = ($o, @{$defaults1{$feature}{$o}});
        for(my $i = 0; $i<=$#replacements; $i++)
        {
            my $r = $replacements[$i];
            my $score = 1/($i+1);
            # Add the score to all permitted values containing $o.
            foreach my $p (@{$index{$r}})
            {
                $suitability{$p} += $score;
            }
        }
    }
    # Normalize the suitability of each permitted value according to its number of elements.
    foreach my $p (@permitted)
    {
        # Do not worry, it cannot happen that $n_members is zero.
        $suitability{$p} /= $n_members{$p};
    }
    # Return the most suitable permitted value.
    @permitted = sort {$suitability{$b} <=> $suitability{$a}} (@permitted);
    $debug = 1;
    if($debug)
    {
        print STDERR ("List of permitted values of feature $feature ordered by decreasing suitability\n");
        foreach my $p (@permitted)
        {
            printf STDERR ("  $p\t%f\n", $suitability{$p});
        }
    }
    # If the replacement is an array, return a reference to it.
    my @repl = split(/\|/, $permitted[0]);
    if(scalar(@repl)==0)
    {
        return "";
    }
    elsif(scalar(@repl)==1)
    {
        return $repl[0];
    }
    else
    {
        return \@repl;
    }
}



#------------------------------------------------------------------------------
# Makes sure that a feature structure complies with the permitted combinations
# recorded in a trie. Replaces feature values if needed.
#------------------------------------------------------------------------------
sub enforce_permitted_joint
{
    my $fs0 = shift;
    my $trie = shift;
    my $fs1 = duplicate($fs0);
    foreach my $f (@features)
    {
        unless(exists($trie->{$fs1->{$f}}))
        {
            $fs1->{$f} = select_replacement($f, $fs1->{$f}, $trie);
        }
        $trie = advance_trie_pointer($f, $fs1->{$f}, $trie);
    }
    return $fs1;
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
            unless($permitvals->{$copy[$i]})
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
    my $ref = ref($replacement);
    if(ref($replacement) eq "" && !$permitvals->{$replacement})
    {
        my $found = 0;
        foreach my $r (@{$defaults1{$feature}{$replacement}})
        {
            if($permitvals->{$r})
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
            confess("Incomplete list of permitted replacement values!\n");
        }
    }
    return $replacement;
}



#------------------------------------------------------------------------------
# Checks whether a value of a feature is permitted. If it is not, replaces it
# (directly in the caller's hash!) with a suitable default and marks that the
# original value has not survived. Used by enforce_permitted_combinations().
# The input/output hash:
#   feature ... feature name
#   value ... value of the feature (scalar or array reference)
#   pointer ... reference to a hash; permitted are those values that correspond to a key in the hash
#   original ... has at least one original value survived (to be filled here)
#------------------------------------------------------------------------------
sub check_value_record
{
    my $record = shift;
    my $feature = $record->{feature};
    # Features tagset and other can have any values.
    if($feature =~ m/^(tagset|other)$/)
    {
        $record->{original} = 1;
        return $record->{value};
    }
    # If there is an array of values, make a copy of the array.
    # If there is a single value, put it into an array.
    my @values;
    if(ref($record->{value}) eq "ARRAY")
    {
        @values = @{$record->{value}};
    }
    else
    {
        push(@values, $record->{value});
    }
    # Figure out what values are permitted.
    my @permitted = grep {exists($record->{pointer}{$_})} @values;
    # If at least one value survived, return the pruned list of values.
    if(@permitted)
    {
        $record->{original} = 1;
    }
    # If no original values survived, look for default replacements.
    else
    {
        my %map;
        foreach my $v (@values)
        {
            my $replacements = $defaults1{$feature}{$v};
            my $found = 0;
            my $replacement;
            foreach my $r (@{$replacements})
            {
                if(exists($record->{pointer}{$r}))
                {
                    $found = 1;
                    $replacement = $r;
                    last;
                }
            }
            if($found)
            {
                # Add this replacement to new values unless it has been put there earlier.
                unless($map{$replacement})
                {
                    push(@permitted, $replacement);
                    $map{$replacement}++;
                }
            }
            # There ought to be always at least one permitted value for every feature.
            # If we have not found a replacement, it means that something got wrong and no value is permitted.
            else
            {
                print STDERR ("feature      = \"$feature\"\n");
                print STDERR ("value        = \"$v\"\n");
                print STDERR ("replacements = ", join(", ", map {"\"$_\""} @{$defaults1{$feature}{$v}}), "\n");
                print STDERR ("permitted    = ", join(", ", map {"\"$_\""} keys(%{$record->{pointer}})), "\n");
                confess("Incomplete list of permitted replacement values!\n");
            }
        }
        $record->{original} = 0;
    }
    # Debugging.
    if(0)
    {
        print STDERR ("feature      = \"$record->{feature}\"\n");
        print STDERR ("values       = ", join(", ", map {"\"$_\""} @values), "\n");
        print STDERR ("permitted    = ", join(", ", map {"\"$_\""} keys(%{$record->{pointer}})), "\n");
        print STDERR ("selected     = ", join(", ", map {"\"$_\""} @permitted), "\n\n");
    }
    # If there is just one permitted value, make it a scalar.
    if(scalar(@permitted)>1)
    {
        $record->{value} = \@permitted;
    }
    elsif(scalar(@permitted)==1)
    {
        $record->{value} = $permitted[0];
    }
    else
    {
        confess("There should be at least one permitted value for feature $feature!\n");
    }
    return $record->{value};
}



#------------------------------------------------------------------------------
# Check values of all features against the list of permitted values. Any
# unpermitted value is replaced by the replacement suggested by check_value().
#------------------------------------------------------------------------------
sub enforce_permitted_values
{
    my $fs = shift; # ref to hash with feature structure
    my $permitvals = shift;
    my $debug = 1;
    # Loop through all known features, not only those set in the given structure.
    foreach my $feature (@features)
    {
        # The "tagset" and "other" features are special. Their values are always permitted.
        next if($feature =~ m/^(tagset|other)$/);
        my $value0 = $fs->{$feature};
        $fs->{$feature} = check_value($feature, $value0, $permitvals->{$feature});
        # Debugging:
        if($debug)
        {
            if($fs->{$feature} ne $value0)
            {
                print STDERR ("Replacing feature \"$feature\" value \"$value0\" by \"$fs->{$feature}\".\n");
            }
        }
    }
    return $fs;
}



#------------------------------------------------------------------------------
# Check values of all features against the trie of permitted feature
# structures, higher-priority features first. Any value prohibited (either by
# the values of higher-priority features, or by the tagset itself) is replaced
# by a value permitted in this context.
#------------------------------------------------------------------------------
sub enforce_permitted_combinations
{
    my $fs = shift; # ref to hash with feature structure
    my $trie = shift;
    my $debug = 1;
    # The pointer into the trie can branch to array of pointers if there is an array of permitted values.
    # A state is composed of the following:
    #   pointer ... pointer into the trie
    #   feature ... feature name corresponding to the pointer (hash keys are values of that feature)
    #   value ..... one or more (array ref) permitted values that can be used to advance the pointer
    #   original .. are the values original (1), or replacements (0)?
    my @states = ({"pointer" => $trie});
    # Loop through all known features.
    foreach my $feature (@features)
    {
        my $value = $fs->{$feature};
        # Use all current trie pointers. Try to advance each of them according to the value of the current feature.
        my $n_orig = 0;
        foreach my $state (@states)
        {
            $state->{feature} = $feature;
            $state->{value} = $value;
            # Check whether the value(s) is (are) permitted. Prune or replace them. Mark whether original value(s) survived.
            check_value_record($state);
            $n_orig += $state->{original};
        }
        # If more than one original values survived, fork this pointer.
        # If one of the original values survived, keep (and advance) this pointer.
        # If no original value survived (i.e., we got a replacement):
          # If there are other pointers where one or more original values survived, kill this pointer.
          # If there are no pointers where original values survived, keep all pointers with replacements.
        if($n_orig)
        {
            # At least one original value survived.
            # Kill all states where no original values survived.
            @states = grep {$_->{original}} @states;
        }
        # Fork states where more than one original value survived.
        for(my $i = 0; $i<=$#states; $i++)
        {
            if(ref($states[$i]{value}) eq "ARRAY")
            {
                # Copy second and higher values to new states.
                for(my $j = 1; $j<=$#{$states[$i]{value}}; $j++)
                {
                    my %new_fs = %{$states[$i]{fs}};
                    my %new_state =
                    (
                        "pointer"  => $states[$i]{pointer},
                        "feature"  => $states[$i]{feature},
                        "value"    => $states[$i]{value}[$j],
                        "original" => 1,
                        "fs"       => \%new_fs
                    );
                    push(@states, \%new_state);
                }
                # Keep the first value in the current state.
                $states[$i]{value} = $states[$i]{value}[0];
            }
        }
        # Now every state contains exactly one value. Advance all trie pointers according to the values.
        foreach my $state (@states)
        {
            # Remember the final value of the current feature.
            $state->{fs}{$state->{feature}} = $state->{value};
            $state->{pointer} = $state->{pointer}{$state->{value}};
        }
    }
    # We have one or more states, each of them with different feature structure with permitted values.
    # We must return only one feature structure.
    # However, we may be able to merge some feature structures if they differ only in one feature.
    my @results = map {$_->{fs}} @states;
    my $merged_results = merge_feature_structures(\@results);
    # If there are more than one resulting feature structures after merging, we
    # do not know which one is the best. We just pick the first and return it.
    # (However, there should always be at least one!)
    if(scalar(@{$merged_results})==0)
    {
        confess("At least one feature structure should survive but none did.\n");
    }
    return $merged_results->[0];
}



###############################################################################
# TRIE FUNCTIONS
###############################################################################



#------------------------------------------------------------------------------
# Adds a value to the trie of permitted feature structures. Gets the name of
# the feature (only to be able to recognize the last feature in the trie) and
# a pointer to the trie level corresponding to that feature. The pointer is a
# reference to an existing hash. It also gets the value of the feature. If the
# hash referenced by the pointer already has a key corresponding to the value,
# the function only advances to the sub-hash referenced by the value, and
# returns the new pointer. If there is no such key, the function first creates
# the new sub-hash and then advances the pointer. If this is the last feature,
# the function stores a tag example instead of a new sub-hash under the value.
#------------------------------------------------------------------------------
sub add_value_to_trie
{
    my $feature = shift;
    my $value = shift;
    my $pointer = shift;
    my $tag = shift;
    if(!exists($pointer->{$value}))
    {
        if($feature ne $features[$#features])
        {
            my %new_sub_hash;
            $pointer->{$value} = \%new_sub_hash;
        }
        else
        {
            $pointer->{$value} = $tag;
        }
    }
    return $pointer->{$value};
}



#------------------------------------------------------------------------------
# Advances a trie pointer. Normally it observes the value of the current
# feature. Special treatment of the "tagset" and "other" features.
#------------------------------------------------------------------------------
sub advance_trie_pointer
{
    my $feature = shift;
    my $value = shift;
    my $pointer = shift;
    if($feature =~ m/^(tagset|other)$/)
    {
        my @keys = keys(%{$pointer});
        $value = $keys[0];
    }
    else
    {
        if(ref($value) eq "ARRAY")
        {
            $value = join("|", @{$value});
        }
        if(!exists($pointer->{$value}))
        {
            confess("Dead trie pointer.\n");
        }
    }
    return $pointer->{$value};
}



###############################################################################
# GENERIC FEATURE STRUCTURE MANIPULATION
###############################################################################



#------------------------------------------------------------------------------
# Compares two values, scalars or arrays, whether they are equal or not.
#------------------------------------------------------------------------------
sub iseq
{
    my $a = shift;
    my $b = shift;
    if(ref($a) ne ref($b))
    {
        return 0;
    }
    elsif(ref($a) eq "ARRAY")
    {
        return array_to_scalar_value($a) eq array_to_scalar_value($b);
    }
    else
    {
        return $a eq $b;
    }
}



#------------------------------------------------------------------------------
# Converts array values to scalars. Sorts the array and combines all elements
# in one string, using the vertical bar as delimiter. Does not care about
# occurrences of vertical bars inside the elements (there should be none
# anyway).
#------------------------------------------------------------------------------
sub array_to_scalar_value
{
    my $value = shift;
    if(ref($value) eq "ARRAY")
    {
        # The sorting helps to ensure that values from two arrays with the same
        # elements will be stringwise identical.
        $value = join("|", sort(@{$value}));
    }
    return $value;
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
# Searches a set of feature structures for pairs of compatible structures that
# can be merged. Merges as many as possible and returns a new set of feature
# structures. (The new set can contain references to structures of the old set
# that have not been merged, as well as references to newly created merged
# structures.)
#------------------------------------------------------------------------------
sub merge_feature_structures
{
    my $set = shift; # reference to array of hashes (feature structures)
    for(my $i = 0; $i<=$#{$set}; $i++)
    {
        # Look for structures that are similar to the i-th structure.
        for(my $j = $i+1; $j<=$#{$set}; $j++)
        {
            # Compare the i-th and the j-th structure. Note in how many features they differ.
            my $diff = compare_feature_structures($set->[$i], $set->[$j], 2);
            if(scalar(@{$diff})<=1)
            {
                my $merged_fs = merge_two_feature_structures($set->[$i], $set->[$j], $diff->[0]);
                # Create new set of feature structures. These two will be merged (in place of the i-th), rest will be unchanged.
                my @new_set;
                for(my $k = 0; $k<=$#{$set}; $k++)
                {
                    if($k==$i)
                    {
                        push(@new_set, $merged_fs);
                    }
                    elsif($k!=$j)
                    {
                        push(@new_set, $set->[$k]);
                    }
                }
                # Replace the original set by the new set. Start over because new merging opportunities may have emerged.
                $set = \@new_set;
                $j = $#{$set};
                $i = -1;
            }
        }
    }
    # Return the current $set. This may or may not be the original reference
    # to the original array.
    return $set;
}



#------------------------------------------------------------------------------
# Compares two feature structures (only known features are compared). Returns
# a reference to the array of names of features in which the two structures
# differ.
#------------------------------------------------------------------------------
sub compare_feature_structures
{
    my $fs1 = shift;
    my $fs2 = shift;
    my $limit = shift; # if nonzero, stop after $limit differences have been found
    my @diff;
    foreach my $f (@features)
    {
        # Compare the values of feature $f.
        my $val1 = $fs1->{$f};
        my $val2 = $fs2->{$f};
        my $ref1 = ref($val1);
        my $ref2 = ref($val2);
        my $diff = 0;
        if($ref1 eq "ARRAY" && $ref2 eq "ARRAY")
        {
            my @sort1 = sort(@{$val1});
            my @sort2 = sort(@{$val2});
            if($#sort1 != $#sort2)
            {
                $diff = 1;
            }
            else
            {
                for(my $k = 0; $k<=$#sort1; $k++)
                {
                    if($sort1[$k] ne $sort2[$k])
                    {
                        $diff = 1;
                        last;
                    }
                }
            }
        }
        elsif($ref1 ne $ref2)
        {
            $diff = 1;
        }
        elsif($val1 ne $val2)
        {
            $diff = 1;
        }
        if($diff)
        {
            push(@diff, $f);
            last if($limit && scalar(@diff)>=$limit);
        }
    }
    return \@diff;
}



#------------------------------------------------------------------------------
# Merges two feature structures that differ at most in one feature. The values
# of the differing feature will be merged into one set. (If the structures
# differed in two or more features, they would not be compatible. There would
# be no guarantee that all combinations of the values of the differing features
# are allowed.) Returns reference to a new structure.
#------------------------------------------------------------------------------
sub merge_two_feature_structures
{
    my $fs1 = shift;
    my $fs2 = shift;
    my $differing_feature = shift;
    my $fs = duplicate($fs1);
    if($differing_feature ne "")
    {
        $fs->{$differing_feature} = merge_values($fs1->{$differing_feature}, $fs2->{$differing_feature});
    }
    return $fs;
}



#------------------------------------------------------------------------------
# Creates a deep copy of a feature structure. If there is a reference to an
# array of values, a copy of the array is created and the copy is referenced
# from the new structure, rather than just copying the reference to the old
# array. The same holds for the "other" feature, which can contain references
# to arrays and / or hashes nested in unlimited number of levels. In fact, this
# function could be used for any nested structures, not just feature
# structures.
#------------------------------------------------------------------------------
sub duplicate
{
    my $source = shift;
    my $duplicate;
    my $ref = ref($source);
    if($ref eq "ARRAY")
    {
        my @new_array;
        foreach my $element (@{$source})
        {
            push(@new_array, duplicate($element));
        }
        $duplicate = \@new_array;
    }
    elsif($ref eq "HASH")
    {
        my %new_hash;
        foreach my $key (keys(%{$source}))
        {
            $new_hash{$key} = duplicate($source->{$key});
        }
        $duplicate = \%new_hash;
    }
    else
    {
        $duplicate = $source;
    }
    return $duplicate;
}



#------------------------------------------------------------------------------
# Merges two sets of values of the same feature. The result is scalar or array
# reference. Values from the first set come first and retain their order.
# However, there are no duplicates. The result is an empty scalar if both input
# values were references to empty arrays.
#------------------------------------------------------------------------------
sub merge_values
{
    my $value1 = shift;
    my $value2 = shift;
    my %map;
    my @merged;
    for my $value ($value1, $value2)
    {
        if(ref($value) eq "ARRAY")
        {
            foreach my $v (@{$value})
            {
                unless($map{$v})
                {
                    push(@merged, $v);
                    $map{$v}++;
                }
            }
        }
        else
        {
            unless($map{$value})
            {
                push(@merged, $value);
                $map{$value}++;
            }
        }
    }
    if(scalar(@merged)==0)
    {
        return "";
    }
    elsif(scalar(@merged)==1)
    {
        return $merged[0];
    }
    else
    {
        return \@merged;
    }
}



###############################################################################
# DRIVER FUNCTIONS WITH PARAMETERIZED DRIVERS
###############################################################################



#------------------------------------------------------------------------------
# Tries to enumerate existing tagset drivers. Searches for the "tagset" folder
# in @INC paths. Once found, it searches its subfolders and lists all modules.
#------------------------------------------------------------------------------
sub find_drivers
{
    my @drivers;
    foreach my $path (@INC)
    {
        my $tpath = "$path/tagset";
        if(-d $tpath)
        {
            opendir(DIR, $tpath) or die("Cannot read folder $tpath: $!\n");
            my @subdirs = readdir(DIR);
            closedir(DIR);
            foreach my $sd (@subdirs)
            {
                my $sdpath = "$tpath/$sd";
                if(-d $sdpath && $sd !~ m/^\.\.?$/)
                {
                    opendir(DIR, $sdpath) or die("Cannot read folder $sdpath: $!\n");
                    my @files = readdir(DIR);
                    closedir(DIR);
                    foreach my $file (@files)
                    {
                        my $fpath = "$sdpath/$file";
                        my $driver = $file;
                        if(-f $fpath && $driver =~ s/\.pm$//)
                        {
                            $driver = $sd."::".$driver;
                            push(@drivers, $driver);
                        }
                    }
                }
            }
        }
    }
    @drivers = sort(@drivers);
    return \@drivers;
}



#------------------------------------------------------------------------------
# Decodes a tag using a particular driver.
#------------------------------------------------------------------------------
sub decode
{
    my $driver = shift; # e.g. "cs::pdt"
    my $tag = shift;
    $tag =~ s/([\\"\$\@])/\\$1/g;
    my $eval = <<_end_of_eval_
    {
        use tagset::${driver};
        my \$fs = tagset::${driver}::decode("$tag");
        return \%{\$fs};
    }
_end_of_eval_
    ;
    print("$eval\n") if($debug && 0);
    my %fs = eval($eval);
    if($@)
    {
        confess("$@\nEval failed");
    }
    return \%fs;
}



#------------------------------------------------------------------------------
# Encodes a tag using a particular driver.
#------------------------------------------------------------------------------
sub encode
{
    my $driver = shift; # e.g. "cs::pdt"
    my $fs = shift;
    my $fstring = structure_to_string($fs);
    my $eval = <<_end_of_eval_
    {
        use tagset::${driver};
        my \$tag = tagset::${driver}::encode($fstring);
        return \$tag;
    }
_end_of_eval_
    ;
    print("$eval\n") if($debug && 0);
    my $tag = eval($eval);
    if($@)
    {
        confess("$@\nEval failed");
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Lists all tags of a tag set.
#------------------------------------------------------------------------------
sub list
{
    my $driver = shift; # e.g. "cs::pdt"
    my $eval = <<_end_of_eval_
    {
        use tagset::${driver};
        my \$list_eval = tagset::${driver}::list();
        return \@{\$list_eval};
    }
_end_of_eval_
    ;
    print("$eval\n") if($debug && 0);
    my @list = eval($eval);
    if($@)
    {
        confess("$@\nEval failed");
    }
    return \@list;
}



###############################################################################
# TEXT REPRESENTATION OF STRUCTURES FOR PRINTING AND DEBUGGING
###############################################################################



#------------------------------------------------------------------------------
# If a feature structure is permitted, returns an example of a known tag that
# generates the same feature structure. Otherwise returns an empty string.
#------------------------------------------------------------------------------
sub get_tag_example
{
    my $fs = shift; # ref to hash with feature structure
    my $trie = shift;
    foreach $f (@features)
    {
        if($f =~ m/^(tagset|other)$/)
        {
            my @klice = keys(%{$trie});
            $trie = $trie->{$klice[0]};
        }
        else
        {
            if(exists($trie->{$fs->{$f}}))
            {
                $trie = $trie->{$fs->{$f}};
            }
            else
            {
                return "Forbidden value $fs->{$f} of feature $f";
            }
        }
    }
    return $trie;
}



#------------------------------------------------------------------------------
# Debugging function. Prints permitted feature values to STDERR.
#------------------------------------------------------------------------------
sub print_permitted_values
{
    my $permitvals = shift;
    print STDERR ("The following feature values are permitted:\n");
    foreach my $feature (sort(keys(%{$permitvals})))
    {
        print STDERR ("$feature:\t", join(", ", map{"\"$_\""}(sort(grep{$permitvals->{$feature}{$_}}(keys(%{$permitvals->{$feature}}))))), "\n");
    }
}



#------------------------------------------------------------------------------
# Debugging function. Prints permitted feature value combinations to STDERR.
#------------------------------------------------------------------------------
sub get_permitted_combinations_as_text
{
    my $permitcombs = shift;
    return get_permitted_combinations_as_text_recursion({}, 0, $permitcombs);
}



#------------------------------------------------------------------------------
# Recursive part of printing permitted feature value combinations.
#------------------------------------------------------------------------------
sub get_permitted_combinations_as_text_recursion
{
    my $fs0 = shift; # partially filled feature structure (hash reference)
    my $i = shift; # index to the global list of @features of the next feature to process
    my $trie = shift; # pointer to the trie (hash reference)
    return if($i>$#features);
    my $string;
    # Loop through permitted values of the next feature.
    my @values = sort(keys(%{$trie}));
    foreach my $value (@values)
    {
        # Add the value of the next feature to the feature structure.
        my %fs1 = %{$fs0};
        $fs1{$features[$i]} = $value;
        # If this is the last feature, print the feature structure.
        if($i==$#features)
        {
            $string .= "[";
            $string .= join(",", map{"$_=\"$fs1{$_}\""}(grep{$fs1{$_} ne ""}(@features)));
            $string .= "]\n";
        }
        # Otherwise, go to the next feature.
        else
        {
            $string .= get_permitted_combinations_as_text_recursion(\%fs1, $i+1, $trie->{$value});
        }
    }
    return $string;
}



#------------------------------------------------------------------------------
# Generates text from contents of feature structure so it can be printed.
#------------------------------------------------------------------------------
sub feature_structure_to_text
{
    my $fs = shift; # hash reference
    my @assignments = map
    {
        my $f = $_;
        my $v = $fs->{$f};
        if(ref($v) eq "ARRAY")
        {
            $v = join("|", map {"\"$_\""} @{$v});
        }
        else
        {
            $v = "\"$v\"";
        }
        "$f=$v";
    }
    (grep{$fs->{$_} ne ""}(@known_features));
    return "[".join(",", @assignments)."]";
}



#------------------------------------------------------------------------------
# Recursively converts a structure to string describing a Perl constant.
# Useful for using eval.
#------------------------------------------------------------------------------
sub structure_to_string
{
    my $source = shift;
    my $string;
    my $ref = ref($source);
    if($ref eq "ARRAY")
    {
        $string = "[".join(", ", map{structure_to_string($_)}(@{$source}))."]";
    }
    elsif($ref eq "HASH")
    {
        $string = "{".join(", ", map{structure_to_string($_)." => ".structure_to_string($source->{$_})}(keys(%{$source})))."}";
    }
    else
    {
        $string = $source;
        $string =~ s/([\\"\$\@])/\\$1/g;
        $string = "\"$string\"";
    }
    return $string;
}



1;
