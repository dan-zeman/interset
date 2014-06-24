#!/usr/bin/perl

package MorphCon::csts;

use utf8;

use Data::Dumper;

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

			if (parse_csts($struct)) {
				$callback->($struct);
			}
		});
	} else {
		my $list2 = MorphCon::simple->read_file($filename);
		foreach my $struct (@$list) {
			if (parse_csts($struct)) {
				push @$list, $struct;
			}
		}
	}

	return $list;
}

sub parse_csts {
	my $struct = shift;

	$tag = $struct->{tags}->[0]->{codes}->[0];
	delete $struct->{tags};
	$struct->{tags} = [];

	return 0 if $tag =~ /^\s*\<\/?csts\>\s*$/ or $tag =~ /^\s*$/;

	if ($tag =~ /^\s*\<((d|f)( cap)?)\>([^<]*)\s*(.*)$/) {
		if ($2 eq "d") {
			$struct->{diacritic} = 1;
		}
		if ($3 eq " cap") {
			$struct->{capital} = 1;
		}
		$struct->{word} = $4;
		my @lemmata = split(/\s*\<MMl\>\s*/, $5);
		foreach my $lemma_st (@lemmata) {
			next if $lemma_st =~ /^\s*$/;
			my @tags = split(/\s*\<MMt\>\s*/, $lemma_st);
			my $lemma = $tags[0];
			my @codes = @tags[1 .. @tags-1];
			push @{$struct->{tags}}, {lemma => $lemma, codes => \@codes};
		}
	}
	return 1;
}

sub open_for_writing {
	my $this = shift;
	$this->SUPER::open_for_writing(@_);
	$this->write_line_tech("<csts>\n");
}

sub write_line {
	my $this = shift;
	my $struct = shift;

	my $wh = $this->{"write_handle"};
	my $line = ($struct->{diacritic} ? "<d>" : "<f" . ($struct->{capital} ? " cap" : "") . ">") . 
		$struct->{word};
	foreach my $tag_s (@{$struct->{tags}}) {
		$line .= "<MMl>" . $tag_s->{lemma} . "<MMt>" . join("<MMt>", @{$tag_s->{codes}});
	}

	$this->write_line_tech("$line\n");
	#print $wh "$line\n";
}

sub close_for_writing {
	my $this = shift;

	$this->write_line_tech("</csts>\n");
	$this->SUPER::close_for_writing(@_);
}

return 1;
