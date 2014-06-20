#!/usr/bin/env perl
# Testing DZ Interset 2.0.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
# We must declare in advance how many tests we are going to perform.
use Test::More tests => 7;

# Test en::penn, the only tagset driver shipped with the first subversion of Interset 2.0.
use Lingua::Interset::Tagset::EN::Penn;
my $ts = Lingua::Interset::Tagset::EN::Penn->new();
ok(defined($ts), 'tagset en::penn object defined');
# List of tags in the tagset must not be empty.
my $list = $ts->list();
my $n = scalar(@{$list});
ok($n > 0, 'en::penn has non-empty list of tags');
# Decode a tag.
my $fs = $ts->decode('NN');
ok(defined($fs),            'decoded feature structure is defined');
ok($fs->is_noun(),          'is noun');
ok($fs->number() eq 'sing', 'is singular');
# Modify the feature structure and encode it again.
$fs->set_number('plu');
my $tag = $ts->encode($fs);
ok(defined($tag) && $tag eq 'NNS', 'encoded tag');
# Run standard driver tests.
# They will be counted together as one test here because test plans exceeding 254 tests may pose problems.
my @errors = $ts->test();
if(@errors)
{
    print STDERR (join('', @errors), "\n");
}
ok(!@errors, 'en::penn driver integrity test');
