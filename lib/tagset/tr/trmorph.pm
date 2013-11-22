#!/usr/bin/perl
# Interset driver for the TRmorph Turkish tags
# This one works with the new TRmorph version as of fall 2013.
# Copyright © 2013 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::tr::trmorph;
use utf8;
use open ':utf8';



# The symbols are documented in
# Çağrı Çöltekin (2013, draft October 12): 'TRmorph: A morphological analyzer for Turkish'
# https://github.com/coltekin/TRmorph/blob/master/doc/trmorph-manual.pdf
my %symtable =
(
    # Part of speech tags
    'Alpha' => [], ###!!! Symbols of the alphabet
    'Adj' => ['pos' => 'adj'],
    'Adj:partial' => ['pos' => 'adj', 'hyph' => 'hyph'], # Part of multi-word adjective
    'Adv' => ['pos' => 'adv'],
    'Adv:qst' => ['pos' => 'adv', 'prontype' => 'int'],
    'Adv:partial' => ['pos' => 'adv', 'hyph' => 'hyph'], # Part of multi-word adverb, e.g. "apar topar" = "hurriedly"
    'Cnj' => ['pos' => 'conj'],
    'Cnj:coo' => ['pos' => 'conj', 'subpos' => 'coor'],
    'Cnj:adv' => ['pos' => 'conj'], ###!!!
    'Cnj:sub' => ['pos' => 'conj', 'subpos' => 'sub'], # Only three borrowings from Persian: "ki", "eğer", "şayet"
    'Cnj:partial' => ['pos' => 'conj', 'hyph' => 'hyph'], # Part of multi-word conjunction, e.g. "ya ... ya" = "either ... or"
    'Cnj:coo:partial' => ['pos' => 'conj', 'subpos' => 'coor', 'hyph' => 'hyph'], # Part of multi-word conjunction, e.g. "ya ... ya" = "either ... or"
    'Det' => ['pos' => 'adj', 'subpos' => 'det'],
    'Det:def' => ['pos' => 'adj', 'subpos' => 'det', 'definiteness' => 'def', 'prontype' => 'dem'],
    'Det:indef' => ['pos' => 'adj', 'subpos' => 'det', 'definiteness' => 'ind', 'prontype' => 'ind'],
    'Det:qst' => ['pos' => 'adj', 'subpos' => 'det', 'prontype' => 'int'], # "ne kadar" = "how much", "hangi" = "which"
    'Exist' => ['pos' => 'verb', 'subpos' => 'exist'], # Existential verbs/particles "var" and "yok"
    'Exist:neg' => ['pos' => 'verb', 'subpos' => 'exist', 'negativeness' => 'neg'], # Negative existential verb/particle "yok"
    'Ij' => ['pos' => 'int'],
    'N' => ['pos' => 'noun'],
    'N:prop' => ['pos' => 'noun', 'subpos' => 'prop'],
    'N:abbr' => ['pos' => 'noun', 'abbr' => 'abbr'],
    'N:prop:abbr' => ['pos' => 'noun', 'subpos' => 'prop', 'abbr' => 'abbr'],
    'N:partial' => ['pos' => 'noun', 'hyph' => 'hyph'], # Part of multi-word noun
    'Not' => ['pos' => 'part', 'negativeness' => 'neg'], # Negative marker "değil"
    'Num' => ['pos' => 'num'],
    'Num:ara' => ['pos' => 'num', 'numform' => 'digit'],
    'Num:rom' => ['pos' => 'num', 'numform' => 'roman'],
    'Num:qst' => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'int'], # "kaç" = "how many"
    'Onom' => [], # Onomatopoeia ###!!!
    'Postp' => ['pos' => 'prep', 'subpos' => 'post'],
    'Postp:adj' => ['pos' => 'prep', 'subpos' => 'post', 'synpos' => 'attr'], # Postpositional phrase acts as adjective
    'Postp:adv' => ['pos' => 'prep', 'subpos' => 'post', 'synpos' => 'adv'], # Postpositional phrase acts as adverb
    'Postp:ablC' => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'abl'],
    'Postp:accC' => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'acc'],
    'Postp:datC' => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'dat'],
    'Postp:genC' => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'gen'],
    'Postp:insC' => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'ins'],
    'Postp:liC' => ['pos' => 'prep', 'subpos' => 'post'], ###!!! Requires the noun to have suffix "-li" or "-siz". These are not case markers.
    'Postp:nomC' => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'nom'],
    'Prn' => ['pos' => 'noun', 'prontype' => 'prs'], # Pronoun (not necessarily personal but this is the default non-empty value)
    'Prn:pers' => ['pos' => 'noun', 'prontype' => 'prs'],
    'Prn:pers:1s' => ['pos' => 'noun', 'prontype' => 'prs', 'person' => '1', 'number' => 'sing'], # I
    'Prn:pers:2s' => ['pos' => 'noun', 'prontype' => 'prs', 'person' => '2', 'number' => 'sing'], # thou
    'Prn:pers:3s' => ['pos' => 'noun', 'prontype' => 'prs', 'person' => '3', 'number' => 'sing'], # he/she/it
    'Prn:pers:1p' => ['pos' => 'noun', 'prontype' => 'prs', 'person' => '1', 'number' => 'plu'], # we
    'Prn:pers:2p' => ['pos' => 'noun', 'prontype' => 'prs', 'person' => '2', 'number' => 'plu'], # you
    'Prn:pers:3p' => ['pos' => 'noun', 'prontype' => 'prs', 'person' => '3', 'number' => 'plu'], # they
    'Prn:refl' => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'reflex'], # "kendi" = "oneself"
    'Prn:dem' => ['pos' => 'noun', 'prontype' => 'dem'],
    'Prn:locp' => ['pos' => 'noun', 'advtype' => 'loc'],
    'Prn:qst' => ['pos' => 'noun', 'prontype' => 'int'],
    'Prn:pers:qst' => ['pos' => 'noun', 'prontype' => 'int', 'animateness' => 'anim'], ###!!! Example is "kim" = "who"
    'Punc' => ['pos' => 'punc'],
    'Q' => ['pos' => 'part', 'prontype' => 'int'], # Question particle "mi"
    'q' => ['pos' => 'part', 'prontype' => 'int'], # Question particle "mi" put into one token with the verb (the token contains space)
    'V' => ['pos' => 'verb'],
    'V:partial' => ['pos' => 'verb', 'hyph' => 'hyph'], # Part of multi-word verb
    # Derivational tags. They should be followed by a new POS tag.
    '0' => [], # Zero derivation
    'ki' => [], # The suffix "-ki" creates adjectives from genitive or locative nouns.
    # Verb from verb derivations
    'abil' => [], ###!!! ability ("-abil") ("görebil" = "to be able to see")
    'iver' => [], ###!!! immediacy ("-iver") Hastily ("giriverir" = "he/she/it bounces"; "girer" = "he/she/it enters")
    'agel' => [], ###!!! habitual/long term ("-agel") EverSince (not very productive)
    'adur' => [], ###!!! repetition/continuity ("-adur") # Repeat (not very productive)
    'ayaz' => [], ###!!! almost ("-ayaz") Almost (not very productive)
    'akal' => [], ###!!! stop/freeze in action ("-akal") Stay (not very productive) ("şaşakalmıştık" = "we were astonished"; "şaşmıştık" = "we were surprised")
    'agor' => [], ###!!! somewhat like <iver> ("-agör") Repeat (not very productive)
    # Subordinating suffixes. They attach to an untensed verb and make them head of subordinated clause.
    # TRmorph treats them as derivational suffixes, therefore they are followed by a new POS tag (<N>, <Adj> or <Adv>).
    # Verbal nouns. These suffixes create relative clauses that behave like nouns (subjects or objects).
    'vn:inf' => ['pos' => 'noun', 'verbform' => 'inf'], # Infinitive ("-ma", "-mak")
    'vn:yis' => ['pos' => 'noun'], # ("-iş")
    'vn:past' => ['pos' => 'noun', 'verbform' => 'part', 'tense' => 'past'], # Past nominal participle ("-dik")
    'vn:pres' => ['pos' => 'noun', 'verbform' => 'part', 'tense' => 'pres'], # Present nominal participle ("-an")
    'vn:fut' => ['pos' => 'noun', 'verbform' => 'part', 'tense' => 'fut'], # Future nominal participle ("-acak")
    # (Adjectival) participles. These suffixes create relative clauses that behave like adjectives (attributes).
    'part:past' => ['pos' => 'adj', 'verbform' => 'part', 'tense' => 'past'], # Past participle ("-dik")
    'part:pres' => ['pos' => 'adj', 'verbform' => 'part', 'tense' => 'pres'], # Present participle ("-an")
    'part:fut' => ['pos' => 'adj', 'verbform' => 'part', 'tense' => 'fut'], # Future participle ("-acak")
    # Converbs. These suffixes create relative clauses that behave like adverbs (adverbials).
    'cv:ip' => [], ###!!! ("-ip")
    'cv:meksizin' => [], ###!!! ("-meksizin")
    'cv:ince' => [], ###!!! ("-ince")
    'cv:erek' => [], ###!!! ("-erek")
    'cv:eli' => [], ###!!! ("-eli")
    'cv:dikce' => [], ###!!! ("-dikçe")
    'cv:esiye' => [], ###!!! ("-esiye")
    'cv:den' => [], ###!!! ("-den")
    'cv:cesine' => [], ###!!! ("-cesine")
    'cv:ya' => [], ###!!! ("-a")
    'cv:ken' => [], ###!!! ("-ken")
    # Other derivations
    # <li> and <siz>: see under inflectional tags for cases.
    # <dir>: see copulae
    'lik' => [], ###!!! noun -> noun, adjective -> noun, adverb -> noun
    'dim' => [], ###!!! noun -> noun ("-cik", "-cak", "-cağiz")
    'ci' => [], ###!!! noun -> noun, noun -> adjective
    'arasi' => [], ###!!! noun -> adjective
    'imsi' => [], ###!!! noun -> adjective
    'ca' => [], ###!!! noun/adverb -> adverb, adjective/number -> adjective
    'yici' => [], ###!!! verb -> adjective
    'cil' => [], ###!!! noun -> adjective
    'gil' => [], ###!!! noun -> noun
    'lan' => [], ###!!! adjective -> verb
    'las' => [], ###!!! noun -> verb, adjective -> verb
    'yis' => [], ###!!! verb -> noun
    'esi' => [], ###!!! verb -> adjective
    'sal' => [], ###!!! noun -> adjective
    'la' => [], ###!!! noun -> verb, onomatopoeia -> verb
    # Inflectional tags
    'pl' => ['number' => 'plu'], # "-lar"
    'p1s' => ['poss' => 'poss', 'possperson' => '1', 'possnumber' => 'sing'], # "-im" ("my")
    'p2s' => ['poss' => 'poss', 'possperson' => '2', 'possnumber' => 'sing'], # "-in" ("your")
    'p3s' => ['poss' => 'poss', 'possperson' => '3', 'possnumber' => 'sing'], # "-si" ("his/her/its")
    'p1p' => ['poss' => 'poss', 'possperson' => '1', 'possnumber' => 'plu'], # "-imiz" ("our")
    'p2p' => ['poss' => 'poss', 'possperson' => '2', 'possnumber' => 'plu'], # "-iniz" ("your")
    'p3p' => ['poss' => 'poss', 'possperson' => '3', 'possnumber' => 'plu'], # "-lari" ("their")
    'acc' => ['case' => 'acc'], # "-i" (accusative)
    'dat' => ['case' => 'dat'], # "-a" (dative)
    'abl' => ['case' => 'abl'], # "-dan" (ablative)
    'loc' => ['case' => 'loc'], # "-da" (locative)
    'gen' => ['case' => 'gen'], # "-in" (genitive)
    'ins' => ['case' => 'ins'], # "-la" (instrumental)
    'li' => [], ###!!! suffix "-li" is not a case marker but it behaves so and occupies the case slot; also a derivational suffix noun -> adj/adv
    'siz' => [], ###!!! suffix "-siz" is not a case marker but it behaves so and occupies the case slot; also a derivational suffix noun -> adj/adv
    'ncomp' => [], ###!!! optional tag, disabled by default; marks the head of multi-word noun compounds; e.g. "at arabası" = "horse carriage", the suffix "-sı" marks the head of the compound (but it is ambiguous and could be also interpreted as possessive suffix)
    # Any nominal can become predicate with one of the copular suffixes "-di", "-miş", "-sa" or "-(y)".
    # Example: "öğrenci" = "student"; "öğrenciydik" = "we were students"; "öğrenciymişler" = "they were students";
    # "öğrenciysen" = "if you are a student"; "öğrenciyim" = "I am a student"
    # Copular suffixes create verbs from nouns, so they are accompanied by <V>.
    # (In fact, there is first a zero derivation of verb from noun, then the copula, as in "<N><0><V><cpl:past><1p>".)
    'cpl:pres' => ['tense' => 'pres'], # "öğrenciyim" = "I am a student"
    'cpl:past' => ['tense' => 'past'], # "öğrenciydik" = "we were students"
    'cpl:evid' => ['tense' => 'narr'], # "öğrenciymişler" = "they [reportedly] were students"
    'cpl:cond' => ['mood' => 'cond'], # "öğrenciysen" = "if you are a student"
    '1s' => ['person' => '1', 'number' => 'sing'], # "öğrenciyim" = "I am a student"
    '2s' => ['person' => '2', 'number' => 'sing'], # "öğrenciysen" = "if you are a student"
    '3s' => ['person' => '3', 'number' => 'sing'], # "öğretmen" = "he/she is a teacher"
    '1p' => ['person' => '1', 'number' => 'plu'], # "öğrenciydik" = "we were students"
    '2p' => ['person' => '2', 'number' => 'plu'], #
    '3p' => ['person' => '3', 'number' => 'plu'], # "doktor" = "they are doctors"
    'dir' => [], ###!!! Göksel and Kerslake (2005) call this "generalizing modality marker"; it substitutes overt copula, it is common with 3s, disambiguates between noun and predicate readings; <dir> can also be a derivation from noun to adverb
    'dist' => ['pos' => 'num', 'numtype' => 'dist'], # distributive numeral: "birer" = "one each"; "ikişer" = "two each"
    'ord' => ['pos' => 'num', 'numtype' => 'ord'], # ordinal number: "birinci" = "first"; "ikinci" = "second"
    'perc' => [], ###!!! Percent sign ("%") before a number is treated like a prefix and tagged "<perc>".
    # Verbal voice suffixes (TRmorph treats them as derivations and adds a <V> tag after them.)
    'rfl' => ['reflex' => 'reflex'],
    'rcp' => ['voice' => 'rcp'],
    'caus' => ['voice' => 'caus'], # This suffix can be used repetitively.
    'pass' => ['voice' => 'pass'],
    'neg' => ['negativeness' => 'neg'], # Negative suffix "-ma" in verbs. Nominal predicates use the particle "değil" instead.
    # Tense/aspect/modality suffixes for verbs
    'evid' => ['tense' => 'narr'], # Evidential past (perfective) ("-miş")
    'fut' => ['tense' => 'fut'], # Future ("-acak")
    'obl' => ['mood' => 'nec'], # Obligative ("-mali")
    'impf' => [], ###!!! Imperfective ("-makta")
    'cont' => ['aspect' => 'prog'], # Imperfective ("-yor")
    'past' => ['tense' => 'past'], # Past ("-di")
    'cond' => ['mood' => 'cond'], # Conditional ("-sa")
    'opt' => ['mood' => 'opt'], # Optative ("-a")
    'imp' => ['mood' => 'imp'], # Imperative ("-")
    'aor' => ['subtense' => 'aor'], # Aorist ("-ar", "-ir" etc.)
);



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
# cat train.conll test.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 1074
# 1072 after cleaning ###!!!???and adding 'other'-resistant tags
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
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
