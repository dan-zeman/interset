#!/usr/bin/env perl
# A temporary envelope that provides access to the old (Interset 1.0) drivers from Interset 2.0.
# Once all the old drivers are ported to Interset 2.0, this module will be removed.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Lingua::Interset::OldTagsetDriver;
use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use Lingua::Interset;
use Lingua::Interset::FeatureStructure;
our $VERSION; BEGIN { $VERSION = "2.00" }
extends 'Lingua::Interset::Tagset';



has 'driver' => ( isa => 'Str', is => 'ro', required => 1 ); # e.g. 'cs::pdt'; not 'tagset::cs::pdt' (the 'tagset' part will be inserted automatically)
# The following attributes are required but they will be automatically derived from 'driver' in BUILDARGS() below.
has 'decode_function' => ( isa => 'CodeRef', is => 'ro', required => 1 );
has 'encode_function' => ( isa => 'CodeRef', is => 'ro', required => 1 );
has 'list_function'   => ( isa => 'CodeRef', is => 'ro', required => 1 );



#------------------------------------------------------------------------------
# This block will be called before object construction. It will take the driver
# attribute from the user and use it to get the three function attributes. Then
# it will pass all the attributes to the constructor.
#------------------------------------------------------------------------------
around BUILDARGS => sub
{
    my $orig = shift;
    my $class = shift;
    # Call the default BUILDARGS in Moose::Object. It will take care of distinguishing between a hash reference and a plain hash.
    my $attr = $class->$orig(@_);
    if($attr->{driver})
    {
        my $driver_hash = Lingua::Interset::get_driver_hash();
        if(!exists($driver_hash->{$attr->{driver}}))
        {
            confess("Unknown tagset driver '$attr->{driver}'");
        }
        if(!$driver_hash->{$attr->{driver}}{old})
        {
            confess("OldTagsetDriver can be used only for old drivers but '$attr->{driver}' is new");
        }
        my $package = $driver_hash->{$attr->{driver}}{package};
        my $eval = <<_end_of_eval_
        {
            use ${package};
            my \$decode = \\&${package}::decode;
            my \$encode = \\&${package}::encode;
            my \$list = \\&${package}::list;
            return (\$decode, \$encode, \$list);
        }
_end_of_eval_
        ;
        my ($decode, $encode, $list) = eval($eval);
        if($@)
        {
            confess("$@\nEval failed");
        }
        # Now add the references to the driver functions to the attribute hash.
        $attr->{decode_function} = $decode;
        $attr->{encode_function} = $encode;
        $attr->{list_function} = $list;
    }
    return $attr;
};



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    my $fs = Lingua::Interset::FeatureStructure->new();
    my $fs_hash = &{$self->decode_function()}($tag);
    $fs->set_hash($fs_hash);
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $fs_hash = $fs->get_hash();
    # Call non-strict ("1") encoding of the old driver. We use a different method ("encode_strict") for strict encoding now.
    my $tag = &{$self->encode_function()}($fs_hash, 1);
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    return &{$self->list_function()}();
}



1;

=over

=item Lingua::Interset::OldTagsetDriver

Provides object envelope for an old, non-object-oriented driver from Interset 1.0.
This makes the old drivers at least partially usable until they are fully ported to Interset 2.0.
Note however that the old drivers use Interset features and/or values that have been changed in the new version.

=back

=cut
