#!/usr/bin/env perl
# The main class of DZ Interset 2.0.
# It defines all morphosyntactic features and their values.
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Lingua::Interset::FeatureStructure;
use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
our $VERSION; BEGIN { $VERSION = "2.00" }



# Should the features have their own classes, too?
# Pluses:
# + We could bind all properties of one feature tighter (its name, its priority, list of values and their intuitive ordering, list of default value changes).
# + There would be more space for additional services such as documentation and examples of the feature values.
# Minuses:
# - It is good to have them all together here. Better overall picture, mutual relations checking etc. If they are spread across 30 files, the picture will be lost.
# - Handling classes might turn out to be more complicated than handling simple attributes?
# - Perhaps efficiency issues?
# These are the features and values defined in DZ Interset:
has 'pos'          => ( is  => 'rw', default => '',
                        isa => enum ['noun', 'adj', 'num', 'verb', 'adv', 'prep', 'conj', 'part', 'int', ''] ); ###!!! RENAME prep to adp (adposition)?
has 'subpos'       => ( is  => 'rw', default => '',
                        isa => enum ['mod', 'ex', 'voc', 'post', 'circ', 'preppron', 'comprep', 'emp', 'res', 'inf', 'vbp', ''] );
has 'nountype'     => ( is  => 'rw', default => '',
                        isa => enum ['com', 'prop', 'class', ''] ); ###!!! NEW FEATURE (from subpos)
has 'adjtype'      => ( is  => 'rw', default => '',
                        isa => enum ['pdt', 'det', 'art', ''] ); ###!!! NEW FEATURE (from subpos)
has 'prontype'     => ( is  => 'rw', default => '',
                        isa => enum ['prn', 'prs', 'rcp', 'int', 'rel', 'dem', 'neg', 'ind', 'tot', ''] ); ###!!! NEW VALUE prn ... pronominal, without knowing the exact type
has 'numtype'      => ( is  => 'rw', default => '',
                        isa => enum ['card', 'ord', 'mult', 'frac', 'gen', 'dist', ''] );
has 'numform'      => ( is  => 'rw', default => ''
                        isa => enum ['word', 'digit', 'roman', ''] );
has 'numvalue'     => ( is  => 'rw', default => '',
                        isa => enum ['1', '2', '3', ''] );
has 'verbtype'     => ( is  => 'rw', default => '',
                        isa => enum ['aux', 'cop', 'mod', 'verbconj', ''] ); ###!!! NEW FEATURE (from subpos)
has 'advtype'      => ( is  => 'rw', default => '',
                        isa => enum ['man', 'loc', 'tim', 'deg', 'cau', ''] );
has 'conjtype'     => ( is  => 'rw', default => '',
                        isa => enum ['coor', 'sub', 'comp', ''] ); ###!!! NEW FEATURE (from subpos)
has 'punctype'     => ( is  => 'rw', default => '',
                        isa => enum ['peri', 'qest', 'excl', 'quot', 'brck', 'comm', 'colo', 'semi', 'dash', 'symb', 'root', ''] );
has 'puncside'     => ( is  => 'rw', default => '',
                        isa => enum ['ini', 'fin', ''] );
has 'synpos'       => ( is  => 'rw', default => '',
                        isa => enum ['subst', 'attr', 'adv', 'pred', ''] ); ###!!! DO WE STILL NEED THIS?
# For the following group of almost-boolean attributes I am not sure what would be the best internal representation.
# However, regardless the representation, I would like the setter (writer) method to accept boolean values (zero/nonzero), too.
has 'poss'         => ( is  => 'rw', default => '',
                        isa => enum ['poss', ''] ); ###!!! OR yes-no-empty? But I do not think it would be practical.
has 'reflex'       => ( is  => 'rw', default => '',
                        isa => enum ['reflex', ''] ); ###!!! OR yes-no-empty? But I do not think it would be practical.
has 'foreign'      => ( is  => 'rw', default => '',
                        isa => enum ['foreign', ''] ); ###!!! OR yes-no-empty? But I do not think it would be practical.
has 'abbr'         => ( is  => 'rw', default => '',
                        isa => enum ['abbr', ''] ); ###!!! OR yes-no-empty? But I do not think it would be practical.
has 'hyph'         => ( is  => 'rw', default => '',
                        isa => enum ['hyph', ''] ); ###!!! OR yes-no-empty? But I do not think it would be practical.
has 'typo'         => ( is  => 'rw', default => '',
                        isa => enum ['typo', ''] ); ###!!! OR yes-no-empty? But I do not think it would be practical.
has 'echo'         => ( is  => 'rw', default => '',
                        isa => enum ['rdp', 'ech', ''] );
has 'negativeness' => ( is  => 'rw', default => '',
                        isa => enum ['pos', 'neg', ''] );
has 'definiteness' => ( is  => 'rw', default => '',
                        isa => enum ['ind', 'def', 'red', 'com', ''] );
has 'gender'       => ( is  => 'rw', default => '',
                        isa => enum ['masc', 'fem', 'com', 'neut', ''] );
has 'animateness'  => ( is  => 'rw', default => '',
                        isa => enum ['anim', 'nhum', 'inan', ''] );
has 'number'       => ( is  => 'rw', default => '',
                        isa => enum ['sing', 'dual', 'plu', 'ptan', 'coll', ''] );
has 'case'         => ( is  => 'rw', default => '',
                        isa => enum ['nom', 'gen', 'dat', 'acc', 'voc', 'loc', 'ins', 'ist',
                                     'abl', 'del', 'par', 'dis', 'ess', 'tra', 'com', 'abe', 'ine', 'ela', 'ill', 'ade', 'all', 'sub', 'sup', 'lat',
                                     'add', 'tem', 'ter', 'abs', 'erg', 'cau', 'ben', ''] );
has 'prepcase'     => ( is  => 'rw', default => '',
                        isa => enum ['npr', 'pre', ''] );
has 'degree'       => ( is  => 'rw', default => '',
                        isa => enum ['pos', 'comp', 'sup', 'abs', ''] );
has 'person'       => ( is  => 'rw', default => '',
                        isa => enum ['1', '2', '3', ''] );
has 'politeness'   => ( is  => 'rw', default => '',
                        isa => enum ['inf', 'pol', ''] );
has 'possgender'   => ( is  => 'rw', default => '',
                        isa => enum ['masc', 'fem', 'com', 'neut', ''] );
has 'possperson'   => ( is  => 'rw', default => '',
                        isa => enum ['1', '2', '3', ''] );
has 'possnumber'   => ( is  => 'rw', default => '',
                        isa => enum ['sing', 'dual', 'plu', ''] );
has 'possednumber' => ( is  => 'rw', default => '',
                        isa => enum ['sing', 'dual', 'plu', ''] );
has 'subcat'       => ( is  => 'rw', default => '',
                        isa => enum ['intr', 'tran', ''] );
has 'verbform'     => ( is  => 'rw', default => '',
                        isa => enum ['fin', 'inf', 'sup', 'part', 'trans', 'ger', ''] ); ###!!! Combine this feature with mood? Mood always implies verbform=fin.
has 'mood'         => ( is  => 'rw', default => '',
                        isa => enum ['ind', 'imp', 'cnd', 'pot', 'sub', 'jus', 'qot', ''] );
has 'tense'        => ( is  => 'rw', default => '',
                        isa => enum ['past', 'pres', 'fut', ''] );
has 'subtense'     => ( is  => 'rw', default => '',
                        isa => enum ['aor', 'imp', 'pqp', ''] ); ###!!! Combine this feature with tense? There are other hierarchical features anyway (case, number...)
has 'voice'        => ( is  => 'rw', default => '',
                        isa => enum ['act', 'pass', ''] );
has 'aspect'       => ( is  => 'rw', default => '',
                        isa => enum ['imp', 'perf', 'pro', ''] );
has 'variant'      => ( is  => 'rw', default => '',
                        isa => enum ['short', 'long', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ''] );
has 'style'        => ( is  => 'rw', default => '',
                        isa => enum ['arch', 'form', 'norm', 'coll', 'vrnc', 'slng', 'derg', 'vulg', ''] );
has 'tagset'       => ( is  => 'rw', default => '',
                        isa => subtype as 'Str', where { m/^([a-z]+::[a-z]+)?$/ }, message { "'$_' does not look like a tagset identifier ('lang::corpus')." } );
has 'other'        => ( is  => 'rw', default => '' );



#---------------------------------------------------------------------------------
# Create a hash of ordering values to assist sorting feature values "intuitively".
# For example, singular is intuitively before but alphabetically after plural.
# Intuitive sorting will be useful when displaying a list of values.
#---------------------------------------------------------------------------------
my %order_values;
BUILD
{
    # Taken from DZ Interset 1: The intuitive ordering is defined by the array of
    # known values. This is a bad solution because we have to maintain the list of
    # values in at least two places: here and in the Moose enums above.
    my %known_values =
    (
        "pos"          => ["noun", "adj", "num", "verb", "adv", "prep", "conj", "part", "int", "punc"],
        "subpos"       => ["prop", "class", "pdt", "det", "art",
                           "aux", "cop", "mod", "verbconj", "mod", "ex", "voc", "post", "circ", "preppron", "comprep",
                           "coor", "sub", "comp", "emp", "res", "inf", "vbp"],
        "prontype"     => ["prs", "rcp", "int", "rel", "dem", "neg", "ind", "tot"],
        "numtype"      => ["card", "ord", "mult", "frac", "gen", "dist"],
        "numform"      => ["word", "digit", "roman"],
        "numvalue"     => ["1", "2", "3"],
        "advtype"      => ["man", "loc", "tim", "deg", "cau"],
        "punctype"     => ["peri", "qest", "excl", "quot", "brck", "comm", "colo", "semi", "dash", "symb", "root"],
        "puncside"     => ["ini", "fin"],
        "synpos"       => ["subst", "attr", "adv", "pred"],
        "poss"         => ["poss"],
        "reflex"       => ["reflex"],
        "negativeness" => ["pos", "neg"],
        "definiteness" => ["ind", "def", "red", "com"],
        "gender"       => ["masc", "fem", "com", "neut"],
        "animateness"  => ["anim", "nhum", "inan"],
        "number"       => ["sing", "dual", "plu", "ptan", "coll"],
        "case"         => ["nom", "gen", "dat", "acc", "voc", "loc", "ins", "ist",
                           "abl", "del", "par", "dis", "ess", "tra", "com", "abe", "ine", "ela", "ill", "ade", "all", "sub", "sup", "lat",
                           "add", "tem", "ter", "abs", "erg", "cau", "ben"],
        "prepcase"     => ["npr", "pre"],
        "degree"       => ["pos", "comp", "sup", "abs"],
        "person"       => [1, 2, 3],
        "politeness"   => ["inf", "pol"],
        "possgender"   => ["masc", "fem", "com", "neut"],
        "possperson"   => [1, 2, 3],
        "possnumber"   => ["sing", "dual", "plu"],
        "possednumber" => ["sing", "dual", "plu"],
        "subcat"       => ["intr", "tran"],
        "verbform"     => ["fin", "inf", "sup", "part", "trans", "ger"],
        "mood"         => ["ind", "imp", "cnd", "pot", "sub", "jus", "qot"],
        "tense"        => ["past", "pres", "fut"],
        "subtense"     => ["aor", "imp", "pqp"],
        "aspect"       => ["imp", "perf", "pro"],
        "voice"        => ["act", "pass"],
        "foreign"      => ["foreign"],
        "abbr"         => ["abbr"],
        "hyph"         => ["hyph"],
        "echo"         => ["rdp", "ech"],
        "style"        => ["arch", "form", "norm", "coll", "vrnc", "slng", "derg", "vulg"],
        "typo"         => ["typo"],
        "variant"      => ["short", "long", 0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "tagset"       => [""],
        "other"        => [""],
    );
    for(my $i = 0; $i<=$#known_features; $i++)
    {
        my $feature = $known_features[$i];
        $order_values{$feature}{''} = ($i+1)*1000;
        my @values = @{$known_values{$feature}};
        for(my $j = 0; $j<=$#values; $j++)
        {
            my $value = $values[$j];
            $order_values{$feature}{$value} = ($i+1)*1000+($j+1);
        }
    }
}



1;

=over

=item Lingua::Interset::FeatureStructure

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

The C<FeatureStructure> class defines all morphosyntactic features and their values used
in DZ Interset.

=back

=cut

# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# This file is distributed under the GNU General Public License v3. See doc/COPYING.txt.
