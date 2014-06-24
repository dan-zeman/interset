#!/usr/bin/perl

package MorphCon::wpl;

use utf8;

@ISA = (MorphCon::simple);

use IO::File;

sub new {
	my $class = shift;
	my $field_with_tag = shift;

	my $this = MorphCon::simple->new(@_);
	$this->{field_with_tag} = $field_with_tag;

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

			if (parse_wpl($struct, $this)) {
				$callback->($struct);
			}
		});
	} else {
		my $list2 = MorphCon::simple->read_file($filename);
		foreach my $struct (@$list) {
			if (parse_wpl($struct, $this)) {
				push @$list, $struct;
			}
		}
	}

	return $list;
}

sub parse_wpl {
	my $struct = shift;
	my $this = shift;

	my $line = $struct->{tags}->[0]->{codes}->[0];
	delete $struct->{tags};
	$struct->{tags} = [];

	my @fields = split("\t", $line);
	my $field_with_tag = $this->{field_with_tag};
	my $field_with_lemma = $field_with_tag == 1 ? 2 : 1;
	$struct->{word} = $fields[0];
	while ($field_with_tag < @fields and $field_with_lemma < @fields) {
		my @codes = split(",", $fields[$field_with_tag]);
		push @{$struct->{tags}}, {lemma => $fields[$field_with_lemma], codes => \@codes};

		$field_with_tag += 2;
		$field_with_lemma += 2;
	}

	return 1;
}

sub write_line {
	my $this = shift;
	my $struct = shift;

	my $wh = $this->{"write_handle"};
	my $line = $struct->{word};
	foreach my $tag_s (@{$struct->{tags}}) {
		$line .=  "\t";
		if ($this->{field_with_tag} == 2) {
			$line .= $tag_s->{lemma} . "\t";
			$line .= join(",", @{$tag_s->{codes}});
		} elsif ($this->{field_with_tag} == 1) {
			$line .= join(",", @{$tag_s->{codes}}) . "\t";
			$line .= $tag_s->{lemma};
		}
	}
	my @additional_columns = @{$struct->{wpl_additional_columns}};
	if (@additional_columns > 0) {
		$line .= "\t" . join("\t", @additional_columns);
	}
	
	$this->write_line_tech("$line\n");
	#print $wh "$line\n";
}
