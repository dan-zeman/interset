#!/usr/bin/env perl
# Reads CoNLL-U from STDIN, converts UPOS+FEATS to UniMorph, saves UniMorph as
# XPOS, writes the result to STDOUT. Checks round-trip conversion, looking for
# UD features that we cannot represent in UniMorph.
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;
use Lingua::Interset qw(decode encode list);

sub usage
{
    print STDERR ("Usage: $0 --unimorph path-to-file < input.conllu > output.conllu\n");
}

my $umpath;
GetOptions
(
    'unimorph=s' => \$umpath
);

my %uposf2um;
my %um2uposf;
my %reported;
my %stats;

# Read the UniMorph file.
my $um;
if(defined($umpath))
{
    $um = read_unimorph($umpath);
}
else
{
    print STDERR ("No UniMorph file path given. The CoNLL-U data will not be checked against UniMorph database.");
}

# Read the CoNLL-U file from STDIN or from files given as arguments.
while(<>)
{
    unless(m/^\#/ || m/^\s*$/)
    {
        chomp();
        my @f = split(/\t/, $_);
        my $uposf = "$f[3]\t$f[5]";
        my $unimorph = $uposf2um{$uposf};
        if(!defined($unimorph))
        {
            my $fs1 = reset_non_unimorph_features(decode('mul::uposf', $uposf));
            my $uposf1 = encode('mul::uposf', $fs1);
            $unimorph = encode('mul::unimorph', $fs1);
            $uposf2um{$uposf} = $unimorph;
            # Check the round-trip conversion.
            my $uposf2 = $um2uposf{$unimorph};
            if(!defined($uposf2))
            {
                my $fs2 = decode('mul::unimorph', $unimorph);
                $uposf2 = encode('mul::uposf', $fs2);
                $um2uposf{$unimorph} = $uposf2;
            }
            if($uposf2 ne $uposf1)
            {
                my $message = sprintf("Roundtrip failed: '%s' --> '%s' --> '%s' --> '%s' ... '%s'\n", $uposf, $uposf1, $unimorph, $uposf2, $f[1]);
                unless(exists($reported{$message}))
                {
                    print STDERR ($message);
                    $reported{$message}++;
                }
            }
        }
        # Compare the UniMorph features with the UniMorph database.
        if(defined($umpath) && $f[0] =~ m/^[0-9]+$/)
        {
            check_unimorph($um, $f[1], $f[2], $unimorph, \%stats);
        }
        # Replace the current XPOS tag, if any, with UniMorph.
        $f[4] = defined($unimorph) && $unimorph ne '' ? $unimorph : '_';
        $_ = join("\t", @f)."\n";
    }
    # Write the modified line to the standard output.
    print();
}
my $n = scalar(keys(%reported));
print STDERR ("Total $n roundtrip conversions failed.\n");

# Write the UniMorph file with frequencies.
if(defined($umpath))
{
    printf STDERR ("%d UD tokens: forms found in UniMorph\n", $stats{n_forms_found});
    printf STDERR ("%d UD tokens: forms not found in UniMorph\n", $stats{n_forms_not_found});
    printf STDERR ("%d UD tokens: forms and analyses found in UniMorph\n", $stats{n_token_analyses_found});
    write_unimorph($umpath.'.freq', \%hash);
}



#------------------------------------------------------------------------------
# Removes from a feature structure the features that we know cannot be
# represented in UniMorph. This way we only report roundtrip mismatches that
# are of some interest.
#------------------------------------------------------------------------------
sub reset_non_unimorph_features
{
    my $fs = shift;
    $fs->clear('pos') if($fs->is_punctuation() || $fs->is_symbol());
    $fs->clear('nametype');
    $fs->set('prontype', 'prn') if($fs->prontype());
    $fs->clear('poss');
    $fs->clear('reflex');
    $fs->set('numtype', 'card') if($fs->numtype() eq 'frac');
    $fs->clear('numtype') unless($fs->numtype() eq 'card' && $fs->prontype() eq '');
    $fs->clear('numform');
    $fs->clear('numvalue');
    $fs->clear('adpostype');
    $fs->clear('conjtype') if($fs->conjtype() eq 'oper');
    $fs->clear('verbform') if($fs->pos() eq 'noun'); # use V.MASDAR only for VERB + VerbForm=Vnoun
    $fs->set('pos', 'verb') if($fs->verbform() eq 'part');
    $fs->clear('prepcase');
    $fs->clear('degree') if($fs->degree() eq 'pos');
    $fs->clear('variant');
    $fs->clear('foreign');
    $fs->clear('abbr');
    $fs->clear('hyph');
    $fs->clear('style');
    $fs->clear('typo');
    # UniMorph also cannot express multi-values (e.g. Gender=Masc,Neut).
    foreach my $key (keys(%{$fs}))
    {
        my $value = $fs->get($key);
        if(ref($value) eq 'ARRAY')
        {
            $value = $value->[0];
            $fs->set($key, $value);
        }
    }
    return $fs;
}



#------------------------------------------------------------------------------
# Reads UniMorph language file.
#------------------------------------------------------------------------------
sub read_unimorph
{
    my $path = shift; # e.g. /net/work/people/zeman/unimorph/ces/ces
    my %hash;
    open(UM, $path) or die("Cannot read $path: $!");
    while(<UM>)
    {
        chomp();
        # fields: lemma form features
        my @f = split(/\t/, $_);
        # There may be multiple analyses of the same form.
        # Hash them by form, then by lemma, then by features.
        $hash{$f[1]}{$f[0]}{$f[2]} = \@f;
    }
    close(UM);
    return \%hash;
}



#------------------------------------------------------------------------------
# Tests a form-lemma-features triple against the UniMorph database.
#------------------------------------------------------------------------------
sub check_unimorph
{
    my $um = shift; # hash ref
    my $form = shift;
    my $lemma = shift;
    my $umfeatures = shift;
    my $stats = shift;
    if(defined($umfeatures) && $umfeatures ne '' && $umfeatures ne '_')
    {
        my $foundform;
        if(exists($um->{$form}))
        {
            $stats->{n_forms_found}++;
            $foundform = $form;
        }
        elsif(exists($um->{lc($form)}))
        {
            $stats->{n_forms_found}++;
            $foundform = lc($form);
        }
        else
        {
            $stats->{n_forms_not_found}++;
        }
        if(defined($foundform))
        {
            if(exists($um->{$foundform}{$lemma}))
            {
                # The order of individual UniMorph features is not significant.
                # Order them alphabetically before matching.
                $umfeatures = join(';', sort(split(/;/, $umfeatures)));
                foreach my $analysis (keys(%{$um->{$foundform}{$lemma}}))
                {
                    my $reordered_analysis = join(';', sort(split(/;/, $analysis)));
                    if($reordered_analysis eq $umfeatures)
                    {
                        $um->{$foundform}{$lemma}{$analysis}[3]++;
                        $stats->{n_token_analyses_found}++;
                        last;
                    }
                }
            }
        }
    }
}



#------------------------------------------------------------------------------
# Writes modified UniMorph language file: Only lines that were found in UD
# data, with added column with frequencies.
#------------------------------------------------------------------------------
sub write_unimorph
{
    my $path = shift; # e.g. /net/work/people/zeman/unimorph/ces/ces
    my $hash = shift;
    open(UM, ">$path") or die("Cannot write $path: $!");
    my @forms = sort(keys(%{$hash}));
    foreach my $form (@forms)
    {
        my @lemmas = sort(keys(%{$hash->{$form}}));
        foreach my $lemma (@lemmas)
        {
            my @analyses = sort(keys(%{$hash->{$form}{$lemma}}));
            foreach my $analysis (@analyses)
            {
                my $frequency = $hash->{$form}{$lemma}{$analysis}[3];
                if(1 || $frequency)
                {
                    print UM ("$lemma\t$form\t$analysis\t$frequency\n");
                }
            }
        }
    }
    close(UM);
}
