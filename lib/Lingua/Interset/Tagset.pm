#!/usr/bin/env perl
# The root class for all physical tagsets covered by DZ Interset 2.0.
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Lingua::Interset::Tagset;
use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use Lingua::Interset::FeatureStructure;
our $VERSION; BEGIN { $VERSION = "2.00" }



###!!! A temporary toy example.
my %postable =
(
    '.'     => ['pos' => 'punc', 'punctype' => 'peri'],
    ','     => ['pos' => 'punc', 'punctype' => 'comm'],
    '-LRB-' => ['pos' => 'punc', 'punctype' => 'brck', 'puncside' => 'ini'],
    '-RRB-' => ['pos' => 'punc', 'punctype' => 'brck', 'puncside' => 'fin'],
    '``'    => ['pos' => 'punc', 'punctype' => 'quot', 'puncside' => 'ini'],
    "''"    => ['pos' => 'punc', 'punctype' => 'quot', 'puncside' => 'fin'],
    ':'     => ['pos' => 'punc'],
    '$'     => ['pos' => 'punc', 'punctype' => 'symb', 'other' => 'currency'],
    '\#'    => ['pos' => 'punc', 'other' => '\#'],
    'AFX'   => ['pos' => 'adj',  'hyph' => 'hyph'],
    'CC'    => ['pos' => 'conj', 'conjtype' => 'coor'],
);



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    my $fs = Lingua::Interset::FeatureStructure->new();
    ###!!! A temporary toy example.
    $self->tagset('en::penn');
    my $assignments = $postable{$tag};
    if($assignments)
    {
        for(my $i = 0; $i<=$#{$assignments}; $i += 2)
        {
            $fs->set($assignments->[$i], $assignments->[$i+1]);
        }
    }
    return $fs;
}



1;

=over

=item Lingua::Interset::Tagset

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

The C<Tagset> class defines is the inheritance root for all classes describing
physical tagsets (strings of characters). It defines decoding of tags, encoding
and list of known tags.

=back

=cut

# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# This file is distributed under the GNU General Public License v3. See doc/COPYING.txt.
