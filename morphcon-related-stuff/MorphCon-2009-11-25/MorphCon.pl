#!/usr/bin/perl

use constant MORPHCON_VERSION => "MorphCon v0.2alfa";

use strict;

use utf8;

use Pod::Usage;
use Getopt::Long;
my $opt_infile = "";
my $opt_outfile = "";
my $opt_informat = "";
my $opt_outformat = "";
my $opt_intagset = "";
my $opt_outtagset = "";
my $opt_preview = "";
my $opt_run = "";
my $opt_exit = "";
my $opt_debug = "";
my $opt_autosense = "";
my $opt_man = "";
my $opt_help = "";
GetOptions(
	'infile|i=s' => \$opt_infile,
	'outfile|o=s' => \$opt_outfile,
	'informat|f=s' => \$opt_informat,
	'outformat|g=s' => \$opt_outformat,
	'intagset|t=s' => \$opt_intagset,
	'outtagset|s=s' => \$opt_outtagset,
	'preview!' => \$opt_preview,
	'run!' => \$opt_run,
	'exit!' => \$opt_exit,
	'debug!' => \$opt_debug,
	'autosense!' => \$opt_autosense,
	'man!' => \$opt_man,
	'help!' => \$opt_help
);
pod2usage(1) if $opt_help;
pod2usage(-exitstatus => 0, -verbose => 2) if $opt_man;
if ($ARGV[0]) {
	$opt_outformat = shift;
}
if ($ARGV[0]) {
	$opt_outtagset = shift;
}
print STDERR "Output format: $opt_outformat, Output tagset: $opt_outtagset\n";

use Encode;
my $codepage = "cp1250"; # the codepage in which filenames are encoded

use Tk;
use Tk::JPEG;
use Tk::Dialog;
use Tk::ROText;
use Tk::ProgressBar;

use MorphCon::simple;
use MorphCon::kwic;
use MorphCon::wpl;
use MorphCon::csts;
use MorphCon::ajkac;

use tagset::cs::ajka;
use tagset::cs::pdt16;
use tagset::cs::pdt;
use tagset::cs::multext;

use Data::Dumper;

my %component;		# hash which contains all graphical widgets
my $file_size;		# size of the input file in bytes (needed for the progress bar)

# setting up file formats
use constant INPUT_FILE_FORMAT => "simple";
use constant OUTPUT_FILE_FORMAT => "same";

my %file_formats = (
	"same" => {
		text => "Same as Input"
	},
	"simple" => {
		class => "MorphCon::simple",
		text => "SimpleTag"
	},
	"wpl2" => {
		class => "MorphCon::wpl(2)",
		text => "WPL (word-lemma-tag)"
	},
	"wpl1" => {
		class => "MorphCon::wpl(1)",
		text => "WPL (word-tag-lemma)"
	},
	"kwic" => {
		class => "MorphCon::kwic",
		text => "KWIC/Tag"
	},
	"csts" => {
		class => "MorphCon::csts",
		text => "CSTS"
	},
	"ajkac" => {
		class => "MorphCon::ajkac",
		text => "Ajka"
	}
);

my $input_file_format = &INPUT_FILE_FORMAT;
my $input_file_format_text = $file_formats{&INPUT_FILE_FORMAT}->{text};
my $output_file_format = &OUTPUT_FILE_FORMAT;
my $output_file_format_text = $file_formats{&OUTPUT_FILE_FORMAT}->{text};

if ($opt_informat ne "") {
	if ($opt_informat ne "same" and exists $file_formats{$opt_informat}) {
		$input_file_format = $opt_informat;
		$input_file_format_text = $file_formats{$opt_informat}->{text};
	} else {
		die "Input file format \"$opt_informat\" not supported!\n";
	}
}
if ($opt_outformat ne "") {
	if ($opt_outformat ne "kwic" and exists $file_formats{$opt_outformat}) {
		$output_file_format = $opt_outformat;
		$output_file_format_text = $file_formats{$opt_outformat}->{text};
	} else {
		die "Output file format \"$opt_outformat\" not supported!\n";
	}
}

# setting up tagset formats
use constant INPUT_TAGSET_FORMAT => "ajka";
use constant OUTPUT_TAGSET_FORMAT => "same";

my %tagset_formats = (
	"same" => {
		text => "Same as Input"
	},
	"ajka" => {
		text => "cs:attributive",
		encode => \&tagset::cs::ajka::encode,
		decode => \&tagset::cs::ajka::decode,
		regex => qr/k[0-9AY][^ ]*/
	},
	"pdt16" => {
		text => "cs:positional-16",
		encode => \&tagset::cs::pdt16::encode,
		decode => \&tagset::cs::pdt16::decode,
		regex => qr/[^\s]{12}--[^\s]{2}/
	},
	"pdt" => {
		text => "cs:positional-15",
		encode => \&tagset::cs::pdt::encode,
		decode => \&tagset::cs::pdt::decode,
		regex => qr/[^\s]{12}--[^\s]{1}/
	},
	"multext" => {
		text => "cs:positional-multext",
		encode => \&tagset::cs::multext::encode,
		decode => \&tagset::cs::multext::decode,
		regex => qr/A[a-z\-0-9]{5}|A[a-z\-0-9]{8,9}|C[a-z\-0-9]|C[a-z\-0-9]{7}|I|M[a-z\-0-9]{8,9}|N[a-z\-0-9]{2,4}|N[a-z\-0-9]{7}|P[a-z\-0-9]{13}|Q|R[a-z\-0-9]{2}|S[a-z\-0-9]{2,3}|V[a-z\-0-9]{4,5}|V[a-z\-0-9]{8}|V[a-z\-0-9]{13}|X|Y/
	},
	"interset" => {
		text => "Raw Interset",
		encode => \&interset_encode,
		decode => \&interset_decode,
		regex => qr/\s*\{.*\}\s*/
	},
	"interset_with_tag" => {
		text => "Interset with Tag",
		encode => \&interset_encode_with_tag,
	},
	"desc" => {
		text => "Tag Description",
		encode => \&desc_encode,
	},
);

my $input_tagset_format = &INPUT_TAGSET_FORMAT;
my $input_tagset_format_text = $tagset_formats{&INPUT_TAGSET_FORMAT}->{text};
my $output_tagset_format = &OUTPUT_TAGSET_FORMAT;
my $output_tagset_format_text = $tagset_formats{&OUTPUT_TAGSET_FORMAT}->{text};

if ($opt_intagset ne "") {
	if ($opt_intagset ne "same" and exists $tagset_formats{$opt_intagset}) {
		$input_tagset_format = $opt_intagset;
		$input_tagset_format_text = $tagset_formats{$opt_intagset}->{text};
	} else {
		die "Input tagset format \"$opt_intagset\" not supported!\n";
	}
}
if ($opt_outtagset ne "") {
	if (exists $tagset_formats{$opt_outtagset}) {
		$output_tagset_format = $opt_outtagset;
		$output_tagset_format_text = $tagset_formats{$opt_outtagset}->{text};
	} else {
		die "Output tagset format \"$opt_outtagset\" not supported!\n";
	}
}

# autosense input file format and tagset
if ($opt_infile ne "" and $opt_autosense) {
	autosense_file($opt_infile);
}

# creating the main window and menubar
my $top = new MainWindow(-title => "MorphCon");
my $menu = $top->Menu(-type => "menubar");
$top->configure(-menu => $menu);

my %menu_entry; # hash which contains all menu items

# the file menu
$menu_entry{file} = $menu->cascade(-label => "File", -tearoff => 0);
$menu_entry{'open'} = $menu_entry{file}->command(-label => "Open", -command => \&getInputFile);
$menu_entry{save} = $menu_entry{file}->command(-label => "Save", -command => \&getOutputFile);
$menu_entry{quit} = $menu_entry{file}->command(-label => "Quit", -command => sub { exit; });

# the help menu
$component{about_dialog} = $top->Dialog(-title => "MorphCon", -text => "bla, bla", -default_button => 'Ok', -buttons => [qw/Ok/]);
$menu_entry{help} = $menu->cascade(-label => "?", -tearoff => 0);
$menu_entry{about} = $menu_entry{help}->command(-label => "About", -command => sub {$component{about_dialog}->Show});

# main window consists of the input area on the left and the output area on the right
$component{input_frame} = $top->Labelframe(-text => "Input")->grid(-row => 0, -column => 0);
$component{output_frame} = $top->Labelframe(-text => "Output")->grid(-row => 0, -column => 1, -sticky => "e");

$component{input_file_label} = $component{input_frame}->Label(-text => "File:")->grid(-row => 0, -column => 0, -sticky => "w");
$component{output_file_label} = $component{output_frame}->Label(-text => "File:")->grid(-row => 0, -column => 0, -sticky => "w");

$component{input_file_entry} = $component{input_frame}->Entry(-width => 60, -text => $opt_infile)->grid(-row => 0, -column => 1);
$component{output_file_entry} = $component{output_frame}->Entry(-width => 60, -text => $opt_outfile)->grid(-row => 0, -column => 1);

$component{input_file_browse_button} = $component{input_frame}->Button(-text => "Browse", -command => \&getInputFile)->grid(-row => 0, -column => 2);
$component{output_file_browse_button} = $component{output_frame}->Button(-text => "Browse", -command => \&getOutputFile)->grid(-row => 0, -column => 2);

$component{input_fileformat_label} = $component{input_frame}->Label(-text => "Input format:")->grid(-row => 1, -column => 0, -sticky => "w");
$component{output_fileformet_label} = $component{output_frame}->Label(-text => "Output format:")->grid(-row => 1, -column => 0, -sticky => "w");

$component{input_tagset_label} = $component{input_frame}->Label(-text => "Tagset:")->grid(-row => 2, -column => 0, -sticky => "w");
$component{output_tagset_label} = $component{output_frame}->Label(-text => "Tagset:")->grid(-row => 2, -column => 0, -sticky => "w");

$component{input_fileformat_options} = $component{input_frame}->Optionmenu(
	-options => generate_options(\%file_formats, {"same" => 1})
)->grid(-row => 1, -column => 1, -columnspan => 2, -sticky => "w");
$component{input_fileformat_options}->configure(-variable => \$input_file_format);
$component{input_fileformat_options}->configure(-textvariable => \$input_file_format_text);

$component{output_fileformat_options} = $component{output_frame}->Optionmenu(
	-options => generate_options(\%file_formats, {"kwic" => 1})
)->grid(-row => 1, -column => 1, -columnspan => 2, -sticky => "w");
$component{output_fileformat_options}->configure(-variable => \$output_file_format);
$component{output_fileformat_options}->configure(-textvariable => \$output_file_format_text);

$component{input_tagset_options} = $component{input_frame}->Optionmenu(
	-options => generate_options(\%tagset_formats, {"same" => 1, "desc" => 1, "interset_with_tag" => 1})
)->grid(-row => 2, -column => 1, -columnspan => 2, -sticky => "w");
$component{input_tagset_options}->configure(-variable => \$input_tagset_format);
$component{input_tagset_options}->configure(-textvariable => \$input_tagset_format_text);

$component{output_tagset_options} = $component{output_frame}->Optionmenu(
	-options => generate_options(\%tagset_formats)
)->grid(-row => 2, -column => 1, -columnspan => 2, -sticky => "w");
$component{output_tagset_options}->configure(-variable => \$output_tagset_format);
$component{output_tagset_options}->configure(-textvariable => \$output_tagset_format_text);

$component{autosense_option} = $component{input_frame}->Checkbutton(-text => "Autosense file format")->grid(-column => 0, -columnspan => 3, -sticky => "w");
if ($opt_autosense) {
	$component{autosense_option}->select;
}
$component{preview_option} = $component{output_frame}->Checkbutton(-text => "Just show preview dialog (Don't write to file)")->grid(-column => 0, -columnspan => 3, -sticky => "w");
if ($opt_preview) {
	$component{preview_option}->select;
}

# in the lower area of the window is the start button, the progress bar and the status bar
$component{start_button} = $top->Button(-text => "Start Conversion", -command => sub {
	my $e = start_conversion(@_);
	if ($e eq "noinputfile") {
		$top->Dialog(
			-title => "MorphCon",
			-text => "No input file given!",
			-default_button => 'Ok',
			-buttons => [qw/Ok/]
		)->Show;
	} elsif ($e eq "nooutputfile") {
		$top->Dialog(
			-title => "MorphCon",
			-text => "No output file given!",
			-default_button => 'Ok',
			-buttons => [qw/Ok/]
		)->Show;
	}
})->grid(-row => 1, -column => 0, -sticky => "w");
$component{progress_bar} = $top->ProgressBar(
	-padx => 2,
	-pady => 2,
	-borderwidth => 2,
	-troughcolor => '#BFEFFF',
	-colors => [ 0, '#104E8B' ],
	-length => 200,
	-blocks => 29
);
$component{progress_bar}->grid(-row => 2, -column => 0, -sticky => "w", -ipadx => 100);
$component{progress_bar}->value(0);

$component{status_bar} = $top->Labelframe(-text => "Status")->grid(
	-row => 3,
	-column => 0,
	-columnspan => 3,
	-sticky => "we"
);
$component{status_label} = $component{status_bar}->Label(-text => "")->pack(
	-anchor => "nw"
);
$component{status_label}->configure(-text => MORPHCON_VERSION);

$component{logo} = $top->Canvas(
	-width => 209,
	-height => 123,
	-borderwidth => 2
)->grid(-row => 1, -column => 1, -sticky => 'e', -rowspan => 2);

$component{logo_pic} = $top->Photo(-file => "logo-blue.jpg");
$component{logo}->createImage(0, 0, -anchor => 'nw', -image => $component{logo_pic},); 

$component{previewer} = $top->DialogBox(-title => "MorphCon Previewer", -buttons => ["OK"]);
$component{previewer_text} = $component{previewer}->add('Scrolled', 'ROText',
	-wrap => 'none',
	-height => 40
)->pack(-fill => 'both');
$component{previewer_text}->configure(-scrollbars => 'osoe');

if ($opt_run) {
	my $e = start_conversion();
	if ($e eq "noinputfile") {
		$top->Dialog(
			-title => "MorphCon",
			-text => "No input file given!",
			-default_button => 'Ok',
			-buttons => [qw/Ok/]
	)	->Show;
	} elsif ($e eq "nooutputfile") {
		$top->Dialog(
			-title => "MorphCon",
			-text => "No output file given!",
			-default_button => 'Ok',
			-buttons => [qw/Ok/]
		)->Show;
	}
}

MainLoop();

exit 0;

sub autosense_file {
	my $file = encode($codepage, shift);
	print STDERR "Autosensing: $file\n";
	my $fh = new IO::File;
	$fh->open($file, "<") or die "file not found: $file\n";
	$fh->binmode(":utf8");

	my @tagset_names;
	my @tagset_regexs;

	foreach my $tagset (keys %tagset_formats) {
		if (exists $tagset_formats{$tagset}->{regex}) {
			push @tagset_names, $tagset;
			push @tagset_regexs, $tagset_formats{$tagset}->{regex};
		}
	}

	my $tagexpr = join("|", @tagset_regexs);

	my $line = <$fh>;
	my $tag;
	while ($line =~ /^#/ or $line =~ /^\s*$/) {
		$line = <$fh>;
	}
	if ($line =~ /^\s*\<csts\>/) {
		$line = <$fh>;
		set_input_file_format("csts");
		$line =~ /\<MMt\>\s*(.*)/;
		$tag = $1;
	} else {
		if ($line =~ /\<l\>.+\<c\>\s*(.*)/) {
			set_input_file_format("ajkac");
			$tag = $1;
		} elsif ($line =~ /\<.+\/\s*(.*)\s*\>/) {
			set_input_file_format("kwic");
			$tag = $1;
		} elsif ($line =~ /^([^\t]*)$/) {
			set_input_file_format("simple");
			$tag = $1;
		} elsif ($line =~ /^[^\t]+\t($tagexpr)/) {
			set_input_file_format("wpl1");
			$tag = $1;
		} elsif ($line =~ /^[^\t]+\t[^\t]+\t($tagexpr)/) {
			set_input_file_format("wpl2");
			$tag = $1;
		}
	}

	for (my $i = 0; $i < @tagset_names; $i++) {
		if ($tag =~ $tagset_regexs[$i]) {
			set_input_tagset($tagset_names[$i]);
			last;
		}
	}
}

sub set_input_file_format {
	my $file_format = shift;
	print STDERR "Input file format: $file_format\n";
	$input_file_format = $file_format;
	$input_file_format_text = $file_formats{$file_format}->{text};
}

sub set_input_tagset {
	my $tagset = shift;
	print STDERR "Input tagset: $tagset\n";
	$input_tagset_format = $tagset;
	$input_tagset_format_text = $tagset_formats{$tagset}->{text};
}

sub generate_options {
	my $mapping = shift;
	my $skip = shift;
	my $o = [];
	foreach my $e (keys %{$mapping}) {
		unless ($skip->{$e}) {
			push @{$o}, [$mapping->{$e}->{text}, $e];
		}
	}
	return $o;
}

sub getInputFile {
	my $filename = $top->getOpenFile();
	$component{input_file_entry}->configure(-text => $filename);
	$component{input_file_entry}->xview('end');
	if ($component{autosense_option}->{'Value'}) {
		autosense_file($filename);
	}
}

sub getOutputFile {
	my $filename = $top->getSaveFile();
	$component{output_file_entry}->configure(-text => $filename);
	$component{output_file_entry}->xview('end');
}

sub start_conversion {
	$component{progress_bar}->value(0);

	my $input_file_name = $component{input_file_entry}->get();
	my $output_file_name = $component{output_file_entry}->get();

	unless ($input_file_name) {
		return "noinputfile";
	}

	$file_size = -s encode($codepage, $input_file_name);
	print STDERR "File size: $file_size\n";

	my $preview = 0;
	if ($component{preview_option}->{'Value'}) {
		$component{previewer_text}->delete("1.0", "end");
		$output_file_name = $component{previewer_text};
		$preview = 1;
	} elsif (not $output_file_name) {
		return "nooutputfile";
	}

	my $reader;
	my $writer;
	my $status = "";
	my $encode;
	my $decode;

	$reader = eval("new " . $file_formats{$input_file_format}->{class});
	$status .= "Input format: " . $file_formats{$input_file_format}->{text};
	if ($output_file_format eq "same") {
		$writer = $reader;
	} else {
		$writer = eval("new " . $file_formats{$output_file_format}->{class});
	}
	$status .= "; Output format: " . $file_formats{$output_file_format}->{text};

	$decode = $tagset_formats{$input_tagset_format}->{decode};
	$status .= "; Input tagset: " . $tagset_formats{$input_tagset_format}->{text};

	if ($output_tagset_format eq "same") {
		$encode = $tagset_formats{$input_tagset_format}->{encode};
	} else {
		$encode = $tagset_formats{$output_tagset_format}->{encode};
	}
	$status .= "; Output tagset: " . $tagset_formats{$output_tagset_format}->{text};

	$component{status_label}->configure(-text => $status);
	print STDERR "$status\n";
	$component{status_label}->update();

	if ($preview) {
		$writer->open_for_writing(encode($codepage, $output_file_name), $component{previewer_text});
	} else {
		$writer->open_for_writing(encode($codepage, $output_file_name));
	}
	my $callback = sub {
		my $struct = shift;
	
		if ($opt_debug) {
			print Dumper($struct);
		}
		foreach my $tag (@{$struct->{tags}}) {
			print "$tag->{lemma}:\n" if $opt_debug;
			foreach my $code (@{$tag->{codes}}) {
				print "\t$code ==> " if $opt_debug;
				$code = $encode->($decode->($code), $code);
				print "$code\n" if $opt_debug;
			}
		}
		if ($opt_debug) {
			#print Dumper($struct);
		}
		$writer->write_line($struct);
	};
	$reader->read_file(
		encode($codepage, $input_file_name),
		$callback,
		$file_size,
		$component{progress_bar}
	);
	$writer->close_for_writing();

	$component{progress_bar}->value(100);
	if ($preview) {
		$component{previewer}->Show;
	}
	$component{progress_bar}->value(0);
	if ($opt_exit) {
		exit 0;
	}
}

sub desc_encode {
	my $f0 = shift;
	my %f = %{$f0};
	my $code = shift;

	my $tag_string = "$code ";

	my @codes = ();
	if ($f{pos} eq "noun" or $f{pos} eq "adj") {
		@codes = ($f{case}, $f{number}, $f{gender});
	} elsif ($f{pos} eq "verb") {
		@codes = ($f{person}, $f{number});
	}
	$tag_string .= "(" . join("+", ($f{pos}, @codes)) . ")";

	return $tag_string;
}

sub interset_encode_with_tag {
	return interset_encode(@_, 1);
}

sub interset_encode {
	my $f0 = shift;
	my %f = %{$f0};
	my $code = shift;
	my $with_tag = shift;

	my $tag_string = "";

	my $d = Data::Dumper->new([$f0]);
	$d->Indent(0);
	$d->Terse(1);

	if ($with_tag) {
		$tag_string .= "$code ";
	}

	$tag_string .= $d->Dump;

	return $tag_string;
}

sub interset_decode {
	my $tag_string = shift;

	my $f = eval($tag_string);

	return $f;
}

__END__

=head1 NAME

MorphCon.pl - MorphCon GUI Tool

=head1 SYNOPSIS

MorphCon.pl [options] <output format> <output tagset>

	Options:
		-help			brief help message (-h)
		-man			full documentation (-m)
		-infile <filename>	input file (-i)
		-outfile <filename>	output file (-o)
		-informat <format>	file format of input file (-f)
		-outformat <format>	file format of output file (-g)
		-intagset <format>	tagset of input file (-t)
		-outtagset <format>	tagset of output file (-s)
		-autosense		autosense input file format and tagset (-a)
		-preview		set preview option (-p)
		-run			automaticaly start conversion (-r)
		-exit			exit after conversion (-e)
		-debug			print debug information to STDOUT (-d)

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-infile>

Sets the input file name.

=item B<-outfile>

Sets the output file name.

=item B<-informat>

Sets the format of the input file. Possible values are:
	simple	 	Simple textfile with tags
	wpl2		WPL-Vertical Mode (word-tag-lemma)
	wpl1		WPL-Vertical Mode (word-lemma-tag)
	kwic		KWIC/tag-Format
	csts		csts
	ajkac		ajka Corpus (ajka -c)

You can also use the autosense feature.

=item B<-outformat>

Sets the format of the output file. Possible values are:
	same	 	Same as input
	simple	 	Simple textfile with tags
	wpl2		WPL-Vertical Mode (word-tag-lemma)
	wpl1		WPL-Vertical Mode (word-lemma-tag)
	csts		csts
	ajkac		ajka Corpus (ajka -c)

KWIC-files can only be created from KWIC-files, so use "-informat kwic -outformat same".

=item B<-intagset>

Sets the tagset of the input file. Possible values are:
	ajka		tagset::cs:ajka
	pdt16		tagset::cs:pdt16

=item B<-outtagset>

Sets the tagset of the output file. Possible values are:
	same		Same as input
	ajka		tagset::cs:ajka
	pdt16		tagset::cs:pdt16

=item B<-autosense>

With this option set MorphCon.pl will try to guess the format and tagset of the input file. Don't forget to
specify the input file name.

=item B<-preview>

With this option set MorphCon.pl will show the outcome of the conversion in a preview window. Nothing will be
written to the output file!

=item B<-run>

The conversion will be started as MorphCon.pl is loaded. Use this together with the -exit option for the
automatization of file conversions.

=item B<-exit>

Exit after the conversion is done.

=item B<-debug>

Debug information about the conversion is written to STDOUT.
Use "MorphCon.pl [options] -d > debug.txt" to capture it to a file.

=back

=head1 DESCRIPTION

MorphCon converts between different czech tagset and file formats used for morphological analysis.

=cut
