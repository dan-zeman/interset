package tagset::no::conll;

use strict;
use warnings;
use utf8;
use v5.12;

use List::MoreUtils qw/zip/;

use tagset::common;

my %pos_map = (
    adj                => 'adj',
    adv                => 'adv',
    '<anf>'            => 'punc',
    clb                => 'punc',
    det                => 'adj',
    'inf-merke'        => 'conj',
    interj             => 'int',
    '<komma>'          => 'punc',
    konj               => 'conj',
    '<parentes-beg>'   => 'punc',
    '<parentes-slutt>' => 'punc',
    prep               => 'prep',
    'prep+subst'       => '???', # 'i_tilfelle'. Probably corpus bug.
    pron               => 'noun',
    sbu                => 'conj',
    '<strek>'          => 'punc',
    subst              => 'noun',
    symb               => 'punc',
    ukjent             => '???',
    verb               => 'verb',
);

my %feat_map = (
    1                     => [qw/person 1/],
    2                     => [qw/person 2/],
    3                     => [qw/person 3/],

    akk                   => [qw/case acc/],
    nom                   => [qw/case nom/],
    gen                   => [qw/case gen/],

    be                    => [qw/definiteness def/],
    ub                    => [qw/definiteness ind/],

    pos                   => [qw/degree pos/],
    komp                  => [qw/degree comp/],
    sup                   => [qw/degree sup/],

    mask                  => [qw/gender masc/],
    fem                   => [qw/gender fem/],
    nøyt                  => [qw/gender neut/],
    n                     => [qw/gender neut/], # XXX: Corpus bug?
    'm/f'                 => [gender => [qw/masc fem/]],
    #ubøy                  => [qw/field value/], # TODO: Indeclinable nouns

    ent                   => [qw/number sing/],
    fl                    => [qw/number plu/],

    prop                  => [qw/subpos prop/],

    poss                  => [qw/poss poss/],

    refl                  => [qw/reflex reflex/],
    hum                   => [qw/animateness anim/], # XXX: Not strictly animate
    pers                  => [qw/prontype prs/],
    høflig                => [qw/politeness pol/],
    sp                    => [qw/prontype int/],
    res                   => [qw/prontype rcp/],

    pres                  => [qw/tense pres/],
    pret                  => [qw/tense past/],
    'perf-part'           => [qw/tense past/],
    imp                   => [qw/mood imp/],
    pass                  => [qw/voice pass/],
    inf                   => [qw/verbform inf/],

    unorm                 => [qw/typo typo/],
    fork                  => [qw/abbr abbr/],

    '<anf>'               => [qw/punctype quot/],
    '<kolon>'             => [qw/punctype colo/],
    '<komma>'             => [qw/punctype comm/],
    '<ellipse>'           => [qw/punctype symb/], # XXX: No own type for ellipsis.
    '<punkt>'             => [qw/punctype peri/],
    '<semi>'              => [qw/punctype semi/],
    '<spm>'               => [qw/punctype qest/],
    '<utrop>'             => [qw/punctype excl/],

    # Classifying tags for multi-word expressions.
    #'adj+kon+adj'         => [qw/field value/],
    #'adj+verb'            => [qw/field value/],
    #'adv+adj'             => [qw/field value/],
    #'adv+adv+prep'        => [qw/field value/],
    #'det+subst'           => [qw/field value/],
    #'interj+adv'          => [qw/field value/],
    #'prep+adj'            => [qw/field value/],
    #'prep+adv'            => [qw/field value/],
    #'prep+adv+subst'      => [qw/field value/],
    #'prep+det+sbu'        => [qw/field value/],
    #'prep+det+subst'      => [qw/field value/],
    #'prep+konj+prep'      => [qw/field value/],
    #'prep+prep'           => [qw/field value/],
    #'prep+subst'          => [qw/field value/],
    #'prep+subst+prep'     => [qw/field value/],
    #'prep+subst+prep+sbu' => [qw/field value/],
    #'prep+subst+subst'    => [qw/field value/],
    #'pron+verb+verb'      => [qw/field value/],
    #'subst+perf-part'     => [qw/field value/],
    #'subst+prep'          => [qw/field value/],

    ###### UNSORTED ######
    #'<adj>'               => [qw/field value/],
    #'<adv>'               => [qw/field value/],
    #appell                => [qw/field value/], # Appellative (common nouns). Can probably be ignored.
    #'<aux1/inf>'          => [qw/field value/],
    #'<aux1/infinitiv>'    => [qw/field value/],
    #'<aux1/perf_part>'    => [qw/field value/],
    #clb                   => [qw/field value/], # Clause boundary. Can probably be ignored.
    #'<dato>'              => [qw/field value/],
    #dem                   => [qw/field value/], # TODO: Demonstrative
    #forst                 => [qw/field value/], # TODO: Emphasis
    #g                     => [qw/field value/], # Corpus bug?
    #'<ikke-clb>'          => [qw/field value/], # Non-clause boundary. Can probably be ignored.
    #'<klokke>'            => [qw/field value/],
    #kvant                 => [qw/field value/], # TODO
    #'<ordenstall>'        => [qw/field value/],
    #'<overskrift>'        => [qw/field value/],
    #pa                    => [qw/field value/],
    #pa1refl4              => [qw/field value/],
    #pa6                   => [qw/field value/],
    #'pa/til'              => [qw/field value/],
    #'<perf-part>'         => [qw/field value/],
    #pr2                   => [qw/field value/],
    #'<pres-part>'         => [qw/field value/],
    #'<romertall>'         => [qw/field value/],
    #samset                => [qw/field value/], # Compound word. Can probably be ignored.
    #sbu                   => [qw/field value/], # Probably corpus bug.
    #'<s-verb>'            => [qw/field value/],
    #tr                    => [qw/field value/], # Subcat frame.
    #w                     => [qw/field value/], # Corpus bug?
);

my @tags = qw/adj adv <anf> clb det inf-merke interj <komma> konj
              <parentes-beg> <parentes-slutt> prep prep+subst pron sbu <strek>
              subst symb ukjent verb/;

sub decode {
    my ($pos, undef, $feats) = split m/\s+/msxo, $_[0];
    $feats = '' if(!defined($feats));
    my @feats = split m/\|/msxo, $feats;
    my @ones = (1) x @feats; # XXX: Apparently (1) x @feats isn't legal as an arg to zip.
    my %feats = zip @feats, @ones;

    my $decoded = {pos => $pos_map{$pos}, tagset => 'no::conll'};

    for my $feat (@feats) {
        next if not exists $feat_map{$feat};
        my ($key, $value) = @{$feat_map{$feat}};
        $decoded->{$key} = $value;
    }

    # Handle things that don't correspond to a single feature/value pair.
    $decoded->{subpos} = 'det'  if $pos eq 'det';
    $decoded->{subpos} = 'sub'  if $pos eq 'sbu';
    $decoded->{subpos} = 'coor' if $pos eq 'konj';

    $decoded->{verbform} = 'inf' if $pos eq 'inf-merke';

    $decoded->{punctype} = 'quot' if $pos eq '<anf>';
    $decoded->{punctype} = 'comm' if $pos eq '<komma>';
    @$decoded{qw/punctype puncside/} = qw/brck ini/ if $pos eq '<parentes-beg>';
    @$decoded{qw/punctype puncside/} = qw/brck fin/ if $pos eq '<parentes-slutt>';
    $decoded->{punctype} = 'dash' if $pos eq '<strek>';
    $decoded->{punctype} = 'symb' if $pos eq 'symb';

    $decoded->{verbform} = $pos eq 'perf-part'? 'part':
                                                'fin'
        if $pos eq 'verb';

    return $decoded;
}

sub encode {
}

sub list { [@tags] }

1;
