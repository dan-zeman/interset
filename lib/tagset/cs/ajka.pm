#!/usr/bin/perl
# This Interset driver created by Petr Poøízka, Markus Schäfer and Daniel Zeman
# For more on Ajka, see http://nlp.fi.muni.cz/projekty/ajka/ajkacz.htm

package tagset::cs::ajka;
use utf8;

use tagset::common;

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
	#	S => "tvar s pÅ™Ã­klonnÃ½m -s"
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
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    # Modify the feature structure so that it contains values expected by this
    # driver.
    my $f = tagset::common::enforce_permitted_joint($f0, $permitted);
    my %f = %{$f}; # This is not a deep copy but $f already refers to a deep copy of the original %{$f0}.

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



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# I have no official list of tags that can be generated by Ajka. So I took all
# PDT tags, converted them to Ajka, removed duplicates and put the result here.
# So this list lacks features that are in Ajka and are not in PDT.
# Count: 4294 PDT tags --> 846 Ajka tags
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
k0
k1
k1c1
k1c2
k1c3
k1c4
k1c5
k1c6
k1c7
k1gF
k1gFnDc7
k1gFnP
k1gFnPc1
k1gFnPc2
k1gFnPc3
k1gFnPc4
k1gFnPc5
k1gFnPc6
k1gFnPc7
k1gFnS
k1gFnSc1
k1gFnSc2
k1gFnSc3
k1gFnSc4
k1gFnSc5
k1gFnSc6
k1gFnSc7
k1gI
k1gInP
k1gInPc1
k1gInPc2
k1gInPc3
k1gInPc4
k1gInPc5
k1gInPc6
k1gInPc7
k1gInS
k1gInSc1
k1gInSc2
k1gInSc3
k1gInSc4
k1gInSc5
k1gInSc6
k1gInSc7
k1gM
k1gMc1
k1gMc2
k1gMc3
k1gMc4
k1gMc5
k1gMc6
k1gMc7
k1gMnP
k1gMnPc1
k1gMnPc2
k1gMnPc3
k1gMnPc4
k1gMnPc5
k1gMnPc6
k1gMnPc7
k1gMnS
k1gMnSc1
k1gMnSc2
k1gMnSc3
k1gMnSc4
k1gMnSc5
k1gMnSc6
k1gMnSc7
k1gN
k1gNnP
k1gNnPc1
k1gNnPc2
k1gNnPc3
k1gNnPc4
k1gNnPc5
k1gNnPc6
k1gNnPc7
k1gNnS
k1gNnSc1
k1gNnSc2
k1gNnSc3
k1gNnSc4
k1gNnSc5
k1gNnSc6
k1gNnSc7
k1nP
k1nPc1
k1nPc2
k1nPc3
k1nPc4
k1nPc5
k1nPc6
k1nPc7
k1nS
k1nSc1
k1nSc2
k1nSc3
k1nSc4
k1nSc5
k1nSc6
k1nSc7
k2
k2eA
k2eAd1
k2eAd2
k2eAd3
k2eAgFd1
k2eAgFnDc7
k2eAgFnDc7d1
k2eAgFnDc7d2
k2eAgFnDc7d3
k2eAgFnPc1
k2eAgFnPc1d1
k2eAgFnPc1d2
k2eAgFnPc1d3
k2eAgFnPc2
k2eAgFnPc2d1
k2eAgFnPc2d2
k2eAgFnPc2d3
k2eAgFnPc3
k2eAgFnPc3d1
k2eAgFnPc3d2
k2eAgFnPc3d3
k2eAgFnPc4
k2eAgFnPc4d1
k2eAgFnPc4d2
k2eAgFnPc4d3
k2eAgFnPc5
k2eAgFnPc5d1
k2eAgFnPc5d2
k2eAgFnPc5d3
k2eAgFnPc6
k2eAgFnPc6d1
k2eAgFnPc6d2
k2eAgFnPc6d3
k2eAgFnPc7
k2eAgFnPc7d1
k2eAgFnPc7d2
k2eAgFnPc7d3
k2eAgFnSc1
k2eAgFnSc1d1
k2eAgFnSc1d2
k2eAgFnSc1d3
k2eAgFnSc2
k2eAgFnSc2d1
k2eAgFnSc2d2
k2eAgFnSc2d3
k2eAgFnSc3
k2eAgFnSc3d1
k2eAgFnSc3d2
k2eAgFnSc3d3
k2eAgFnSc4
k2eAgFnSc4d1
k2eAgFnSc4d2
k2eAgFnSc4d3
k2eAgFnSc5
k2eAgFnSc5d1
k2eAgFnSc5d2
k2eAgFnSc5d3
k2eAgFnSc6
k2eAgFnSc6d1
k2eAgFnSc6d2
k2eAgFnSc6d3
k2eAgFnSc7
k2eAgFnSc7d1
k2eAgFnSc7d2
k2eAgFnSc7d3
k2eAgFnSd1
k2eAgId1
k2eAgInPc1
k2eAgInPc1d1
k2eAgInPc1d2
k2eAgInPc1d3
k2eAgInPc2
k2eAgInPc2d1
k2eAgInPc2d2
k2eAgInPc2d3
k2eAgInPc3
k2eAgInPc3d1
k2eAgInPc3d2
k2eAgInPc3d3
k2eAgInPc4
k2eAgInPc4d1
k2eAgInPc4d2
k2eAgInPc4d3
k2eAgInPc5
k2eAgInPc5d1
k2eAgInPc5d2
k2eAgInPc5d3
k2eAgInPc6
k2eAgInPc6d1
k2eAgInPc6d2
k2eAgInPc6d3
k2eAgInPc7
k2eAgInPc7d1
k2eAgInPc7d2
k2eAgInPc7d3
k2eAgInPd1
k2eAgInPd2
k2eAgInPd3
k2eAgInSc1
k2eAgInSc1d1
k2eAgInSc1d2
k2eAgInSc1d3
k2eAgInSc2
k2eAgInSc2d1
k2eAgInSc2d2
k2eAgInSc2d3
k2eAgInSc3
k2eAgInSc3d1
k2eAgInSc3d2
k2eAgInSc3d3
k2eAgInSc4
k2eAgInSc4d1
k2eAgInSc4d2
k2eAgInSc4d3
k2eAgInSc5
k2eAgInSc5d1
k2eAgInSc5d2
k2eAgInSc5d3
k2eAgInSc6
k2eAgInSc6d1
k2eAgInSc6d2
k2eAgInSc6d3
k2eAgInSc7
k2eAgInSc7d1
k2eAgInSc7d2
k2eAgInSc7d3
k2eAgInSd1
k2eAgMnP
k2eAgMnPc1
k2eAgMnPc1d1
k2eAgMnPc1d2
k2eAgMnPc1d3
k2eAgMnPc2
k2eAgMnPc2d1
k2eAgMnPc2d2
k2eAgMnPc2d3
k2eAgMnPc3
k2eAgMnPc3d1
k2eAgMnPc3d2
k2eAgMnPc3d3
k2eAgMnPc4
k2eAgMnPc4d1
k2eAgMnPc4d2
k2eAgMnPc4d3
k2eAgMnPc5
k2eAgMnPc5d1
k2eAgMnPc5d2
k2eAgMnPc5d3
k2eAgMnPc6
k2eAgMnPc6d1
k2eAgMnPc6d2
k2eAgMnPc6d3
k2eAgMnPc7
k2eAgMnPc7d1
k2eAgMnPc7d2
k2eAgMnPc7d3
k2eAgMnSc1
k2eAgMnSc1d1
k2eAgMnSc1d2
k2eAgMnSc1d3
k2eAgMnSc2
k2eAgMnSc2d1
k2eAgMnSc2d2
k2eAgMnSc2d3
k2eAgMnSc3
k2eAgMnSc3d1
k2eAgMnSc3d2
k2eAgMnSc3d3
k2eAgMnSc4
k2eAgMnSc4d1
k2eAgMnSc4d2
k2eAgMnSc4d3
k2eAgMnSc5
k2eAgMnSc5d1
k2eAgMnSc5d2
k2eAgMnSc5d3
k2eAgMnSc6
k2eAgMnSc6d1
k2eAgMnSc6d2
k2eAgMnSc6d3
k2eAgMnSc7
k2eAgMnSc7d1
k2eAgMnSc7d2
k2eAgMnSc7d3
k2eAgMnSd1
k2eAgNnDc7
k2eAgNnDc7d1
k2eAgNnDc7d2
k2eAgNnDc7d3
k2eAgNnPc1
k2eAgNnPc1d1
k2eAgNnPc1d2
k2eAgNnPc1d3
k2eAgNnPc2
k2eAgNnPc2d1
k2eAgNnPc2d2
k2eAgNnPc2d3
k2eAgNnPc3
k2eAgNnPc3d1
k2eAgNnPc3d2
k2eAgNnPc3d3
k2eAgNnPc4
k2eAgNnPc4d1
k2eAgNnPc4d2
k2eAgNnPc4d3
k2eAgNnPc5
k2eAgNnPc5d1
k2eAgNnPc5d2
k2eAgNnPc5d3
k2eAgNnPc6
k2eAgNnPc6d1
k2eAgNnPc6d2
k2eAgNnPc6d3
k2eAgNnPc7
k2eAgNnPc7d1
k2eAgNnPc7d2
k2eAgNnPc7d3
k2eAgNnS
k2eAgNnSc1
k2eAgNnSc1d1
k2eAgNnSc1d2
k2eAgNnSc1d3
k2eAgNnSc2
k2eAgNnSc2d1
k2eAgNnSc2d2
k2eAgNnSc2d3
k2eAgNnSc3
k2eAgNnSc3d1
k2eAgNnSc3d2
k2eAgNnSc3d3
k2eAgNnSc4
k2eAgNnSc4d1
k2eAgNnSc4d2
k2eAgNnSc4d3
k2eAgNnSc5
k2eAgNnSc5d1
k2eAgNnSc5d2
k2eAgNnSc5d3
k2eAgNnSc6
k2eAgNnSc6d1
k2eAgNnSc6d2
k2eAgNnSc6d3
k2eAgNnSc7
k2eAgNnSc7d1
k2eAgNnSc7d2
k2eAgNnSc7d3
k2eAgNnSd1
k2eAnP
k2eAnPd1
k2eAnS
k2eN
k2eNd1
k2eNgFd1
k2eNgFnDc7
k2eNgFnDc7d1
k2eNgFnDc7d2
k2eNgFnDc7d3
k2eNgFnPc1
k2eNgFnPc1d1
k2eNgFnPc1d2
k2eNgFnPc1d3
k2eNgFnPc2
k2eNgFnPc2d1
k2eNgFnPc2d2
k2eNgFnPc2d3
k2eNgFnPc3
k2eNgFnPc3d1
k2eNgFnPc3d2
k2eNgFnPc3d3
k2eNgFnPc4
k2eNgFnPc4d1
k2eNgFnPc4d2
k2eNgFnPc4d3
k2eNgFnPc5
k2eNgFnPc5d1
k2eNgFnPc5d2
k2eNgFnPc5d3
k2eNgFnPc6
k2eNgFnPc6d1
k2eNgFnPc6d2
k2eNgFnPc6d3
k2eNgFnPc7
k2eNgFnPc7d1
k2eNgFnPc7d2
k2eNgFnPc7d3
k2eNgFnSc1
k2eNgFnSc1d1
k2eNgFnSc1d2
k2eNgFnSc1d3
k2eNgFnSc2
k2eNgFnSc2d1
k2eNgFnSc2d2
k2eNgFnSc2d3
k2eNgFnSc3
k2eNgFnSc3d1
k2eNgFnSc3d2
k2eNgFnSc3d3
k2eNgFnSc4
k2eNgFnSc4d1
k2eNgFnSc4d2
k2eNgFnSc4d3
k2eNgFnSc5
k2eNgFnSc5d1
k2eNgFnSc5d2
k2eNgFnSc5d3
k2eNgFnSc6
k2eNgFnSc6d1
k2eNgFnSc6d2
k2eNgFnSc6d3
k2eNgFnSc7
k2eNgFnSc7d1
k2eNgFnSc7d2
k2eNgFnSc7d3
k2eNgInPc1
k2eNgInPc1d1
k2eNgInPc1d2
k2eNgInPc1d3
k2eNgInPc2
k2eNgInPc2d1
k2eNgInPc2d2
k2eNgInPc2d3
k2eNgInPc3
k2eNgInPc3d1
k2eNgInPc3d2
k2eNgInPc3d3
k2eNgInPc4
k2eNgInPc4d1
k2eNgInPc4d2
k2eNgInPc4d3
k2eNgInPc5
k2eNgInPc5d1
k2eNgInPc5d2
k2eNgInPc5d3
k2eNgInPc6
k2eNgInPc6d1
k2eNgInPc6d2
k2eNgInPc6d3
k2eNgInPc7
k2eNgInPc7d1
k2eNgInPc7d2
k2eNgInPc7d3
k2eNgInPd1
k2eNgInPd2
k2eNgInPd3
k2eNgInSc1
k2eNgInSc1d1
k2eNgInSc1d2
k2eNgInSc1d3
k2eNgInSc2
k2eNgInSc2d1
k2eNgInSc2d2
k2eNgInSc2d3
k2eNgInSc3
k2eNgInSc3d1
k2eNgInSc3d2
k2eNgInSc3d3
k2eNgInSc4
k2eNgInSc4d1
k2eNgInSc4d2
k2eNgInSc4d3
k2eNgInSc5
k2eNgInSc5d1
k2eNgInSc5d2
k2eNgInSc5d3
k2eNgInSc6
k2eNgInSc6d1
k2eNgInSc6d2
k2eNgInSc6d3
k2eNgInSc7
k2eNgInSc7d1
k2eNgInSc7d2
k2eNgInSc7d3
k2eNgMnP
k2eNgMnPc1
k2eNgMnPc1d1
k2eNgMnPc1d2
k2eNgMnPc1d3
k2eNgMnPc2
k2eNgMnPc2d1
k2eNgMnPc2d2
k2eNgMnPc2d3
k2eNgMnPc3
k2eNgMnPc3d1
k2eNgMnPc3d2
k2eNgMnPc3d3
k2eNgMnPc4
k2eNgMnPc4d1
k2eNgMnPc4d2
k2eNgMnPc4d3
k2eNgMnPc5
k2eNgMnPc5d1
k2eNgMnPc5d2
k2eNgMnPc5d3
k2eNgMnPc6
k2eNgMnPc6d1
k2eNgMnPc6d2
k2eNgMnPc6d3
k2eNgMnPc7
k2eNgMnPc7d1
k2eNgMnPc7d2
k2eNgMnPc7d3
k2eNgMnSc1
k2eNgMnSc1d1
k2eNgMnSc1d2
k2eNgMnSc1d3
k2eNgMnSc2
k2eNgMnSc2d1
k2eNgMnSc2d2
k2eNgMnSc2d3
k2eNgMnSc3
k2eNgMnSc3d1
k2eNgMnSc3d2
k2eNgMnSc3d3
k2eNgMnSc4
k2eNgMnSc4d1
k2eNgMnSc4d2
k2eNgMnSc4d3
k2eNgMnSc5
k2eNgMnSc5d1
k2eNgMnSc5d2
k2eNgMnSc5d3
k2eNgMnSc6
k2eNgMnSc6d1
k2eNgMnSc6d2
k2eNgMnSc6d3
k2eNgMnSc7
k2eNgMnSc7d1
k2eNgMnSc7d2
k2eNgMnSc7d3
k2eNgNnDc7
k2eNgNnDc7d1
k2eNgNnDc7d2
k2eNgNnDc7d3
k2eNgNnPc1
k2eNgNnPc1d1
k2eNgNnPc1d2
k2eNgNnPc1d3
k2eNgNnPc2
k2eNgNnPc2d1
k2eNgNnPc2d2
k2eNgNnPc2d3
k2eNgNnPc3
k2eNgNnPc3d1
k2eNgNnPc3d2
k2eNgNnPc3d3
k2eNgNnPc4
k2eNgNnPc4d1
k2eNgNnPc4d2
k2eNgNnPc4d3
k2eNgNnPc5
k2eNgNnPc5d1
k2eNgNnPc5d2
k2eNgNnPc5d3
k2eNgNnPc6
k2eNgNnPc6d1
k2eNgNnPc6d2
k2eNgNnPc6d3
k2eNgNnPc7
k2eNgNnPc7d1
k2eNgNnPc7d2
k2eNgNnPc7d3
k2eNgNnS
k2eNgNnSc1
k2eNgNnSc1d1
k2eNgNnSc1d2
k2eNgNnSc1d3
k2eNgNnSc2
k2eNgNnSc2d1
k2eNgNnSc2d2
k2eNgNnSc2d3
k2eNgNnSc3
k2eNgNnSc3d1
k2eNgNnSc3d2
k2eNgNnSc3d3
k2eNgNnSc4
k2eNgNnSc4d1
k2eNgNnSc4d2
k2eNgNnSc4d3
k2eNgNnSc5
k2eNgNnSc5d1
k2eNgNnSc5d2
k2eNgNnSc5d3
k2eNgNnSc6
k2eNgNnSc6d1
k2eNgNnSc6d2
k2eNgNnSc6d3
k2eNgNnSc7
k2eNgNnSc7d1
k2eNgNnSc7d2
k2eNgNnSc7d3
k2eNnP
k2eNnPd1
k2eNnS
k2gFnDc7
k2gFnP
k2gFnPc1
k2gFnPc2
k2gFnPc3
k2gFnPc4
k2gFnPc5
k2gFnPc6
k2gFnPc7
k2gFnS
k2gFnSc1
k2gFnSc2
k2gFnSc3
k2gFnSc4
k2gFnSc5
k2gFnSc6
k2gFnSc7
k2gInP
k2gInPc1
k2gInPc2
k2gInPc3
k2gInPc4
k2gInPc5
k2gInPc6
k2gInPc7
k2gInS
k2gInSc1
k2gInSc2
k2gInSc3
k2gInSc4
k2gInSc5
k2gInSc6
k2gInSc7
k2gMnP
k2gMnPc1
k2gMnPc2
k2gMnPc3
k2gMnPc4
k2gMnPc5
k2gMnPc6
k2gMnPc7
k2gMnS
k2gMnSc1
k2gMnSc2
k2gMnSc3
k2gMnSc4
k2gMnSc5
k2gMnSc6
k2gMnSc7
k2gNnDc7
k2gNnP
k2gNnPc1
k2gNnPc2
k2gNnPc3
k2gNnPc4
k2gNnPc5
k2gNnPc6
k2gNnPc7
k2gNnS
k2gNnSc1
k2gNnSc2
k2gNnSc3
k2gNnSc4
k2gNnSc5
k2gNnSc6
k2gNnSc7
k2nDc7
k2nP
k2nPc1
k2nPc2
k2nPc3
k2nPc4
k2nPc5
k2nPc6
k2nPc7
k2nS
k2nSc1
k2nSc2
k2nSc3
k2nSc4
k2nSc5
k2nSc6
k2nSc7
k4
k4c1
k4c2
k4c3
k4c4
k4c5
k4c6
k4c7
k4gFnDc7
k4gFnPc1
k4gFnPc2
k4gFnPc3
k4gFnPc4
k4gFnPc5
k4gFnPc6
k4gFnPc7
k4gFnSc1
k4gFnSc2
k4gFnSc3
k4gFnSc4
k4gFnSc5
k4gFnSc6
k4gFnSc7
k4gInPc1
k4gInPc2
k4gInPc3
k4gInPc4
k4gInPc5
k4gInPc6
k4gInPc7
k4gInSc1
k4gInSc2
k4gInSc3
k4gInSc4
k4gInSc5
k4gInSc6
k4gInSc7
k4gMnPc1
k4gMnPc2
k4gMnPc3
k4gMnPc4
k4gMnPc5
k4gMnPc6
k4gMnPc7
k4gMnSc1
k4gMnSc2
k4gMnSc3
k4gMnSc4
k4gMnSc5
k4gMnSc6
k4gMnSc7
k4gNnDc7
k4gNnPc1
k4gNnPc2
k4gNnPc3
k4gNnPc4
k4gNnPc5
k4gNnPc6
k4gNnPc7
k4gNnSc1
k4gNnSc2
k4gNnSc3
k4gNnSc4
k4gNnSc5
k4gNnSc6
k4gNnSc7
k4nP
k4nPc1
k4nPc2
k4nPc3
k4nPc4
k4nPc5
k4nPc6
k4nPc7
k4nS
k4nSc1
k4nSc2
k4nSc3
k4nSc4
k4nSc5
k4nSc6
k4nSc7
k5
k5eA
k5eAaImSnP
k5eAaImSnS
k5eAaPmDnP
k5eAaPmDnS
k5eAmAgMnPtM
k5eAmAgNnStM
k5eAmAnPtM
k5eAmAnStM
k5eAmAp2gFnStM
k5eAmAp2gNnStM
k5eAmAp2nStM
k5eAmAtM
k5eAmF
k5eAmN
k5eAmNgFnS
k5eAmNgMnP
k5eAmNgNnS
k5eAmNnP
k5eAmNnS
k5eAmNp2gFnS
k5eAmNp2gNnS
k5eAmNp2nS
k5eAp1nP
k5eAp1nS
k5eAp2
k5eAp2nP
k5eAp2nS
k5eAp3nP
k5eAp3nS
k5eN
k5eNaImSnP
k5eNaImSnS
k5eNaPmDnP
k5eNaPmDnS
k5eNmAgMnPtM
k5eNmAgNnStM
k5eNmAnPtM
k5eNmAnStM
k5eNmAp2gFnStM
k5eNmAp2gNnStM
k5eNmAp2nStM
k5eNmAtM
k5eNmF
k5eNmN
k5eNmNgFnS
k5eNmNgMnP
k5eNmNgNnS
k5eNmNnP
k5eNmNnS
k5eNmNp2gFnS
k5eNmNp2gNnS
k5eNp1nP
k5eNp1nS
k5eNp2
k5eNp2nP
k5eNp2nS
k5eNp3nP
k5eNp3nS
k5p1nP
k5p1nS
k5p2nP
k5p2nS
k5p3
k6
k6eA
k6eAd1
k6eAd2
k6eAd3
k6eN
k6eNd1
k6eNd2
k6eNd3
k7
k7c1
k7c2
k7c3
k7c4
k7c6
k7c7
k8
k8xC
k8xS
k9
kA
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
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
