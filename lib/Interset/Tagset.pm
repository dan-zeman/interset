#!/usr/bin/env perl
# The root class for all physical tagsets covered by DZ Interset 2.0.
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Interset::Tagset;
use utf8;
use open ':utf8';
use Moose;



1;

=over

=item Interset::Tagset

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
