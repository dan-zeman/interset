#!/usr/bin/perl

package MorphCon::simple;

use utf8;

use IO::File;

sub new {
	$this = {
	};
	bless $this;
	return $this;
}

sub read_file {
	my $this = shift;

	my $filename = shift;
	my $callback = shift;
	my $file_size = shift;
	my $progress_bar = shift;

	my $list = [];

	my $fh = new IO::File;
	$fh->open($filename, "<") or die "file not found: $filename\n";
	$fh->binmode(":utf8");

	my $byte_counter = 0;
	my $step = 0;
	while (my $line = <$fh>) {
		$byte_counter += length $line;
		if ($file_size > 0) {
			my $progress = $byte_counter/$file_size*100;
			$progress_bar->value($progress);
			if ($progress > $step) {
				$progress_bar->update();
				$step += 10;
			}
		}
		chomp $line;
		
		my $struct = {
			tags => [{codes => [$line]}]
		};

		if (defined $callback) {
			$callback->($struct);
		} else {
			push @$list, $struct;
		}
	}

	close $fh;

	return $list;
}

sub open_for_writing {
	my $this = shift;

	my $filename = shift;
	my $previewer = shift;

	if (defined $previewer) {
		$this->{previewer} = $previewer;
	} else {
		$this->{write_handle} = new IO::File;
		open $this->{write_handle}, ">", $filename;
		binmode $this->{write_handle}, ":utf8";
	}
}

sub write_line {
	my $this = shift;
	my $struct = shift;

	foreach my $tag (@{$struct->{tags}}) {
		$this->write_line_tech(join("\n", @{$tag->{codes}}) . "\n");
	}
}

sub write_line_tech {
	my $this = shift;
	my $output = shift;

	if ($this->{previewer}) {
		$this->{previewer}->insert('end', $output);
	} else {
		my $wh = $this->{"write_handle"};
		print $wh $output;
	}
}

sub close_for_writing {
	my $this = shift;

	unless ($this->{previewer}) {
		close $this->{write_handle};
	}
}

return 1;
