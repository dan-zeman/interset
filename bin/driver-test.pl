#!/usr/bin/env perl
# Tests integrity of DZ Interset drivers.
# Copyright © 2007, 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL
# 11.6.2014: Adapted to Interset 2.0.

use strict;
use warnings;
use utf8;
use open ':utf8';
binmode(STDIN,  ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage
{
    print STDERR ("Usage: driver-test.pl [-d] driver [driver2 [driver3...]]\n");
    print STDERR ("       driver-test.pl [-d] -a\n");
    print STDERR ("       driver-test.pl [-d] -A\n");
    print STDERR ("  driver name example: ar::conll\n");
    print STDERR ("  -a: test all known drivers but no pairs of drivers\n");
    print STDERR ("  -A: test all known drivers and all pairs of drivers\n");
    print STDERR ("  -d: debug mode (list tags being tested)\n");
    print STDERR ("  -o: print known tags together with unknown tags created by stripping the 'other' feature\n");
    print STDERR ("  -O: same as -o but without additional info, i.e. directly copyable to the list() function\n");
}

use Getopt::Long qw(:config no_ignore_case bundling);
use Carp; # confess()
use Lingua::Interset qw(find_drivers get_driver_object);
use Lingua::Interset::FeatureStructure qw(feature_valid value_valid);

# Autoflush after every Perl statement.
my $old_fh = select(STDOUT);
$| = 1;
select(STDERR);
$| = 1;
select($old_fh);
# Get options.
my $all = 0;
my $all_conversions = 0;
my $drivers;
my $conversions;
my $debug = 0;
my $list_other;
my $list_other_plain;
GetOptions('a' => \$all, 'A' => \$all_conversions, 'debug' => \$debug, 'o' => \$list_other, 'O' => \$list_other_plain);
# Get the list of all drivers if needed.
if($all || $all_conversions)
{
    $drivers = find_drivers();
    $conversions = $all_conversions;
}
else
{
    $drivers = \@ARGV;
    $conversions = scalar(@{$drivers})>1;
}
# If the list of drivers is empty, show the list of available drivers and exit.
if(scalar(@{$drivers})==0)
{
    usage();
    my $drivers = find_drivers();
    if(scalar(@{$drivers}))
    {
        print STDERR ("\nThe following tagset drivers are available on this system:\n");
        foreach my $driver (@{$drivers})
        {
            print STDERR ("\t$driver->{tagset}\t$driver->{path}\t$driver->{package}\n");
        }
        my $n_drivers = scalar(@{$drivers});
        print STDERR ("Total $n_drivers drivers.\n");
        my $driver_hash = Lingua::Interset::get_driver_hash();
        print("Total ", scalar(keys(%{$driver_hash})), " tagsets.\n");
    }
    else
    {
        print STDERR ("\nNo tagset drivers have been found on this system.\n");
    }
}
else
{
    my $starttime = time();
    # Start with testing each driver separately (this is also a prerequisite to testing of pairs).
    foreach my $d (@{$drivers})
    {
        # If there were errors, interrupt testing so we do not overlook the errors.
        last if(test($d));
    }
    # Continue with testing conversions from one driver to another, if asked for it.
    if($conversions)
    {
        foreach my $d1 (@{$drivers})
        {
            foreach my $d2 (@{$drivers})
            {
                next if($d2 eq $d1);
                test_conversion($d1, $d2);
                print("\n");
            }
        }
    }
    print("Total duration ", duration($starttime), ".\n");
}



#------------------------------------------------------------------------------
# Tests a single driver.
#------------------------------------------------------------------------------
sub test
{
    my $tagset = shift; # e.g. "cs::pdt"
    my $starttime = time();
    print("Testing $tagset ...");
    my $driver = get_driver_object($tagset);
    my $list = $driver->list();
    my $n_tags = scalar(@{$list});
    print(" $n_tags tags");
    # Hash the known tags so that we can query whether a tag is known.
    my %known;
    foreach my $tag (@{$list})
    {
        $known{$tag}++;
    }
    # We will collect unknown tags created by erasing 'other' and encoding again.
    my %unknown;
    # We will also collect known tags after erasing 'other' and encoding again.
    my %other_survivors;
    my $n_errors = 0;
    my $n_other = 0;
    foreach my $tag (@{$list})
    {
        if($debug)
        {
            print STDERR ("Now testing tag $tag\n");
        }
        my @errors = $driver->test_tag($tag, \$n_other, \%other_survivors);
        foreach my $error (@errors)
        {
            if($n_errors==0)
            {
                print("\n\n");
            }
            print("$error\n");
        }
        $n_errors += @errors;
        # We do not want to wait for all the errors if there are thousands of them.
        # We want to start fixing them because we have to fix them all anyway.
        last if($n_errors>=100);
        ###!!! By moving the test to the Tagset module we lost updating the %unknown hash.
    }
    # We can print the list of all tags including the unknown ones but normally we do not want to.
    if($list_other || $list_other_plain)
    {
        my @known = keys(%known);
        my @unknown = keys(%unknown);
        list_known_and_unknown_tags(\@known, \@unknown, $list_other_plain, $driver);
    }
    if($n_errors)
    {
        confess("Tested $n_tags tags, found $n_errors errors.\n");
    }
    else
    {
        print(" OK\n");
        print("$n_other tags use the 'other' feature.\n");
        my $n_other_survivors = scalar(keys(%other_survivors));
        print("$n_other_survivors tags are independent on 'other' (they survive encode(decode(x)-other)).\n");
    }
    print("Duration ", duration($starttime), ".\n");
    return $n_errors;
}



#------------------------------------------------------------------------------
# Converts all tags of tagset 1 to tagset 2. Checks whether the target tags are
# permitted in tagset 2.
#------------------------------------------------------------------------------
sub test_conversion
{
    my $tagset1 = shift;
    my $tagset2 = shift;
    my $starttime = time();
    my $driver1 = get_driver_object($tagset1);
    my $driver2 = get_driver_object($tagset2);
    print("Testing conversion from $tagset1 to $tagset2.\n");
    my $n_tags = 0;
    my $n_errors = 0;
    my $list1 = $driver1->list();
    my $list2 = $driver2->list();
    if(scalar(@{$list1})==0)
    {
        print("List of known tags of $tagset1 is empty. Nothing to test.\n");
        return 0;
    }
    if(scalar(@{$list2})==0)
    {
        print("List of known tags of $tagset2 is empty. Nothing to test.\n");
        return 0;
    }
    # Hash list 2 so that we can check which tags are permitted.
    my %tagset2;
    foreach my $t (@{$list2})
    {
        $tagset2{$t}++;
    }
    # Remember used target tags so that we can evaluate information loss.
    my %t2hits;
    # We will collect unknown tags created by erasing 'other' and encoding again.
    my %unknown;
    # Convert all tagset 1 tags to tagset 2 and check whether the result is permitted.
    foreach my $src (@{$list1})
    {
        my $fs = $driver1->decode($src);
        my $tgt = $driver2->encode($fs);
        $t2hits{$tgt}++;
        if($debug)
        {
            my $fs1 = correct($driver2, $fs);
            print("Source tag = $src\n");
            print("Features   = ", $fs->as_string(), "\n");
            print("Corrected  = ", $fs1->as_string(), "\n");
            print("Target tag = $tgt\n");
            print("\n");
        }
        if(!exists($tagset2{$tgt}))
        {
            my $fs1 = correct($driver2, $fs);
            print("\n\n") if($n_errors==0);
            print("Source tag = $src\n");
            print("Features   = ", $fs->as_string(), "\n");
            print("Corrected  = ", $fs1->as_string(), "\n");
            print("Example    = ", get_tag_example($driver2, $fs1), "\n");
            print("Target tag = $tgt\n");
            print("The target tag is not known in the target tagset.\n\n");
#            die();
            $n_errors++;
            $unknown{$tgt}++;
        }
        $n_tags++;
    }
    # We can print the list of all tags including the unknown ones but normally we do not want to.
    if($list_other || $list_other_plain)
    {
        my @known = keys(%tagset2);
        my @unknown = keys(%unknown);
        my ($decode, $encode, $listf) = tagset::common::get_driver_functions($driver2);
        list_known_and_unknown_tags(\@known, \@unknown, $list_other_plain, $decode);
    }
    if($n_errors)
    {
        # Repeat the initial message. It may not be visible now after all the error messages
        # and we may not know what conversion test this was.
        print("Tested conversion from $tagset1 to $tagset2.\n");
        print("Tested $n_tags tags, found $n_errors errors.\n");
        confess();
    }
    else
    {
        my $n_hits = scalar(keys(%t2hits));
        # Tagset of only one tag bears zero information.
        my $src_inf = $n_tags-1;
        my $tgt_inf = $n_hits-1;
        unless($tgt_inf)
        {
            print("The converted tags bear no information (all source tags were converted to the same target tag)!\n");
            confess();
        }
        print("$n_tags source tags mapped to $n_hits of total ", scalar(@{$list2}), " target tags.\n");
        if($src_inf)
        {
            my $inf_loss = ($src_inf-$tgt_inf)/$src_inf;
            printf("Information loss %d %%.\n", $inf_loss*100+0.5);
        }
        # For each used target tag, show how many source tags have been mapped to it.
        if($n_hits<=20)
        {
            foreach my $key (sort(keys(%t2hits)))
            {
                print("Target tag $key hit by $t2hits{$key} source tags.\n");
            }
        }
    }
    print("Duration ", duration($starttime), ".\n");
}



#------------------------------------------------------------------------------
# Takes a list of known tags and a list of unknown tags, merges them and prints
# the resulting list with explanatory feature structures. If the known tags
# have just been collected from a corpus (which probably means that other tags
# may exist and be valid), the joint list helps decide whether the unknown tags
# seem reasonable and may be added to the list of known tags.
#------------------------------------------------------------------------------
sub list_known_and_unknown_tags
{
    my $known = shift; # reference to array
    my $unknown = shift; # reference to array
    # Plain list means without UNK flags and feature structures.
    # Plain list is suitable for directly copying to the list() function in the driver.
    my $plain = shift; # boolean
    my $driver = shift; # Lingua::Interset::Tagset
    # Merge known and unknown tags into one list but remember the knownness.
    my %unknown;
    unless($plain)
    {
        foreach my $tag (@{$unknown})
        {
            $unknown{$tag}++;
        }
    }
    # Merge and remove duplicates if any.
    # Neither of known and unknown should contain duplicates and the lists should not overlap but let's check it, it is not guaranteed.
    my %map;
    foreach my $tag (@{$known}, @{$unknown})
    {
        $map{$tag}++;
    }
    my @all = sort(keys(%map));
    foreach my $tag (@all)
    {
        if($plain)
        {
            print("$tag\n");
        }
        else
        {
            print(exists($unknown{$tag}) ? 'UNK   ' : '      ');
            print($tag);
            my $f = $driver->decode($tag);
            print('   ', $f->as_string());
            print("\n");
        }
    }
}



#------------------------------------------------------------------------------
# Corrects a feature structure to comply with a driver's expectations. Mimics
# what drivers usually do to perform strict encoding.
#------------------------------------------------------------------------------
sub correct
{
    my $driver = shift; # Lingua::Interset::Tagset
    my $fs0 = shift; # Lingua::Interset::FeatureStructure
    my $fs1 = $fs0->duplicate();
    my $permitted = $driver->permitted_structures();
    $fs1->enforce_permitted_values($permitted);
    return $fs1;
}



#------------------------------------------------------------------------------
# Retrieves a tag example for a feature structure permitted by a driver.
#------------------------------------------------------------------------------
sub get_tag_example
{
    my $driver = shift; # Lingua::Interset::Tagset
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $permitted = $driver->permitted_structures();
    my $tag = $permitted->get_tag_example($fs);
    return $tag;
}



#------------------------------------------------------------------------------
# Measures time. Gets start time, asks system for current time. Generates
# formatted message about the duration that can be printed out.
#------------------------------------------------------------------------------
sub duration
{
    my $starttime = shift;
    my $stoptime = time();
    my $cas = $stoptime-$starttime;
    my $hod = int($cas/3600);
    my $min = int(($cas%3600)/60);
    my $sek = $cas%60;
    my $hlaseni;
    if($hod==0)
    {
        if($min==0)
        {
            $hlaseni = sprintf("$sek second%s", $sek==1 ? "" : "s");
        }
        else
        {
            $hlaseni = sprintf("%d:%02d minutes", $min, $sek);
        }
    }
    else
    {
        $hlaseni = sprintf("%2d:%02d:%02d hours", $hod, $min, $sek);
    }
    return $hlaseni;
}



1;
