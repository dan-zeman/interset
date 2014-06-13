# ABSTRACT: DZ Interset is a universal morphosyntactic feature set to which all tagsets of all corpora/languages can be mapped.
# Copyright © 2007-2014 Univerzita Karlova v Praze / Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset;

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose 2.1205;
use MooseX::SemiAffordanceAccessor; # attribute x is written using set_x($value) and read using x()
# Allow the user to import the core functions into their namespace by stating
# use Lingua::Interset qw(decode encode list);
use Exporter::Easy ( OK => [ 'decode', 'encode', 'encode_strict', 'list', 'find_drivers', 'get_driver_object' ] );



###############################################################################
# DRIVER FUNCTIONS WITH PARAMETERIZED DRIVERS
###############################################################################



# Static reference to the list of all installed tagset drivers.
# The list will be built lazily, see find_drivers().
my $driver_list = undef;
my $driver_hash = undef; # indexed by tagset id



#------------------------------------------------------------------------------
# Tries to enumerate existing tagset drivers. Searches for relevant folders in
# @INC paths.
#------------------------------------------------------------------------------
sub find_drivers
{
    if(!defined($driver_list))
    {
        $driver_list = _find_drivers();
    }
    return $driver_list;
}
sub _find_drivers
{
    my @drivers;
    foreach my $path (@INC)
    {
        # Old drivers (Interset 1.0) are in the "tagset" folder.
        # We will continue using them until all have been ported to Interset 2.0.
        my $tpath = "$path/tagset";
        if(-d $tpath)
        {
            opendir(DIR, $tpath) or confess("Cannot read folder $tpath: $!\n");
            my @subdirs = readdir(DIR);
            closedir(DIR);
            foreach my $sd (@subdirs)
            {
                my $sdpath = "$tpath/$sd";
                if(-d $sdpath && $sd !~ m/^\.\.?$/)
                {
                    opendir(DIR, $sdpath) or confess("Cannot read folder $sdpath: $!\n");
                    my @files = readdir(DIR);
                    closedir(DIR);
                    foreach my $file (@files)
                    {
                        my $fpath = "$sdpath/$file";
                        my $driver = $file;
                        if(-f $fpath && $driver =~ s/\.pm$//)
                        {
                            $driver = $sd."::".$driver;
                            my %record =
                            (
                                'old'     => 1,
                                'tagset'  => $driver,
                                'package' => "tagset::$driver",
                                'path'    => $fpath
                            );
                            push(@drivers, \%record);
                        }
                    }
                }
            }
        }
        # New drivers (Interset 2.0) are in the "Lingua/Interset" folder.
        # Not everything in this folder is a driver! But subfolders lead to drivers, the additional stuff are files, not folders.
        my $lipath = "$path/Lingua/Interset";
        if(-d $lipath)
        {
            opendir(DIR, $lipath) or confess("Cannot read folder $lipath: $!\n");
            my @subdirs = readdir(DIR);
            closedir(DIR);
            foreach my $sd (@subdirs)
            {
                my $sdpath = "$lipath/$sd";
                if(-d $sdpath && $sd !~ m/^\.\.?$/)
                {
                    opendir(DIR, $sdpath) or confess("Cannot read folder $sdpath: $!\n");
                    my @files = readdir(DIR);
                    closedir(DIR);
                    foreach my $file (@files)
                    {
                        my $fpath = "$sdpath/$file";
                        my $driver = $file;
                        if(-f $fpath && $driver =~ s/\.pm$//)
                        {
                            my $driver_uppercased = "$sd::$driver";
                            my $driver_lowercased = lc($driver_uppercased);
                            my %record =
                            (
                                'old'     => 0,
                                'tagset'  => $driver_lowercased,
                                'package' => "Lingua::Interset::$driver_uppercased",
                                'path'    => $fpath
                            );
                            push(@drivers, \%record);
                        }
                    }
                }
            }
        }
    }
    @drivers = sort {$a->{tagset} cmp $b->{tagset}} (@drivers);
    return \@drivers;
}



#------------------------------------------------------------------------------
# Returns the set of all known tagset drivers indexed by tagset id. If there
# are two drivers installed for the same tagset, it is not defined which one
# will be returned (and something is definitely wrong if they are not
# identical implementations). Exception: Interset 2.0 drivers are prefered over
# the old ones.
#------------------------------------------------------------------------------
sub get_driver_hash
{
    if(!defined($driver_hash))
    {
        my $driver_list = find_drivers();
        # Index the drivers by tagset id.
        my %hash;
        foreach my $driver (@{$driver_list})
        {
            # It is possible (though not exactly desirable) that there are several drivers installed for the same tagset.
            if(exists($hash{$driver->{tagset}}))
            {
                # If the previously encountered driver is old and this one is new, prefer the new one.
                # Otherwise (both are old or both are new) just hope that the two installed modules are identical.
                if($hash{$driver->{tagset}}{old} && !$driver->{old})
                {
                    $hash{$driver->{tagset}} = $driver;
                }
            }
            else # this is the first driver found for this tagset
            {
                $hash{$driver->{tagset}} = $driver;
            }
        }
        $driver_hash = \%hash;
    }
    return $driver_hash;
}



#------------------------------------------------------------------------------
# Decodes a tag using a particular driver.
#------------------------------------------------------------------------------
sub decode
{
    my $tagset = shift; # e.g. "cs::pdt"
    my $driver = get_driver_object($tagset);
    return $driver->decode(@_);
}



#------------------------------------------------------------------------------
# Encodes a tag using a particular driver.
#------------------------------------------------------------------------------
sub encode
{
    my $tagset = shift; # e.g. "cs::pdt"
    my $driver = get_driver_object($tagset);
    return $driver->encode(@_);
}



#------------------------------------------------------------------------------
# Encodes a tag using a particular driver and strict encoding (only known
# tags).
#------------------------------------------------------------------------------
sub encode_strict
{
    my $tagset = shift; # e.g. "cs::pdt"
    my $driver = get_driver_object($tagset);
    return $driver->encode_strict(@_);
}



#------------------------------------------------------------------------------
# Lists all tags of a tag set.
#------------------------------------------------------------------------------
sub list
{
    my $tagset = shift; # e.g. "cs::pdt"
    my $driver = get_driver_object($tagset);
    return $driver->list(@_);
}



#------------------------------------------------------------------------------
# Creates and returns a tagset driver object for a given tagset.
#------------------------------------------------------------------------------
sub get_driver_object
{
    my $tagset = shift; # e.g. "cs::pdt"
    my $driver_hash = get_driver_hash();
    if(!exists($driver_hash->{$tagset}))
    {
        confess("Unknown tagset driver '$tagset'");
    }
    # We will cache the driver objects for tagsets. We do not want to construct them again and again.
    if(!defined($driver_hash->{$tagset}{driver}))
    {
        my $package = $driver_hash->{$tagset}{package};
        my $eval;
        if($driver_hash->{$tagset}{old})
        {
            $eval = <<_end_of_old_eval_
            {
                use ${package};
                use Lingua::Interset::OldTagsetDriver;
                my \$object = Lingua::Interset::OldTagsetDriver->new(driver => '${tagset}');
                return \$object;
            }
_end_of_old_eval_
            ;
        }
        else # new driver
        {
            $eval = <<_end_of_eval_
            {
                use ${package};
                my \$object = ${package}->new();
                return \$object;
            }
_end_of_eval_
            ;
        }
        my $object = eval {$eval};
        if($@)
        {
            confess("$@\nEval failed");
        }
        $driver_hash->{$tagset}{driver} = $object;
    }
    return $driver_hash->{$tagset}{driver};
}



1;

=pod

=head1 SYNOPSIS

  use Lingua::Interset qw(decode encode);

  my $tag1 = 'NN'; # in the English Penn Treebank, "NN" means "noun"
  my $feature_structure = decode('en::penn', $tag1);
  print($feature_structure->as_string(), "\n");
  $feature_structure->set_number('plu');
  my $tag2 = encode('en::penn', $feature_structure);
  print("$tag2\n");

=head1 DESCRIPTION

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

Individual tagsets are mapped to the Interset using specialized modules
called I<tagset drivers>. Every driver must implement three methods:
C<decode>, C<encode> and C<list>.

The main module, C<Lingua::Interset>, provides parameterized access to the
drivers and their methods. Instead of having to C<use> particular modules
(which would mean you know in advance what tagsets your program will be
working with) you just specify the tagset giving its I<identifier> as a parameter.
Tagset ids are derived from Perl package names but they are always all-lowercase.
Most tagsets are taylored for one language and their id has two components (separated by C<::>):
the ISO 639 code of the language, and a part to distinguish various tagsets for the language.
This second component may be some sort of abbreviated name of the corpus where the tagset is used,
for example.

More information is given at the DZ Interset project page,
L<https://wiki.ufal.ms.mff.cuni.cz/user:zeman:interset>.

=func decode()

Takes tagset id and a tag in that tagset. Returns a C<Lingua::Interset::FeatureStructure> object
with corresponding feature values set.

=func encode()

Takes tagset id and a C<Lingua::Interset::FeatureStructure> object.
Returns the tag in the given tagset that corresponds to the feature values.
Note that some features may be ignored because they cannot be represented
in the given tagset.

=func list()

Takes tagset id and returns the reference to the list of all known tags of that tagset.
This is not directly needed to decode, encode or convert tags but it is very useful
for testing and advanced operations over the tagset.
Note however that many tagset drivers contain only an approximate list,
created by collecting tag occurrences in some corpus.

=cut
