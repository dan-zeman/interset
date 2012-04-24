#!/usr/bin/env perl
# The main class of DZ Interset 2.0.
# It defines all morphosyntactic features and their values.
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Interset::Tag;
use utf8;
use open ':utf8';
use Moose;



has pos          => ( is => 'rw' );
has subpos       => ( is => 'rw' );
has prontype     => ( is => 'rw' );
has numtype      => ( is => 'rw' );
has numform      => ( is => 'rw' );
has numvalue     => ( is => 'rw' );
has advtype      => ( is => 'rw' );
has punctype     => ( is => 'rw' );
has puncside     => ( is => 'rw' );
has synpos       => ( is => 'rw' );
has poss         => ( is => 'rw' );
has reflex       => ( is => 'rw' );
has negativeness => ( is => 'rw' );
has definiteness => ( is => 'rw' );
has gender       => ( is => 'rw' );
has animateness  => ( is => 'rw' );
has number       => ( is => 'rw' );
has case         => ( is => 'rw' );
has prepcase     => ( is => 'rw' );
has degree       => ( is => 'rw' );
has subcat       => ( is => 'rw' );
has verbform     => ( is => 'rw' );
has mood         => ( is => 'rw' );
has tense        => ( is => 'rw' );
has subtense     => ( is => 'rw' );
has voice        => ( is => 'rw' );
has aspect       => ( is => 'rw' );
has foreign      => ( is => 'rw' );
has abbr         => ( is => 'rw' );
has hyph         => ( is => 'rw' );
has echo         => ( is => 'rw' );
has style        => ( is => 'rw' );
has typo         => ( is => 'rw' );
has variant      => ( is => 'rw' );
has tagset       => ( is => 'rw' );
has other        => ( is => 'rw' );



1;

=over

=item Interset::Tag

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

The C<Tag> class defines all morphosyntactic features and their values used
in DZ Interset.

=back

=cut

# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# This file is distributed under the GNU General Public License v3. See doc/COPYING.txt.
