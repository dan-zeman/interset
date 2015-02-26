# ABSTRACT: Driver for the Chinese tagset of the CoNLL 2006 & 2007 Shared Tasks (derived from the Academia Sinica Treebank).
# Documentation in Huang, Chen, Lin: Corpus on Web: Introducing the First Tagged and Balanced Chinese Corpus.
# Copyright © 2007, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::ZH::Conll;
use strict;
use warnings;
our $VERSION = '2.041';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset::Conll';



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'zh::conll';
}



#------------------------------------------------------------------------------
# Creates atomic drivers for surface features.
#------------------------------------------------------------------------------
sub _create_atoms
{
    my $self = shift;
    my %atoms;
    # PART OF SPEECH ####################
    $atoms{pos} = $self->create_atom
    (
        'surfeature' => 'pos',
        'decode_map' =>
        {
            # noun or pronoun
            'Na' => ['pos' => 'noun', 'nountype' => 'com'],
            'Nb' => ['pos' => 'noun', 'nountype' => 'prop'],
            # location noun (including some proper nouns, e.g. Feizhou = Africa)
            'Nc' => ['pos' => 'noun', 'advtype' => 'loc'],
            # time noun
            'Nd' => ['pos' => 'noun', 'advtype' => 'tim'],
            # classifier (measure word)
            'Nf' => ['pos' => 'noun', 'nountype' => 'class'],
            # pronoun
            'Nh' => ['pos' => 'noun', 'prontype' => 'prn'],
            ###!!! ???
            'Nv' => ['pos' => 'noun', 'other' => {'subpos' => 'Nv'}],
            # A A adjective
            # Examples: 主要 = main, 一般 = general, 共同 = common, 最佳 = optimal, 唯一 = the only
            'A'  => ['pos' => 'adj'],
            # determiner
            # anaphoric determiner (this, that)
            'Nep' => ['pos' => 'adj', 'prontype' => 'dem'],
            # classifying determiner (much, half)
            'Neq' => ['pos' => 'adj', 'prontype' => 'prn'],
            # specific determiner (you, shang, ge = every)
            'Nes' => ['pos' => 'adj', 'prontype' => 'prn'],
            # numeric determiner (one, two, three)
            'Neu' => ['pos' => 'num', 'numtype' => 'card'],
            # verb
            'V'   => ['pos' => 'verb'],
            # adverb
            # D Daa: 只 = only, 約 = approximately, 才 = only, 共 = altogether, 僅 = only
            # D Dab: 都 = all, 所, 均 = all, 皆 = all, 完全 = entirely
            # D Dbaa: 是 = is, 會 = can/will, 可能 = maybe, 不會 = will not, 一定 = for sure
            # D Dbab: 要 = want, 能 = can, 可以 = can, 可 = can, 來 = come
            # D Dbb: 也 = also, 還 = also, 則 = then, 卻 = yet, 並 = and
            # D Dbc: 看起來 = looks, 看來 = seems, 說起來 = speaks, 聽起來 = sounds, 吃起來 = tastes
            # D Dc: 不 = not, 未 = not, 沒有 = there is no, 沒 = not, 非 = non-
            # D Dd: 就 = then, 又 = again, 已 = already, 將 = will, 才 = only
            # D Dfa: 很 = very, 最 = most, 更 = more, 較 = relatively, 非常 = very much
            # D Dfb: 一點 = a little, 極了 = extremely, 些 = some, 得很 = very, 多 = more
            # D Dg: 一路 = all the way, 到處 = everywhere, 四處 = around, 處處 = everywhere, 當場 = on the spot
            # D Dh: 如何 = how, 一起 = together, 更 = more, 分別 = respectively, 這麼 = so
            # D Dj: 為什麼 = why, 是否 = whether, 怎麼 = how, 為何 = why, 有沒有 = is there?
            # D Dk: 結果 = result, 那 = then, 據說 = reportedly, 據了解 = it is understood that, 那麼 = then
            'Daa'  => ['pos' => 'adv'],
            'Dab'  => ['pos' => 'adv', 'other' => {'subpos' => 'ab'}],
            'Dbaa' => ['pos' => 'adv', 'other' => {'subpos' => 'baa'}],
            'Dbab' => ['pos' => 'adv', 'other' => {'subpos' => 'bab'}],
            'Dbb'  => ['pos' => 'adv', 'other' => {'subpos' => 'bb'}],
            'Dbc'  => ['pos' => 'adv', 'other' => {'subpos' => 'bc'}],
            'Dc'   => ['pos' => 'adv', 'negativeness' => 'neg'],
            'Dd'   => ['pos' => 'adv', 'other' => {'subpos' => 'd'}],
            'Dfa'  => ['pos' => 'adv', 'other' => {'subpos' => 'fa'}],
            'Dfb'  => ['pos' => 'adv', 'other' => {'subpos' => 'fb'}],
            'Dg'   => ['pos' => 'adv', 'other' => {'subpos' => 'g'}],
            'Dh'   => ['pos' => 'adv', 'other' => {'subpos' => 'h'}],
            'Dj'   => ['pos' => 'adv', 'prontype' => 'int'],
            'Dk'   => ['pos' => 'adv', 'other' => {'subpos' => 'k'}],
            # measure word, quantifier
            # DM DM: 一個 yīgè = a, 這個 zhège = this one, 這種 zhèzhǒng = this kind, 個 gè, 一種 yīzhǒng = one kind
            ###!!! There ought to be a better solution!
            'DM'  => ['pos' => 'adj', 'nountype' => 'class'],
            # postposition (qian = before)
            'Ng'  => ['pos' => 'adp', 'adpostype' => 'post'],
            # preposition (66 kinds, 66 different tags)
            'P'   => ['pos' => 'adp', 'adpostype' => 'prep'],
            # conjunction
            # C Caa: 、, 和 = and, 及 = and, 與 = versus, 或 = or
            # C Caa[P1]: 從 = from, 又 = again, 既 = already, 由 = from, 或 = or
            # C Caa[P2]: 又 = again, 到 = to, 至 = to, 或 = or, 也 = also
            # C Cab: 等 = etc., 等等 = and so on, 之類 = the class, 什麼的 = something, 、
            # C Cbaa: 因為 = because, 如果 = in case, 因 = because, 雖然 = though, 若 = if
            # C Cbab: 的話 = if, 應該 = should, 而 = while, 能 = can/able, 並 = and
            # C Cbba: 由於 = due to, 雖 = although, 連 = even though, 既然 = since, 就是 = that
            # C Cbbb: 不但 = not only, 不僅 = not only, 一方面 = on the one hand, 首先 = first of all, 二 = two
            # C Cbca: 而 = and, 但 = but, 因此 = as such, 所以 = and so, 但是 = but
            # C Cbcb: 並 = and, 而且 = and, 且 = and, 並且 = and, 反而 = instead
            'Caa'  => ['pos' => 'conj', 'conjtype' => 'coor'],
            'Cab'  => ['pos' => 'conj', 'conjtype' => 'coor', 'other' => {'subpos' => 'ab'}],
            'Cbaa' => ['pos' => 'conj', 'conjtype' => 'sub'],
            'Cbab' => ['pos' => 'conj', 'conjtype' => 'sub', 'other' => {'subpos' => 'bab'}],
            'Cbba' => ['pos' => 'conj', 'conjtype' => 'sub', 'other' => {'subpos' => 'bba'}],
            'Cbbb' => ['pos' => 'conj', 'conjtype' => 'sub', 'other' => {'subpos' => 'bbb'}],
            'Cbca' => ['pos' => 'conj', 'conjtype' => 'coor', 'other' => {'subpos' => 'bca'}],
            'Cbcb' => ['pos' => 'conj', 'conjtype' => 'coor', 'other' => {'subpos' => 'bcb'}],
            # the "de" particle (two kinds)
            # DE DE: 的 de = of, 之 zhī = of, 得 dé = get, 地 de = ground/land/earth (tagging error?)
            # DE Di: 了 le, 著 zhe, 過 guò, 起來 qǐlái, 起 qǐ
            'DE'   => ['pos' => 'part', 'case' => 'gen'],
            'Di'   => ['pos' => 'part', 'case' => 'gen', 'other' => {'subpos' => 'Di'}],
            # particle
            'T'   => ['pos' => 'part'],
            # interjection
            'I'   => ['pos' => 'int']
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => 'Na',
                       'adj'  => { 'nountype' => { 'class' => 'DM',
                                                   '@'     => 'A' }},
                       'num'  => 'Neu',
                       'verb' => 'V',
                       'adv'  => { 'prontype' => { 'int' => 'Dj',
                                                   '@'   => { 'negativeness' => { 'neg' => 'Dc',
                                                                                  '@'   => { 'other/subpos' => { 'ab'  => 'Dab',
                                                                                                                 'baa' => 'Dbaa',
                                                                                                                 'bab' => 'Dbab',
                                                                                                                 'bb'  => 'Dbb',
                                                                                                                 'bc'  => 'Dbc',
                                                                                                                 'd'   => 'Dd',
                                                                                                                 'fa'  => 'Dfa',
                                                                                                                 'fb'  => 'Dfb',
                                                                                                                 'g'   => 'Dg',
                                                                                                                 'h'   => 'Dh',
                                                                                                                 'k'   => 'Dk',
                                                                                                                 '@'   => 'Daa' }}}}}},
                       'adp'  => { 'adpostype' => { 'prep' => 'P',
                                                    'post' => 'Ng' }},
                       'conj' => { 'conjtype' => { 'coor' => { 'other/subpos' => { 'ab'  => 'Cab',
                                                                                   'bca' => 'Cbca',
                                                                                   'bcb' => 'Cbcb',
                                                                                   '@'   => 'Caa' }},
                                                   'sub'  => { 'other/subpos' => { 'bab' => 'Cbab',
                                                                                   'bba' => 'Cbba',
                                                                                   'bbb' => 'Cbbb',
                                                                                   '@'   => 'Cbaa' }}}},
                       'part' => { 'case' => { 'gen' => { 'other/subpos' => { 'Di' => 'Di',
                                                                              '@'  => 'DE' }},
                                               '@'   => 'T' }},
                       'int'  => 'I' }
        }
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Creates the list of all surface CoNLL features that can appear in the FEATS
# column. This list will be used in decode().
#------------------------------------------------------------------------------
sub _create_features_all
{
    my $self = shift;
    my @features = ();
    return \@features;
}



#------------------------------------------------------------------------------
# Creates the list of surface CoNLL features that can appear in the FEATS
# column with particular parts of speech. This list will be used in encode().
#------------------------------------------------------------------------------
sub _create_features_pos
{
    my $self = shift;
    my %features =
    (
    );
    return \%features;
}



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    my $fs = Lingua::Interset::FeatureStructure->new();
    $fs->set_tagset('zh::conll');
    my $atoms = $self->atoms();
    # Three components: pos, subpos, features (always empty).
    # example: N\tNaa\t_
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    ###!!! We cannot currently decode the tag extensions in brackets, e.g. "[P1]" in "Caa[P1]".
    ###!!! In future we will want to create an atom to take care of them. For the moment, just a quick hack:
    $subpos =~ s/(\[.*?\])//;
    my $bracket = $1;
    if(defined($bracket))
    {
        $fs->set_other_subfeature('bracket', $bracket);
    }
    $atoms->{pos}->decode_and_merge_hard($subpos, $fs);
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $atoms = $self->atoms();
    my $subpos = $atoms->{pos}->encode($fs);
    my $pos = $subpos =~ m/^(DE|Di)$/ ? 'DE' : $subpos eq 'DM' ? 'DM' : substr($subpos, 0, 1);
    ###!!! We cannot currently decode the tag extensions in brackets, e.g. "[P1]" in "Caa[P1]".
    ###!!! In future we will want to create an atom to take care of them. For the moment, just a quick hack:
    my $bracket = $fs->get_other_subfeature('zh::conll', 'bracket');
    if($bracket ne '')
    {
        $subpos .= $bracket;
    }
    my $tag = "$pos\t$subpos\t_";
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# Tags were collected from the corpus, 294 distinct tags found.
# Cleaned up erroneous instances (e.g. with "[P2}" instead of "[P2]").
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
A\tA\t_
C\tCaa\t_
C\tCaa[P1]\t_
C\tCaa[P2]\t_
C\tCab\t_
C\tCbaa\t_
C\tCbab\t_
C\tCbba\t_
C\tCbbb\t_
C\tCbca\t_
C\tCbcb\t_
D\tDaa\t_
D\tDab\t_
D\tDbaa\t_
D\tDbab\t_
D\tDbb\t_
D\tDbc\t_
D\tDc\t_
D\tDd\t_
D\tDfa\t_
D\tDfb\t_
D\tDg\t_
D\tDh\t_
D\tDj\t_
D\tDk\t_
DE\tDE\t_
DE\tDi\t_
DM\tDM\t_
I\tI\t_
Ne\tNep\t_
Ne\tNeqa\t_
Ne\tNeqb\t_
Ne\tNes\t_
Ne\tNeu\t_
Ng\tNg\t_
N\tNaa\t_
N\tNaa[+SPO]\t_
N\tNab\t_
N\tNab[+SPO]\t_
N\tNac\t_
N\tNac[+SPO]\t_
N\tNad\t_
N\tNad[+SPO]\t_
N\tNaea\t_
N\tNaeb\t_
N\tNba\t_
N\tNbc\t_
N\tNca\t_
N\tNcb\t_
N\tNcc\t_
N\tNcda\t_
N\tNcdb\t_
N\tNce\t_
N\tNdaaa\t_
N\tNdaab\t_
N\tNdaac\t_
N\tNdaad\t_
N\tNdaba\t_
N\tNdabb\t_
N\tNdabc\t_
N\tNdabd\t_
N\tNdabe\t_
N\tNdabf\t_
N\tNdbb\t_
N\tNdc\t_
N\tNdda\t_
N\tNddb\t_
N\tNddc\t_
N\tNfa\t_
N\tNfc\t_
N\tNfd\t_
N\tNfe\t_
N\tNfg\t_
N\tNfh\t_
N\tNfi\t_
N\tNhaa\t_
N\tNhab\t_
N\tNhac\t_
N\tNhb\t_
N\tNhc\t_
N\tNv1\t_
N\tNv2\t_
N\tNv3\t_
N\tNv4\t_
P\tP01\t_
P\tP02\t_
P\tP03\t_
P\tP04\t_
P\tP06\t_
P\tP06[P1]\t_
P\tP06[P2]\t_
P\tP06[+part]\t_
P\tP07\t_
P\tP08\t_
P\tP08[+part]\t_
P\tP09\t_
P\tP10\t_
P\tP11\t_
P\tP11[P1]\t_
P\tP11[P2]\t_
P\tP11[+part]\t_
P\tP12\t_
P\tP13\t_
P\tP14\t_
P\tP15\t_
P\tP16\t_
P\tP17\t_
P\tP18\t_
P\tP18[+part]\t_
P\tP19\t_
P\tP19[P1]\t_
P\tP19[P2]\t_
P\tP19[+part]\t_
P\tP20\t_
P\tP20[+part]\t_
P\tP21\t_
P\tP21[+part]\t_
P\tP22\t_
P\tP23\t_
P\tP24\t_
P\tP25\t_
P\tP26\t_
P\tP27\t_
P\tP28\t_
P\tP29\t_
P\tP30\t_
P\tP31\t_
P\tP31[P1]\t_
P\tP31[P2]\t_
P\tP31[+part]\t_
P\tP32\t_
P\tP32[+part]\t_
P\tP35\t_
P\tP35[+part]\t_
P\tP36\t_
P\tP37\t_
P\tP38\t_
P\tP39\t_
P\tP40\t_
P\tP41\t_
P\tP42\t_
P\tP42[+part]\t_
P\tP43\t_
P\tP44\t_
P\tP45\t_
P\tP46\t_
P\tP46[+part]\t_
P\tP47\t_
P\tP48\t_
P\tP48[+part]\t_
P\tP49\t_
P\tP50\t_
P\tP51\t_
P\tP52\t_
P\tP53\t_
P\tP54\t_
P\tP55\t_
P\tP55[+part]\t_
P\tP58\t_
P\tP59\t_
P\tP59[+part]\t_
P\tP60\t_
P\tP61\t_
P\tP62\t_
P\tP63\t_
P\tP64\t_
P\tP65\t_
P\tP66\t_
Str\tStr\t_
T\tTa\t_
T\tTb\t_
T\tTc\t_
T\tTd\t_
V\tV_11\t_
V\tV_12\t_
V\tV_2\t_
V\tVA\t_
V\tVA11\t_
V\tVA11[+ASP]\t_
V\tVA11[+NEG]\t_
V\tVA12\t_
V\tVA12[+NEG]\t_
V\tVA12[+SPV]\t_
V\tVA13\t_
V\tVA13[+ASP]\t_
V\tVA2\t_
V\tVA2[+ASP]\t_
V\tVA2[+SPV]\t_
V\tVA3\t_
V\tVA3[+ASP]\t_
V\tVA4\t_
V\tVA4[+ASP]\t_
V\tVA4[+NEG]\t_
V\tVA4[+NEG,+ASP]\t_
V\tVA4[+SPV]\t_
V\tVB11\t_
V\tVB11[+ASP]\t_
V\tVB11[+DE]\t_
V\tVB11[+NEG]\t_
V\tVB11[+SPV]\t_
V\tVB12\t_
V\tVB12[+ASP]\t_
V\tVB12[+NEG]\t_
V\tVB2\t_
V\tVB2[+ASP]\t_
V\tVB2[+NEG]\t_
V\tVC1\t_
V\tVC1[+NEG]\t_
V\tVC1[+SPV]\t_
V\tVC2\t_
V\tVC2[+ASP]\t_
V\tVC2[+DE]\t_
V\tVC2[+NEG]\t_
V\tVC2[+SPV]\t_
V\tVC31\t_
V\tVC31[+ASP]\t_
V\tVC31[+DE]\t_
V\tVC31[+DE,+ASP]\t_
V\tVC31[+NEG]\t_
V\tVC31[+SPV]\t_
V\tVC32\t_
V\tVC32[+DE]\t_
V\tVC32[+SPV]\t_
V\tVC33\t_
V\tVD1\t_
V\tVD2\t_
V\tVD2[+NEG]\t_
V\tVE11\t_
V\tVE12\t_
V\tVE2\t_
V\tVE2[+DE]\t_
V\tVE2[+NEG]\t_
V\tVE2[+SPV]\t_
V\tVF1\t_
V\tVF2\t_
V\tVG1\t_
V\tVG1[+NEG]\t_
V\tVG2\t_
V\tVG2[+DE]\t_
V\tVG2[+NEG]\t_
V\tVH11\t_
V\tVH11[+ASP]\t_
V\tVH11[+DE]\t_
V\tVH11[+NEG]\t_
V\tVH11[+SPV]\t_
V\tVH12\t_
V\tVH12[+ASP]\t_
V\tVH13\t_
V\tVH14\t_
V\tVH15\t_
V\tVH15[+NEG]\t_
V\tVH16\t_
V\tVH16[+ASP]\t_
V\tVH16[+NEG]\t_
V\tVH16[+SPV]\t_
V\tVH17\t_
V\tVH21\t_
V\tVH21[+ASP]\t_
V\tVH21[+Dbab]\t_
V\tVH21[+DE]\t_
V\tVH21[+NEG]\t_
V\tVH22\t_
V\tVI1\t_
V\tVI2\t_
V\tVI2[+ASP]\t_
V\tVI3\t_
V\tVJ1\t_
V\tVJ1[+DE]\t_
V\tVJ1[+NEG]\t_
V\tVJ2\t_
V\tVJ2[+NEG]\t_
V\tVJ2[+SPV]\t_
V\tVJ3\t_
V\tVJ3[+DE]\t_
V\tVJ3[+NEG]\t_
V\tVK1\t_
V\tVK1[+ASP]\t_
V\tVK1[+DE]\t_
V\tVK1[+NEG]\t_
V\tVK2\t_
V\tVK2[+NEG]\t_
V\tVL1\t_
V\tVL2\t_
V\tVL3\t_
V\tVL4\t_
V\tVP\t_
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::ZH::Conll;
  my $driver = Lingua::Interset::Tagset::ZH::Conll->new();
  my $fs = $driver->decode("N\tNaa\t_");

or

  use Lingua::Interset qw(decode);
  my $fs = decode('zh::conll', "N\tNaa\t_");

=head1 DESCRIPTION

Interset driver for the Chinese tagset of the CoNLL 2006 and 2007 Shared Tasks.
CoNLL tagsets in Interset are traditionally three values separated by tabs.
The values come from the CoNLL columns CPOS, POS and FEAT. For Chinese,
these values are derived from the tagset of the Academia Sinica Treebank
and the FEAT column is always empty.

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::Conll>,
L<Lingua::Interset::FeatureStructure>

=cut
