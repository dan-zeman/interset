#!/usr/bin/perl

package MorphCon::kwic;

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

			if (parse_kwic($struct)) {
				$callback->($struct);
			}
		});
	} else {
		my $list2 = MorphCon::simple->read_file($filename);
		foreach my $struct (@$list) {
			if (parse_kwic($struct)) {
				push @$list, $struct;
			}
		}
	}

	return $list;
}

sub parse_kwic {
	my $struct = shift;

	$tag = $struct->{tags}->[0]->{codes}->[0];
	return 0 if $tag =~ /^#/ or $tag =~ /^\s*$/;

	my @parts = split(/(\<[^\>]+\/[^\>]+\>)/, $tag);
	$struct->{kwic_left_context} = [];
	$struct->{kwic_right_context} = [];
	my $tag_found = 0;
	foreach my $e (@parts) {
		if ($e =~ /^\<\s*([^ ]+)\s*\/\s*([^ ]+)\s*\>$/) {
			my $wortform = $1;
			my $tag_string = $2;
			my $system = "";
#			if ($tag_string =~ /^k/) {
#				$system = "BT";
#			} elsif ($tags =~ /^.{12}--/) {
#				$system = "PT";
#			} else {
#				$system = "UNKNOWN";
#			}
			#print "< {$wortform}${system}[$tag_string] >";
			$struct->{tags} = [{codes => [$tag_string]}];
			$struct->{word} = $wortform;
			$tag_found = 1;
		} else {
			unless ($tag_found) {
				push @{$struct->{kwic_left_context}}, $e;
			} else {
				push @{$struct->{kwic_right_context}}, $e;
			}
			#print $e;
		}
	}
	#print STDERR $tag, "\n";

	return 1;
}

sub write_line {
	my $this = shift;
	my $struct = shift;

	my $wh = $this->{"write_handle"};
	my $line =
		join("", @{$struct->{kwic_left_context}}) .
		"<" . $struct->{word} . "/" .
		$struct->{tags}->[0]->{codes}->[0] . ">" .
		join("", @{$struct->{kwic_right_context}});

	$this->write_line_tech("$line\n");
	#print $wh "$line\n";
}
