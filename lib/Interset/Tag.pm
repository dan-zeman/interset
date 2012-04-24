#!/usr/bin/env perl
# The main class of DZ Interset 2.0.
# It defines all morphosyntactic features and their values.
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Interset::Tag;
use utf8;
use open ':utf8';
use Moose;



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
