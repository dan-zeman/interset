#!/usr/bin/perl
# Vypíše trie povolených rysů pro dekódovanou sadu značek.
###!!! Možná nemá smysl psát tenhle skript zvlášť, když už existuje print_permitted_fs.pl.
# (c) 2008 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

sub usage
{
    print STDERR ("Usage: print_trie.pl driver\n");
    print STDERR ("  driver name example: ar::conll\n");
}

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use tagset::common;

if(scalar(@ARGV)!=1)
{
    usage();
    die("Missing driver name.\n");
}
$driver = $ARGV[0];
# Get list of tags in the tag set.
$list = tagset::common::list($driver);
if($list eq "")
{
    die("The list of tags of $driver is empty.\n");
}
# Decode tags to feature structures.
foreach my $tag (@{$list})
{
    my $fs = tagset::common::decode($driver, $tag);
    # Store the tag in the structure so we can retrieve it easily.
    $fs->{tag} = $tag;
    # Save the feature structure.
    push(@structures, $fs);
}
# Sort the structures by the feature values.
# Feature priorities are specified by the @features array in common.pm.
# The preferred value ordering is defined in %known_values in common.pm.
foreach my $feature (keys(%tagset::common::known_values))
{
    my $i;
    for($i = 0; $i<=$#{$tagset::common::known_values{$feature}}; $i++)
    {
        $sortval{$feature}{$tagset::common::known_values{$feature}[$i]} = $i;
    }
    $sortval{$feature}{""} = $i;
}
@sorted = sort
{
    my $vysledek = 0;
    foreach my $feature (@tagset::common::features)
    {
        $vysledek = $sortval{$feature}{$a->{$feature}} <=> $sortval{$feature}{$b->{$feature}};
        last if($vysledek);
    }
    return $vysledek;
}
(@structures);
# Print the structures.
foreach my $fs (@sorted)
{
    # The following code is almost exactly the same as in tagset::common::feature_structure_to_text().
    # However, here we want the features to be ordered by trie priority and thus taken from @features, not @known_features.
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
    (grep{$_ ne "tagset" && $fs->{$_} ne ""}(@tagset::common::features));
    print("$fs->{tag}\t[".join(",", @assignments)."]\n");
}
