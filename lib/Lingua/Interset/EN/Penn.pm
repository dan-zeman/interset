#!/usr/bin/env perl
# Driver for the tagset of the Penn Treebank.
# Copyright © 2006, 2009, 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL
# 25.3.2009: added new tags HYPH, AFX from PennBioIE, 2005 (HYPH appears in the CoNLL 2009 data)
# 25.3.2009: new tag NIL appears in CoNLL 2009 English data for tokens &, $, %
# 6.6.2014: moved to the new object-oriented Interset

package Lingua::Interset::EN::Penn;
use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use Lingua::Interset::FeatureStructure;
use Lingua::Interset::Trie;
our $VERSION; BEGIN { $VERSION = "2.00" }
extends 'Lingua::Interset::Tagset';



my %postable =
(
    # sentence-final punctuation
    # examples: . ! ?
    '.'     => ['pos' => 'punc', 'punctype' => 'peri'],
    # comma
    # example: ,
    ','     => ['pos' => 'punc', 'punctype' => 'comm'],
    # left bracket
    # example: -LRB- -LCB- [ {
    '-LRB-' => ['pos' => 'punc', 'punctype' => 'brck', 'puncside' => 'ini'],
    # right bracket
    # example: -RRB- -RCB- ] }
    '-RRB-' => ['pos' => 'punc', 'punctype' => 'brck', 'puncside' => 'fin'],
    # left quotation mark
    # example: ``
    '``'    => ['pos' => 'punc', 'punctype' => 'quot', 'puncside' => 'ini'],
    # right quotation mark
    # example: ''
    "''"    => ['pos' => 'punc', 'punctype' => 'quot', 'puncside' => 'fin'],
    # generic other punctuation
    # examples: : ; ...
    ':'     => ['pos' => 'punc'],
    # currency
    # example: $ US$ C$ A$ NZ$
    '$'     => ['pos' => 'punc', 'punctype' => 'symb', 'other' => 'currency'],
    # channel
    # example: #
    '\#'    => ['pos' => 'punc', 'other' => '\#'],
    # "common postmodifiers of biomedical entities such as genes" (Blitzer, MdDonald, Pereira, Proc of EMNLP 2006, Sydney)
    # Example 1: "anti-CYP2E1-IgG" is tokenized and tagged as "anti/AFX -/HYPH CYP2E1-IgG/NN".
    # Example 2: "mono- and diglycerides" is tokenized and tagged as "mono/AFX -/HYPH and/CC di/AFX glycerides/NNS".
    'AFX'   => ['pos' => 'adj',  'hyph' => 'hyph'],
    # coordinating conjunction
    # examples: and, or
    'CC'    => ['pos' => 'conj', 'conjtype' => 'coor'],
    # cardinal number
    # examples: one, two, three
    'CD'    => ['pos' => 'num', 'numtype' => 'card', 'synpos' => 'attr', 'definiteness' => 'def'],
    # determiner
    # examples: a, the, some
    'DT'    => ['pos' => 'adj', 'adjtype' => 'det', 'synpos' => 'attr'],
    # existential there
    # examples: there
    'EX'    => ['pos' => 'adv', 'subpos' => 'ex'],
    # foreign word
    # examples: kašpárek
    'FW'    => ['foreign' => 'foreign'],
    # This tag is new in PennBioIE. In older data hyphens are tagged ":".
    # hyphen
    # example: -
    'HYPH'  => ['pos' => 'punc', 'punctype' => 'dash'],
    # preposition or subordinating conjunction
    # examples: in, on, because
    # We could create array of "prep" and "conj/sub" but arrays generally complicate things and the benefit is uncertain.
    'IN'    => ['pos' => 'prep'],
    # adjective
    # examples: good
    'JJ'    => ['pos' => 'adj', 'degree' => 'pos'],
    # adjective, comparative
    # examples: better
    'JJR'   => ['pos' => 'adj', 'degree' => 'comp'],
    # adjective, superlative
    # examples: best
    'JJS'   => ['pos' => 'adj', 'degree' => 'sup'],
    # list item marker
    # examples: 1., a), *
    'LS'    => ['pos' => 'punc', 'numtype' => 'ord'],
    # modal
    # examples: can, must
    'MD'    => ['pos' => 'verb', 'verbtype' => 'mod'],
    'NIL'   => [],
    # noun, singular or mass
    # examples: animal
    'NN'    => ['pos' => 'noun', 'number' => 'sing'],
    # proper noun, singular
    # examples: America
    'NNP'   => ['pos' => 'noun', 'nountype' => 'prop', 'number' => 'sing'],
    # proper noun, plural
    # examples: Americas
    'NNPS'  => ['pos' => 'noun', 'nountype' => 'prop', 'number' => 'plu'],
    # noun, plural
    # examples: animals
    'NNS'   => ['pos' => 'noun', 'number' => 'plu'],
    # predeterminer
    # examples: "all" in "all the flowers" or "both" in "both his children"
    'PDT'   => ['pos' => 'adj', 'adjtype' => 'pdt'],
    # possessive ending
    # examples: 's
    'POS'   => ['pos' => 'part', 'poss' => 'poss'],
    # personal pronoun
    # examples: I, you, he, she, it, we, they
    'PRP'   => ['pos' => 'noun', 'prontype' => 'prs', 'synpos' => 'subst'],
    # possessive pronoun
    # examples: my, your, his, her, its, our, their
    'PRP$'  => ['pos' => 'adj', 'prontype' => 'prs', 'poss' => 'poss', 'synpos' => 'attr'],
    # adverb
    # examples: here, tomorrow, easily
    'RB'    => ['pos' => 'adv'],
    # adverb, comparative
    # examples: more, less
    'RBR'   => ['pos' => 'adv', 'degree' => 'comp'],
    # adverb, superlative
    # examples: most, least
    'RBS'   => ['pos' => 'adv', 'degree' => 'sup'],
    # particle
    # examples: up, on
    'RP'    => ['pos' => 'part'],
    # symbol
    # Penn Treebank definition (Santorini 1990):
    # This tag should be used for mathematical, scientific and technical symbols
    # or expressions that aren't words of English. It should not be used for any
    # and all technical expressions. For instance, the names of chemicals, units
    # of measurements (including abbreviations thereof) and the like should be
    # tagged as nouns.
    'SYM'   => ['pos' => 'punc', 'punctype' => 'symb'],
    # to
    # examples: to
    # Both the infinitival marker "to" and the preposition "to" get this tag.
    'TO'    => ['pos' => 'part', 'subpos' => 'inf', 'verbform' => 'inf'],
    # interjection
    # examples: uh
    'UH'    => ['pos' => 'int'],
    # verb, base form
    # examples: do, go, see, walk
    'VB'    => ['pos' => 'verb', 'verbform' => 'inf'],
    # verb, past tense
    # examples: did, went, saw, walked
    'VBD'   => ['pos' => 'verb', 'verbform' => 'fin', 'tense' => 'past'],
    # verb, gerund or present participle
    # examples: doing, going, seeing, walking
    'VBG'   => ['pos' => 'verb', 'verbform' => 'part', 'tense' => 'pres', 'aspect' => 'imp'], ###!!! now there is also aspect "pro", we should set it here
    # verb, past participle
    # examples: done, gone, seen, walked
    'VBN'   => ['pos' => 'verb', 'verbform' => 'part', 'tense' => 'past', 'aspect' => 'perf'],
    # verb, non-3rd person singular present
    # examples: do, go, see, walk
    'VBP'   => ['pos' => 'verb', 'verbform' => 'fin', 'tense' => 'pres', 'number' => 'sing', 'person' => [1, 2]],
    # verb, 3rd person singular present
    # examples: does, goes, sees, walks
    'VBZ'   => ['pos' => 'verb', 'verbform' => 'fin', 'tense' => 'pres', 'number' => 'sing', 'person' => 3],
    # wh-determiner
    # examples: which
    'WDT'   => ['pos' => 'adj', 'adjtype' => 'det', 'synpos' => 'attr', 'prontype' => 'int'],
    # wh-pronoun
    # examples: who
    'WP'    => ['pos' => 'noun', 'synpos' => 'subst', 'prontype' => 'int'],
    # possessive wh-pronoun
    # examples: whose
    'WP$'   => ['pos' => 'adj', 'poss' => 'poss', 'synpos' => 'attr', 'prontype' => 'int'],
    # wh-adverb
    # examples: where, when, how
    'WRB'   => ['pos' => 'adv', 'prontype' => 'int'],
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
    $fs->tagset('en::penn');
    my $assignments = $postable{$tag};
    if($assignments)
    {
        $fs->multiset(@{$assignments});
    }
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $tag = '';
    my $pos = $fs->pos();
    my $prontype = $fs->prontype();
    # Foreign words without respect to part of speech.
    if($fs->foreign())
    {
        $tag = 'FW';
    }
    # Separated affixes.
    elsif($fs->hyph())
    {
        $tag = 'AFX';
    }
    # Pronouns, determiners and pronominal adverbs.
    elsif($prontype =~ m/^(rel|int)$/)
    {
        # WDT WP WP$ WRB
        if($pos eq 'adv')
        {
            $tag = 'WRB';
        }
        elsif($fs->poss())
        {
            $tag = 'WP$';
        }
        elsif($pos eq 'adj')
        {
            $tag = 'WDT';
        }
        else
        {
            $tag = 'WP';
        }
    }
    elsif($prontype ne '')
    {
        # PRP PRP$
        if($fs->poss())
        {
            $tag = 'PRP$';
        }
        else
        {
            $tag = 'PRP';
        }
    }
    elsif($pos eq 'noun')
    {
        # NN NNS NNP NNPS
        if($fs->nountype() eq 'prop')
        {
            if($fs->number() eq 'plu')
            {
                $tag = 'NNPS';
            }
            else
            {
                $tag = 'NNP';
            }
        }
        else
        {
            if($fs->number() eq 'plu')
            {
                $tag = 'NNS';
            }
            else
            {
                $tag = 'NN';
            }
        }
    }
    elsif($pos eq 'adj')
    {
        # DT PDT JJ JJR JJS
        if($pos eq 'adj')
        {
            if($fs->adjtype() eq 'det')
            {
                $tag = 'DT';
            }
            elsif($fs->adjtype() eq 'pdt')
            {
                $tag = 'PDT';
            }
            elsif($fs->degree() eq 'sup')
            {
                $tag = 'JJS';
            }
            elsif($fs->degree() eq 'comp')
            {
                $tag = 'JJR';
            }
            else
            {
                $tag = 'JJ';
            }
        }
    }
    elsif($pos eq 'num')
    {
        # CD; ordinal numbers are adjectives JJ
        if($fs->numtype() eq 'card')
        {
            $tag = 'CD';
        }
        else
        {
            ###!!! multiplicative and some ordinal numerals behave more like adverbs; see the synpos?
            $tag = 'JJ';
        }
    }
    elsif($pos eq 'verb')
    {
        # MD VB VBD VBG VBN VBP VBZ
        if($fs->verbtype() eq 'mod')
        {
            $tag = 'MD';
        }
        elsif($fs->verbform() eq 'part')
        {
            if($fs->tense() eq 'pres' || $fs->aspect() =~ m/^(imp|pro)$/)
            {
                $tag = 'VBG';
            }
            else
            {
                $tag = 'VBN';
            }
        }
        elsif($fs->tense() eq 'past')
        {
            $tag = 'VBD';
        }
        elsif($fs->tense() eq 'pres' && $fs->number() eq 'sing')
        {
            if($fs->person() == 3)
            {
                $tag = 'VBZ';
            }
            else
            {
                $tag = 'VBP';
            }
        }
        else
        {
            $tag = 'VB';
        }
    }
    elsif($pos eq 'adv')
    {
        # EX RB RBR RBS
        if($fs->subpos() eq 'ex')
        {
            $tag = 'EX';
        }
        elsif($fs->degree() eq 'sup')
        {
            $tag = 'RBS';
        }
        elsif($fs->degree() eq 'comp')
        {
            $tag = 'RBR';
        }
        else
        {
            $tag = 'RB';
        }
    }
    elsif($pos eq 'prep')
    {
        # IN (TO)
        $tag = 'IN';
    }
    elsif($pos eq 'conj')
    {
        # CC (IN)
        if($fs->conjtype() eq 'sub')
        {
            $tag = 'IN';
        }
        else
        {
            $tag = 'CC';
        }
    }
    elsif($pos eq 'part')
    {
        # RP TO POS
        if($fs->poss())
        {
            $tag = 'POS';
        }
        elsif($fs->verbform() eq 'inf' || $fs->subpos() eq 'inf')
        {
            $tag = 'TO';
        }
        else
        {
            $tag = 'RP';
        }
    }
    elsif($pos eq 'int')
    {
        $tag = 'UH';
    }
    elsif($fs->tagset() eq 'en::penn' && $fs->other() eq 'currency')
    {
        $tag = '$';
    }
    elsif($pos eq 'punc')
    {
        # LS # . , -LRB- -RRB- `` '' HYPH SYM :
        if($fs->numtype() eq 'ord')
        {
            $tag = 'LS';
        }
        elsif($fs->tagset() eq 'en::penn' && $fs->other() eq "\#")
        {
            $tag = "\#";
        }
        elsif($fs->punctype() =~ m/^(peri|qest|excl)$/)
        {
            $tag = '.';
        }
        elsif($fs->punctype() eq 'comm')
        {
            $tag = ',';
        }
        elsif($fs->punctype() eq 'brck')
        {
            if($fs->puncside() eq 'fin')
            {
                $tag = '-RRB-';
            }
            else
            {
                $tag = '-LRB-';
            }
        }
        elsif($fs->punctype() eq 'quot')
        {
            if($fs->puncside() eq 'fin')
            {
                $tag = "''";
            }
            else
            {
                $tag = "``";
            }
        }
        elsif($fs->punctype() eq 'dash')
        {
            # This tag is new in PennBioIE. In older data hyphens are tagged ":".
            $tag = 'HYPH';
        }
        else
        {
            $tag = ':';
        }
    }
    # punctuation and unknown elements
    else
    {
        $tag = 'NIL';
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# 25.3.2009: added new tags HYPH, AFX from PennBioIE, 2005 (HYPH appears in the CoNLL 2009 data)
#
# cd /net/data/LDC/PennTreebank3/parsed/mrg/wsj
# foreach i (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24)
#   cat $i/*.mrg >> /tmp/all.mrg
# end
# cat /tmp/all.mrg | perl -pe 's/\(([-\w]+)\s+[^\(\)]+\)/ $1 /g; s/\([-\w\*]+//g; s/[\(\)]/ /g; s/^\s+//; s/\s+$/\n/; s/\s+/\n/g;' | sort -u | wc -l
# rm /tmp/all.mrg
# 43
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my @list = sort(keys(%postable));
    return \@list;
}



1;

=over

=item Lingua::Interset::EN::Penn

Interset driver for the part-of-speech tagset of the Penn Treebank.

=back

=cut

# Copyright © 2006, 2009, 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# This file is distributed under the GNU General Public License v3. See doc/COPYING.txt.
