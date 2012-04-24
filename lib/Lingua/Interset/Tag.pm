#!/usr/bin/env perl
# The main class of DZ Interset 2.0.
# It defines all morphosyntactic features and their values.
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Lingua::Interset::Tag;
use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
our $VERSION; BEGIN { $VERSION = "2.00" }



has pos          => ( is => 'rw', default => '' );
has subpos       => ( is => 'rw', default => '' );
has prontype     => ( is => 'rw', default => '' );
has numtype      => ( is => 'rw', default => '' );
has numform      => ( is => 'rw', default => '' );
has numvalue     => ( is => 'rw', default => '' );
has advtype      => ( is => 'rw', default => '' );
has punctype     => ( is => 'rw', default => '' );
has puncside     => ( is => 'rw', default => '' );
has synpos       => ( is => 'rw', default => '' );
has poss         => ( is => 'rw', default => '' );
has reflex       => ( is => 'rw', default => '' );
has negativeness => ( is => 'rw', default => '' );
has definiteness => ( is => 'rw', default => '' );
has gender       => ( is => 'rw', default => '' );
has animateness  => ( is => 'rw', default => '' );
has number       => ( is => 'rw', default => '' );
has case         => ( is => 'rw', default => '' );
has prepcase     => ( is => 'rw', default => '' );
has degree       => ( is => 'rw', default => '' );
has subcat       => ( is => 'rw', default => '' );
has verbform     => ( is => 'rw', default => '' );
has mood         => ( is => 'rw', default => '' );
has tense        => ( is => 'rw', default => '' );
has subtense     => ( is => 'rw', default => '' );
has voice        => ( is => 'rw', default => '' );
has aspect       => ( is => 'rw', default => '' );
has foreign      => ( is => 'rw', default => '' );
has abbr         => ( is => 'rw', default => '' );
has hyph         => ( is => 'rw', default => '' );
has echo         => ( is => 'rw', default => '' );
has style        => ( is => 'rw', default => '' );
has typo         => ( is => 'rw', default => '' );
has variant      => ( is => 'rw', default => '' );
has tagset       => ( is => 'rw', default => '' );
has other        => ( is => 'rw', default => '' );



1;

=over

=item Lingua::Interset::Tag

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

The C<Tag> class defines all morphosyntactic features and their values used
in DZ Interset.

=back

=cut

# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# This file is distributed under the GNU General Public License v3. See doc/COPYING.txt.
