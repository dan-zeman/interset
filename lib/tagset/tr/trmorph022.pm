#!/usr/bin/perl
# Interset driver for the TRmorph Turkish tags
# Copyright © 2013 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::tr::trmorph022;
use utf8;
use open ':utf8';



my %symtable;
BEGIN
{
###!!! The symbols used in TRmorph 0.2.2 are described in $TRMORPH/doc/symbols.
###!!! But not all of them! For instance, one of the analyses returned for 'olmak'
###!!! contains '<vinf>', which is not documented in doc/symbols (although it is
###!!! not difficult to guess that it denotes the infinitive).
%symtable =
(
    '1p' => ['person' => '1', 'number' => 'plu'], # A1pl
    '1s' => ['person' => '1', 'number' => 'sing'], # A1sg
    '2p' => ['person' => '2', 'number' => 'plu'], # A2pl
    '2s' => ['person' => '2', 'number' => 'sing'], # A2sg
    '3p' => ['person' => '3', 'number' => 'plu'], # A3pl
    '3s' => ['person' => '3', 'number' => 'sing'], # A3sg
    'abil' => [], # Able (gör-<b>ebil</b> `to be able to see')
    'abl' => ['case' => 'abl'], # Abl
    'acc' => ['case' => 'acc'], # Acc
    'adj' => ['pos' => 'adj'], # Adj
    'adur' => [], # Repeat (not very productive)
    'adv' => ['pos' => 'adv'], # Adv
    'agel' => [], # EverSince (not very productive)
    'agor' => [], # Repeat (not very productive)
    'akal' => [], # Stay (not very productive)
    'akoy' => [], # Start (not very productive)
    'ayaz' => [], # Almost (not very productive)
    'caus' => ['voice' => 'cau'], # Caus (can be attached to the same stem multiple times: yika-<b>t</b>-<b>tır</b> `to make someone have (something) washed')
    'cnjadv' => ['pos' => 'adv', 'subpos' => 'coor'], # Conjunctive adverb (discourse connective)
    'cnjcoo' => ['pos' => 'conj', 'subpos' => 'coor'], # Coordinating conjunction
    'cnjsub' => ['pos' => 'conj', 'subpos' => 'sub'], # Subordinating conjunction
    'cpl_di' => ['tense' => 'past'], # Past copula (gel-iyor `he/she/it is coming', gel-iyor-<b>du</b> `he/she/it was coming')
    'cpl_ken' => ['pos' => 'adv'], # Makes adverbs. Behaves like a copula (gel-iyor-<b>ken</b> `while she/you/I/we/.. is/are coming')
    'cpl_mis' => ['tense' => 'narr'], # Evidential copula (gel-iyor `he/she/it is coming', gel-iyor-<b>muş</b> `(it is said that) he/she/it was coming')
    'cpl_sa' => ['mood' => 'cond'], # Conditional copula (gel-iyor `he/she/it is coming', gel-iyor-<b>sa</b> `if he/she/it is coming')
    'cv' => [], # Converb markers (see more notes in doc; gör-<b>mek</b> için gittim `I went in order to see')
    'dat' => ['case' => 'dat'], # Dat
    'dem' => ['prontype' => 'dem'],
    'dir' => [], # Cop (see more notes in doc)
    'exist' => ['subpos' => 'ex'], # Existential particle 'var'
    'gen' => ['case' => 'gen'], # Gen
    'ij' => ['pos' => 'int'], # Interj
    'ins' => ['case' => 'ins'], # Ins
    'iver' => [], # Hastily
    'ki' => [], # Rel
    'loc' => ['case' => 'loc'], # Loc
    'locp' => [], # Locative pronoun (only three words)
    'n' => ['pos' => 'noun'], # Noun
    'neg' => ['negativeness' => 'neg'], # Neg
    'nexist' => ['subpos' => 'ex', 'negativeness' => 'neg'], # Negative Existential particle `yok'
    'not' => ['pos' => 'part', 'negativeness' => 'neg'], # Negative marker `değil'
    'np' => ['pos' => 'noun', 'subpos' => 'prop'], # Noun Prop
    'num' => ['pos' => 'num'], # Number
    'p1p' => ['poss' => 'poss', 'possperson' => '1', 'possnumber' => 'plu'], # POS1P
    'p1s' => ['poss' => 'poss', 'possperson' => '1', 'possnumber' => 'sing'], # POS1S
    'p2p' => ['poss' => 'poss', 'possperson' => '2', 'possnumber' => 'plu'], # POS2P
    'p2s' => ['poss' => 'poss', 'possperson' => '2', 'possnumber' => 'sing'], # POS2S
    'p3p' => ['poss' => 'poss', 'possperson' => '3', 'possnumber' => 'plu'], # POS3P
    'p3s' => ['poss' => 'poss', 'possperson' => '3', 'possnumber' => 'sing'], # POS3S
    'part_acak' => ['verbform' => 'part'], # Participle marker
    'part_dik' => ['verbform' => 'part'], # Participle marker (gör-<b>düğ</b>-üm film `the movie that I saw')
    'part_yan' => ['verbform' => 'part'], # Participle marker
    'pass' => ['voice' => 'pass'], # Pass (sev-<b>il</b> `to be loved')
    'pers' => ['pos' => 'noun', 'prontype' => 'prs'],
    'pl' => ['number' => 'plu'], # PL
    'pnct' => ['pos' => 'punc'], # Punc
    'postp' => ['pos' => 'prep', 'sub' => 'post'], # Postp
    'prn' => ['pos' => 'noun', 'prontype' => 'prs'], # Pronoun
    'qst' => ['pos' => 'noun', 'prontype' => 'int'], # Question particle that acts like pronoun. Göksel & Kerlaske (2005) call it "interrogative pronoun".
    'rec' => ['voice' => 'rcp'], # Recip (sev `to love' -> sev-<b>iş</b> `to love each other' or `make love')
    'ref' => ['reflex' => 'reflex'], # Refl (yıka `to wash' -> yıka-<b>n</b> `to wash oneself')
    't_aor' => ['subtense' => 'aor'], # Aor (gör-<b>ür</b> `he/she/it sees (something)')
    't_cond' => ['mood' => 'des'], # Oflazer: Desr. But Çöltekin calls it Conditional (gör-<b>se</b> `if he/she/it sees')
    't_cont' => ['aspect' => 'prog'], # Prog1 (gör-<b>üyor</b> `he/she/it is seeing (something)')
    't_fut' => ['tense' => 'fut'], # Fut (gör-<b>ecek</b> `he/she/it will se (something)')
    't_makta' => ['aspect' => 'prog'], # Prog2; This is similar to t_cont, but used less frequently. Most of the time it is used in formal situations, and has a more definite progressive sense (-yor can be used for future events as well). (gör-<b>mekte</b> `he/she/it is seeing (something)')
    't_narr' => ['tense' => 'narr'], # Narr (gör-<b>müş</b> `it is evident/said that he/she/it saw (something)')
    't_obl' => ['mood' => 'nec'], # Neces (gör-<b>meli</b> `he/she/it must see (something)')
    't_opt' => ['mood' => 'opt'], # Opt (Çöltekin's documentation says that Oflazer's equivalent is Imp. Is that a mistake?) (bitir-<b>e</b> `(I) wish/hope/order that he/she/it finishes')
    't_past' => ['tense' => 'past'], # Past (gör-<b>dü</b> `he/she/it saw (something)')
    'v' => ['pos' => 'verb'], # Verb
    'vaux' => ['pos' => 'verb', 'subpos' => 'aux'], # Auxiliary verb
    'vn_acak' => ['pos' => 'noun'], # Verbal noun marker. It forms noun clauses from non-finite verbs (adam ol-<b>acak</b> çocuk =??? `child that will become man'???)
    'vn_dik' => ['pos' => 'noun'], # Verbal noun marker.
    'vn_ma' => ['pos' => 'noun'], # Verbal noun marker.
    'vn_mak' => ['pos' => 'noun'], # Verbal noun marker (gör-<b>mey</b>-e gittim `I went to see')
    'vn_yis' => ['pos' => 'noun'], # Verbal noun marker.
);
}



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = 'tr::trmorph';
    # Example TRmorph analysis:
    # fst-mor trmorph.a
    # reading transducer...
    # finished.
    # analyze> dedi
    # de<v><t_past><3s>
    # de<v><t_past><3p>
    # In the first analysis of this case, we expect to receive "<v><t_past><3s>" as the input $tag.
    $tag =~ s/^<//;
    $tag =~ s/>$//;
    my @elements = split(/></, $tag);
    foreach my $element (@elements)
    {
        if(exists($symtable{$element}))
        {
            my @assignments = @{$symtable{$element}};
            for(my $i = 0; $i<=$#assignments; $i += 2)
            {
                $f{$assignments[$i]} = $assignments[$i+1];
            }
        }
    }
    return \%f;
}



#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
    my $f0 = shift;
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    # Modify the feature structure so that it contains values expected by this
    # driver.
    my $f = tagset::common::enforce_permitted_joint($f0, $permitted);
    my %f = %{$f}; # This is not a deep copy but $f already refers to a deep copy of the original %{$f0}.
    my $tag;
    ###!!! TO BE IMPLEMENTED
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
###!!! To be implemented later!
# Currently we only output the list of the individual symbols.
#------------------------------------------------------------------------------
sub list
{
    my @list = map {"<$_>"} (sort(keys(%symtable)));
    return \@list;
}



#------------------------------------------------------------------------------
# Create trie of permitted feature structures. This will be needed for strict
# encoding. This BEGIN block cannot appear before the definition of the list()
# function.
#------------------------------------------------------------------------------
BEGIN
{
    # Store the hash reference in a global variable.
    $permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
