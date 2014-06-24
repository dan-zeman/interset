#!/usr/bin/perl

package tagset::cs::ajka;
use utf8;

use tagset::common;

use Clone qw(clone);

my %tag_system = (
	k => ["pos", {
		1 => "noun",
		2 => "adj",
		3 => sub {
			my $f = shift;

			$f->{pos} = "pron";
			$f->{prontype} = "prs";
		},
		4 => "num",
		5 => "verb",
		6 => "adv",
		7 => "prep",
		8 => "conj",
		9 => "part",
		0 => "int",
		A => sub {
			my $f = shift;

			$f->{abbr} = "abbr";
		},
		Y => sub {
			my $f = shift;

			$f->{other} = "ajka-kY";
		},
		#P => undef
	}],
	g => ["gender", {
		M => sub {
			my $f = shift;

			$f->{gender} = "masc";
			$f->{possgender} = "masc";
			$f->{animateness} = "anim";
		},
		I => sub {
			my $f = shift;

			$f->{gender} = "masc";
			$f->{possgender} = "masc";
			$f->{animateness} = "inan";
		},
		N => sub {
			my $f = shift;

			$f->{gender} = "neut";
			$f->{possgender} = "neut";
		},
		F => sub {
			my $f = shift;

			$f->{gender} = "fem";
			$f->{possgender} = "fem";
		},
		R => sub {
			my $f = shift;

			$f->{gender} = "family";
		},
		#X => undef,
		Y => sub {
			my $f = shift;

			$f->{gender} = "masc,neut"; # ??? Sauber genug
			$f->{possgender} = "masc,neut"; # ??? Sauber genug
			$f->{animateness} = "inan";
		},
		U => sub {
			my $f = shift;

			$f->{gender} = "masc,neut"; # ??? Sauber genug
			$f->{possgender} = "masc,neut"; # ??? Sauber genug
		},
		P => sub {
			my $f = shift;

			$f->{animateness} = "anim";
		},
		T => sub {
			my $f = shift;

			$f->{animateness} = "inan";
		}
	}],
	n => ["number", {
		S => sub {
			my $f = shift;

			$f->{number} = "sing";
			$f->{possnumber} = "sing";
		},
		P => sub {
			my $f = shift;

			$f->{number} = "plu";
			$f->{possnumber} = "plu";
		},
		D => sub {
			my $f = shift;

			$f->{number} = "dual";
			$f->{possnumber} = "dual";
		},
		R => sub {
			my $f = shift;

			$f->{number} = "family";
		},
	}],
	c => ["case", {
		1 => "nom",
		2 => "gen",
		3 => "dat",
		4 => "acc",
		5 => "voc",
		6 => "loc",
		7 => "ins"
	}],
	e => ["negativeness", {
		A => "pos",
		N => "neg"
	}],
	d => ["degree", {
		1 => "pos",
		2 => "comp",
		3 => "sup"
	}],
	x => {
		k1 => [undef, {
			P => undef
		}],
		k3 => ["prontype", {
			P => sub {
				my $f = shift;

				$f->{prontype} = "prs";
				$f->{subpos} = "pers";
			},
			O => sub {
				my $f = shift;

				$f->{prontype} = "dem";
				$f->{poss} = "poss";
			},
			D => "dem",
			T => sub {
				my $f = shift;

				$f->{prontype} = "dem";
				$f->{other} = "ajka-lim";
			},
			Q => sub {
				my $f = shift;

				$f->{prontype} = "int";
				$f->{other} = "ajka-x";
			},
			R => sub {
				my $f = shift;

				$f->{prontype} = "rel";
				$f->{other} = "ajka-x";
			},
			U => sub {
				my $f = shift;

				$f->{prontype} = "ind";
				$f->{other} = "ajka-x";
			},
			N => sub {
				my $f = shift;

				$f->{prontype} = "neg";
				$f->{other} = "ajka-x";
			},
			X => sub {
				my $f = shift;

				$f->{reflex} = "reflex";
				$f->{other} = "ajka-x";
			}
		}],
		k4 => ["subpos", {
			C => "card",
			O => "ord",
			R => sub {
				my $f = shift;

				$f->{other} = "ajka-gen";
			},
			#G => "gramatika",
			#H => "gramatika",
			D => sub {
				my $f = shift;

				$f->{prontype} = "dem";
			},
			T => sub {
				my $f = shift;

				$f->{prontype} = "dem";
				$f->{other} = "ajka-lim";
			},
			N => "prop"
		}],
		k6 => ["subpos", {
			D => sub {
				my $f = shift;

				$f->{prontype} = "dem";
			},
			T => sub {
				my $f = shift;

				$f->{prontype} = "dem";
				$f->{other} = "ajka-lim";
			},
			M => "man",
			#S => undef,
			Q => "deg",
			#R => undef,
			L => "loc",
			#T => "tim", # Kollision
			C => "cau",
			#D => "mod" # Kollision
		}],
		k8 => ["subpos", {
			C => "coor",
			S => "sub"
		}]
	},
	y => {
		k3 => ["prontype", {
			F => sub {
				my $f = shift;

				$f->{reflex} = "reflex";
				$f->{other} = "ajka-y";
			},
			Q => sub {
				my $f = shift;

				$f->{prontype} = "int";
				$f->{other} = "ajka-y";
			},
			R => sub {
				my $f = shift;

				$f->{prontype} = "rel";
				$f->{other} = "ajka-y";
			},
			N => sub {
				my $f = shift;

				$f->{prontype} = "neg";
				$f->{other} = "ajka-y";
			},
			I => sub {
				my $f = shift;

				$f->{prontype} = "ind";
				$f->{other} = "ajka-y";
			}
		}],
		k4 => ["prontype", {
			Q => sub {
				my $f = shift;

				$f->{prontype} = "int";
				$f->{other} = "ajka-y";
			},
			R => sub {
				my $f = shift;

				$f->{prontype} = "rel";
				$f->{other} = "ajka-y";
			},
			N => sub {
				my $f = shift;

				$f->{prontype} = "neg";
				$f->{other} = "ajka-y";
			},
			I => sub {
				my $f = shift;

				$f->{prontype} = "ind";
				$f->{other} = "ajka-y";
			}
		}],
		k6 => ["prontype", {
			Q => sub {
				my $f = shift;

				$f->{prontype} = "int";
				$f->{other} = "ajka-y";
			},
			R => sub {
				my $f = shift;

				$f->{prontype} = "rel";
				$f->{other} = "ajka-y";
			},
			N => sub {
				my $f = shift;

				$f->{prontype} = "neg";
				$f->{other} = "ajka-y";
			},
			I => sub {
				my $f = shift;

				$f->{prontype} = "ind";
				$f->{other} = "ajka-y";
			}
		}]
	},
	p => ["person", {
		1 => "1",
		2 => "2",
		3 => "3",
		X => "1,2,3", # ??? ad hoc
		M => "1,2,3", # ??? ad hoc
		I => "1,2,3" # ??? ad hoc
	}],
	a => ["aspect", {
		P => "perf",
		I => "imp",
		B => "perf,imp" # ??? Sauber genug
	}],
	t => {
		k5 => ["tense", {
			M => "past",
			#P => "pres",
			P => sub {
				my $f = shift;

				$f->{tense} = "pres";
				$f->{other} = "ajka-tP";
			},
			F => "fut"
		}],
		k6 => ["subpos", {
			Q => "deg",
			#A => undef,
			L => "loc",
			T => "tim",
			C => "cau",
			M => "man",
			D => "mod",
			#S => undef
		}]
	},
	m => {
		k5 => [undef, {
			F => sub {
				my $f = shift;

				$f->{verbform} = "inf";
			},
			I => sub {
				my $f = shift;

				$f->{mood} = "ind";
				$f->{tense} = "pres";
			},
			R => sub {
				my $f = shift;

				$f->{mood} = "imp";
			},
			A => sub {
				my $f = shift;

				$f->{verbform} = "part";
				$f->{voice} = "act";
			},
			N => sub {
				my $f = shift;

				$f->{verbform} = "part";
				$f->{voice} = "pass";
			},
			S => sub {
				my $f = shift;

				$f->{verbform} = "trans";
				$f->{tense} = "pres";
			},
			D => sub {
				my $f = shift;

				$f->{verbform} = "trans";
				$f->{tense} = "past";
			},
			B => sub {
				my $f = shift;

				$f->{mood} = "ind";
				$f->{tense} = "fut";
			},
			P => sub {
				my $f = shift;

				$f->{verbform} = "part";
			},
			T => sub {
				my $f = shift;

				$f->{verbform} = "trans";
			},
			C => sub {
				my $f = shift;

				$f->{mood} = "cnd";
			},
			K => sub {
				my $f = shift;

				$f->{mood} = "sub";
			}
		}],
		kY => ["mood", {
			C => "cnd"
		}]
	},
	#z => ["typ tvaru", {
	#	S => "tvar s příklonným -s"
	#}]
);


#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
	my $tag_string = shift;
	my %f;				# features
	$f{tagset} = "cs::ajka";

	my @parts = split(/([a-z][A-Z0-9])/, $tag_string);
	#my @out;
	my $kat;

	foreach my $e (@parts) {
		next if $e =~ /^\s*$/;

		my $correct = $e =~ /^([a-z])(.)$/;
		my $tag_name = $1;
		my $tag_value = $2;

		$kat = $e if $tag_name eq "k";

		unless ($correct) {
			#push @out, "($e)";
		} else {
			if (exists $tag_system{$tag_name}) {
				if (ref($tag_system{$tag_name}) eq "HASH") {
					if ($tag_system{$tag_name}{$kat}[1]{$tag_value} !~ /^CODE/) {
						$f{$tag_system{$tag_name}{$kat}[0]} =
							$tag_system{$tag_name}{$kat}[1]{$tag_value};
					} else {
						$tag_system{$tag_name}{$kat}[1]{$tag_value}->(\%f);
					}

				} else {
					if ($tag_system{$tag_name}[1]{$tag_value} !~ /^CODE/) {
						$f{$tag_system{$tag_name}[0]} =
							$tag_system{$tag_name}[1]{$tag_value};
					} else {
						$tag_system{$tag_name}[1]{$tag_value}->(\%f);
					}
				}
				#my $f;
				#if (ref($tag_system{$tag_name}) eq "HASH") {
				#	$f = $tag_system{$tag_name}{$kat}[0] . "=" .
				#		$tag_system{$tag_name}{$kat}[1]{$tag_value};
				#} else {
				#	$f = $tag_system{$tag_name}[0] . "=" .
				#		$tag_system{$tag_name}[1]{$tag_value};
				#}
				#push @out, $f;
				 
			} else {
				#push @out, "{$e}";
			}
		}		
	}
	#return "[" . join(",", @out) . "]";
	return \%f;
}

my %encoding = (
	noun => ["k1", ["g", "n", "c", "x"]],
	adj => ["k2", ["e", "g", "n", "c", "d"]],
	num => ["k4", ["x", "y", "g", "n", "c"]],
	verb => ["k5",["e", "a", "m", "p", "g", "n", "t"]],
	adv => ["k6",["e", "x", "y", "d"]],
	prep => ["k7", ["c"]],
	conj => ["k8", ["x"]],
	part => "k9",
	"int" => "k0"
);

%case = (
	nom => 1,
	gen => 2,
	dat => 3,
	acc => 4,
	voc => 5,
	loc => 6,
	ins => 7
);

%number = (
	sing => "S",
	plu => "P",
	dual => "D",
	family => "R"
);

%negativeness = (
	"pos" => "A",
	"neg" => "N",
);

%degree = (
	"pos" => 1,
	"comp" => 2,
	"sup" => 3
);

%aspect = (
	perf => "P",
	imp => "I",
	"perf,imp" => "B"
);

%gender = (
	fem => "F",
	mascanim => "M",
	mascinan => "I",
	neut => "N",
	anim => "P",
	inan => "T",
	"masc,neutinan" => "Y",
	"masc,neut" => "U",
	family => "R"
);

%tense = (
	past => "M",
	pres => "P",
	fut => "F"
);

%subpos = (
	deg => "Q",
	loc => "L",
	tim => "T",
	cau => "C",
	man => "M",
	mod => "D"
);

%verbform = (
	inf => "F",
	partact => "A",
	partpass => "N",
	part => "P",
	transpres => "S",
	transpast => "D",
	trans => "T",
);

%mood = (
	indpres => "I",
	imp => "R",
	indfut => "B",
	cnd => "C",
	"sub" => "K"
);

%prontype = (
	"int" => "Q",
	rel => "R",
	neg => "N",
	ind => "I"
);

#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
	my $f0 = shift;
	my $f = clone($f0);
	my %f = %{$f};

	my $tag_string;

	if (exists $encoding{$f{pos}}) {
		if (ref($encoding{$f{pos}}) eq "ARRAY") {
			#$tag_string = encode_tags(\%f);
			$tag_string = encode_tags(\%f, $encoding{$f{pos}}[0], @{$encoding{$f{pos}}[1]});
		} else {
			$tag_string = $encoding{$f{pos}};
		}
	} else {
		if (
			$f{prontype} eq "prs" or
			$f{prontype} eq "dem" or
			$f{prontype} eq "int" or
			$f{prontype} eq "rel" or
			$f{prontype} eq "ind" or
			$f{prontype} eq "neg" or
			$f{reflex} eq "reflex"
		) {
			$tag_string = encode_tags(\%f, "k3", "x", "y", "p", "g", "n", "c");
		} elsif ($f{abbr} eq "abbr") {
			$tag_string = encode_tags(\%f, "kA");
		} elsif ($f{other} eq "ajka-kY") {
			$tag_string = encode_tags(\%f, "kY", "m", "p", "n");
		}
	}
	
	return $tag_string;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# cat danish_ddt_train.conll ../test/danish_ddt_test.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 4288
#------------------------------------------------------------------------------
sub list
{
	# For the beginning...
	return undef;
}

sub encode_tags {
	my $f0 = shift;
	my %f = %{$f0};

	my $tag_string = shift;
	my @order = @_;

	foreach my $tag_name (@order) {
		my $tag;
		if ($tag_name eq "c" and exists $f{case}) {
			$tag = "c" . $case{$f{case}};
		} elsif ($tag_name eq "n" and exists $f{number}) {
			$tag = "n" . $number{$f{number}};
		} elsif ($tag_name eq "e" and exists $f{negativeness}) {
			$tag = "e" . $negativeness{$f{negativeness}};
		} elsif ($tag_name eq "d" and exists $f{degree}) {
			$tag = "d" . $degree{$f{degree}};
		} elsif ($tag_name eq "p" and exists $f{person}) {
			unless ($f{person} eq "1,2,3") {
				$tag = "p" . $f{person};
			} else {
				$tag = "pX";
			}
		} elsif ($tag_name eq "a" and exists $f{aspect}) {
			$tag = "a" . $aspect{$f{aspect}};
		} elsif ($tag_name eq "g" and (exists $f{gender} or exists $f{animateness})) {
			my $gender = $f{gender};
			#if ($gender eq "masc" and exists $f{animateness}) {
			$gender .= $f{animateness};
			#}
			$tag = "g" . $gender{$gender};
		} elsif ($tag_name eq "t" and exists $f{tense}) {
			unless ($f{mood} eq "ind" or $f{verbform} eq "trans") {
				$tag = "t" . $tense{$f{tense}};
			} elsif ($f{other} eq "ajka-tP") {
				$tag = "tP";
			}
		} elsif ($tag_name eq "t" and exists $f{subpos}) {
			$tag = "t" . $subpos{$f{subpos}};
		} elsif ($tag_name eq "m" and exists $f{verbform}) {
			#$tag = "m" . $verbform{$f{verbform} . $f{voice} . $f{tense}};
			my $key;
			if ($f{verbform} eq "part") {
				$key = $f{verbform} . $f{voice};
			} elsif ($f{verbform} eq "trans") {
				$key = $f{verbform} . $f{tense};
			} else {
				$key = $f{verbform};
			}
			$tag = "m" . $verbform{$key};
		} elsif ($tag_name eq "m" and exists $f{mood}) {
			my $key;
			if ($f{mood} eq "ind") {
				$key = $f{mood} . $f{tense};
			} else {
				$key = $f{mood};
			}
			$tag = "m" . $mood{$key};
		} elsif ($tag_name eq "x" and exists $f{prontype}) {
			if ($f{prontype} eq "prs" and $f{subpos} eq "pers") {
				$tag = "xP";
			} elsif ($f{prontype} eq "prs" and $f{reflex} eq "reflex" and $f{other} eq "ajka-x") { # k3xX has $f{prontype} eq "prs"
				$tag = "xX";
			#} elsif ($f{prontype} eq "dem" and $f{poss} eq "poss") {
			} elsif ($f{poss} eq "poss") {
				$tag = "xO";
			} else {
				if ($f{prontype} eq "dem" and $f{other} eq "ajka-lim") {
					$tag = "xT";
				} elsif ($f{prontype} eq "dem") {
					$tag = "xD";
				} elsif ($f{prontype} eq "int" and $f{other} eq "ajka-x") {
					$tag = "xQ";
				} elsif ($f{prontype} eq "rel" and $f{other} eq "ajka-x") {
					$tag = "xR";
				} elsif ($f{prontype} eq "ind" and $f{other} eq "ajka-x") {
					$tag = "xU";
				} elsif ($f{prontype} eq "neg" and $f{other} eq "ajka-x") {
					$tag = "xN";
				}
			}
		} elsif ($tag_name eq "x" and exists $f{reflex} and $f{other} eq "ajka-x") { # TODO: Defaults to x or y in the conversion of other tagsets?
			if ($f{reflex} eq "reflex") {
				$tag = "xX";
			}
		} elsif ($tag_name eq "x" and $f{other} eq "ajka-gen" and $f{"pos"} eq "num") {
			$tag = "xR";
		} elsif ($tag_name eq "x" and exists $f{subpos}) {
			if ($f{subpos} eq "card") {
				$tag = "xC";
			} elsif ($f{subpos} eq "ord") {
				$tag = "xO";
			} elsif ($f{subpos} eq "prop") {
				$tag = "xN";
			} elsif ($f{subpos} eq "man") {
				$tag = "xM";
			} elsif ($f{subpos} eq "deg") {
				$tag = "xQ";
			} elsif ($f{subpos} eq "loc") {
				$tag = "xL";
			} elsif ($f{subpos} eq "cau") {
				$tag = "xC";
			} elsif ($f{subpos} eq "coor") {
				$tag = "xC";
			} elsif ($f{subpos} eq "sub") {
				$tag = "xS";
			}
		} elsif ($tag_name eq "y" and exists $f{reflex} and $f{other} eq "ajka-y") {
			if ($f{reflex} eq "reflex") {
				$tag = "yF";
			}
		} elsif ($tag_name eq "y" and exists $f{prontype} and $f{other} eq "ajka-y") {
			$tag = "y" . $prontype{$f{prontype}};
		}

		# check if the generated tag can be used
		if ($tag =~ /^[a-z][A-Z0-9]$/) {
			$tag_string .= $tag;
		#} elsif ($tag !~ /^\s*$/) {
		#	print "malformed tag string: $tag_string\[$tag\]\n";
		}
	}

	return $tag_string;
}
