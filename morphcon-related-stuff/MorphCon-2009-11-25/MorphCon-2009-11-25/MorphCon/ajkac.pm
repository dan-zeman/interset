#!/usr/bin/perl

package MorphCon::ajkac;

use utf8;

@ISA = (MorphCon::simple);

use IO::File;

sub new {
	my $class = shift;

	my $this = MorphCon::simple->new(@_);

	return bless($this, $class);
}

sub read_file {
	my $this = shift;

	my $filename = shift;
	my $callback = shift;

	my $list = [];

	if (defined $callback) {
		MorphCon::simple->read_file($filename, sub {
			my $struct = shift;

			if (parse_ajkac($struct)) {
				$callback->($struct);
			}
		});
	} else {
		my $list2 = MorphCon::simple->read_file($filename);
		foreach my $struct (@$list) {
			if (parse_ajkac($struct)) {
				push @$list, $struct;
			}
		}
	}

	return $list;
}

sub parse_ajkac {
	my $struct = shift;

	$tag = $struct->{tags}->[0]->{codes}->[0];
	delete $struct->{tags};
	$struct->{tags} = [];

	return 0 if $tag =~ /^\s*$/;

	$tag =~ /^\s*([^\<]+)(.*)$/;

	$struct->{word} = $1;
	my $d = $2;
	$struct->{word} =~ s/\s+$//;
	my @lemmata = split(/\s*\<l\>\s*/, $d); 
	foreach my $lemma_st (@lemmata) {
		next if $lemma_st =~ /^\s*$/;
		my @tags = split(/\s*\<c\>\s*/, $lemma_st); 
		my $lemma = $tags[0];
		my @codes = @tags[1 .. @tags-1];
		push @{$struct->{tags}}, {lemma => $lemma, codes => \@codes};
	}
	return 1;
}

sub write_line {
	my $this = shift;
	my $struct = shift;

	my $wh = $this->{"write_handle"};
	my $line = $struct->{word};
	foreach my $tag_s (@{$struct->{tags}}) {
		$line .= " <l>" . $tag_s->{lemma} . " <c>" . join(" <c>", @{$tag_s->{codes}});
	}

	$this->write_line_tech("$line\n");
	#print $wh "$line\n";
}

return 1;
