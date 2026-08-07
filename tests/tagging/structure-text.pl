#!/usr/bin/env perl
# structure-text.pl -- decode the literal text of each marked-content run in a
# tagged PDF, so a check can assert on what a structure-aware consumer reads.
#
# Issue #302. Every other extraction check in this repository asks an extractor
# (Poppler, MuPDF, PDFKit) what the page says, and every one of them rebuilds
# words and lines from glyph *geometry*. That is precisely the wrong instrument
# for a defect in the *logical* text of a structure element: an entry heading
# whose title and dates are glued together with no separating character still
# extracts as two lines, because Poppler sees the horizontal gap and splits on
# it. The concatenation is invisible to the entire existing suite.
#
# This script therefore reads the content stream itself:
#
#   /<tag><</MCID n>> BDC  ...  EMC
#
# and decodes the enclosed `Tj'/`TJ' glyph codes through the embedded
# `/ToUnicode' CMap of whichever font each `Tf' selected -- the same path a
# consumer that walks /StructTreeRoot -> /K -> /MCR -> /MCID takes. No glyph
# position is consulted, so a gap produced by `\hfill' or `\\' contributes
# nothing: only real characters appear in the output.
#
# It deliberately does NOT inflate a TJ kern into a space. A space in the
# output is a space in the PDF. That is the whole point.
#
# Output, one marked-content run per line, in page and content-stream order:
#
#   <page>\t<mcid>\t<tag>\t<decoded text>
#
# Requires the input to be an uncompressed PDF: the tagging fixtures set
# `\pdfvariable compresslevel=0' and `objcompresslevel=0' for exactly this
# reason, so no Flate decoder (and so no non-core Perl module) is needed. A
# compressed file is reported as an error rather than silently yielding
# nothing, because "no runs found" is otherwise indistinguishable from "the
# defect is fixed".

use strict;
use warnings;

my $path = shift @ARGV or die "usage: structure-text.pl <uncompressed.pdf>\n";
open my $fh, '<:raw', $path or die "open $path: $!\n";
my $pdf = do { local $/; <$fh> };
close $fh;

# --- objects ---------------------------------------------------------------
my %obj;
while ($pdf =~ /(\d+)\s+0\s+obj\b(.*?)\bendobj/gs) {
  $obj{$1} = $2;
}
die "$path: no indirect objects found; not a PDF?\n" unless %obj;

if ($pdf =~ m{/ObjStm}) {
  die "$path: contains object streams; rerun with objcompresslevel=0\n";
}

sub stream_of {
  my ($body) = @_;
  return undef unless defined $body;
  return $1 if $body =~ /stream\r?\n(.*?)\r?\nendstream/s;
  return undef;
}

# --- /ToUnicode CMaps ------------------------------------------------------
sub parse_cmap {
  my ($text) = @_;
  my %map;
  while ($text =~ /beginbfchar(.*?)endbfchar/gs) {
    my $block = $1;
    while ($block =~ /<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>/g) {
      my ($src, $dst) = ($1, $2);
      $map{hex $src} = join '', map { chr hex } ($dst =~ /(....)/g);
    }
  }
  while ($text =~ /beginbfrange(.*?)endbfrange/gs) {
    my $block = $1;
    while ($block =~ /<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>/g) {
      my ($lo, $hi, $dst) = (hex $1, hex $2, hex $3);
      $map{$_} = chr($dst + $_ - $lo) for $lo .. $hi;
    }
  }
  return \%map;
}

my %cmap_for_obj;
sub cmap_for_font_obj {
  my ($num) = @_;
  return $cmap_for_obj{$num} if exists $cmap_for_obj{$num};
  my $map = {};
  my $body = $obj{$num};
  if (defined $body && $body =~ m{/ToUnicode\s+(\d+)\s+0\s+R}) {
    my $stream = stream_of($obj{$1});
    $map = parse_cmap($stream) if defined $stream;
  }
  return $cmap_for_obj{$num} = $map;
}

# --- pages -----------------------------------------------------------------
# Page objects appear in document order in the fixtures' output; sort by object
# number so the ordering is a property of the file rather than of the regex.
my @pages;
for my $num (sort { $a <=> $b } keys %obj) {
  my $body = $obj{$num};
  next unless $body =~ m{/Type\s*/Page\b} && $body !~ m{/Type\s*/Pages\b};
  next unless $body =~ m{/Contents\s+(\d+)\s+0\s+R};
  my $contents = $1;
  my $resources = $body =~ m{/Resources\s+(\d+)\s+0\s+R} ? $1 : undef;
  push @pages, [ $contents, $resources ];
}
die "$path: no page objects found\n" unless @pages;

# --- decode ----------------------------------------------------------------
my $page_number = 0;
my $found = 0;

for my $page (@pages) {
  my ($contents, $resources) = @$page;
  $page_number++;

  my %font;    # resource name -> ToUnicode map
  if (defined $resources && defined $obj{$resources}) {
    my $dict = $obj{$resources};
    if ($dict =~ m{/Font\s*<<(.*?)>>}s) {
      my $fonts = $1;
      while ($fonts =~ m{/(\S+?)\s+(\d+)\s+0\s+R}g) {
        $font{$1} = cmap_for_font_obj($2);
      }
    }
  }

  my $stream = stream_of($obj{$contents});
  next unless defined $stream;

  my ($tag, $mcid, $text, $current);
  my $cmap = {};

  # One pass over the operators that matter. Anything else is skipped, so an
  # unrecognised operator cannot silently swallow a text run.
  while ($stream =~ m{
        /([A-Za-z][\w.-]*) \s* << ([^<>]*(?:<<[^>]*>>[^<>]*)*) >> \s* BDC
      | /([A-Za-z][\w.-]*) \s+ BMC
      | \b EMC \b
      | /([A-Za-z][\w.-]*) \s+ [\d.]+ \s+ Tf
      | \[ ( (?: [^\[\]] | \[[^\]]*\] )* ) \] \s* TJ
      | < ([0-9A-Fa-f\s]*) > \s* Tj
      | \( ( (?: \\. | [^\\()] )* ) \) \s* Tj
    }gsx) {

    my ($bdc_tag, $bdc_dict, $bmc_tag, $tf, $tj, $tj_hex, $tj_lit) =
      ($1, $2, $3, $4, $5, $6, $7);

    if (defined $bdc_tag) {
      # Flush any run already open: BDC blocks are not nested in this output,
      # but an unbalanced stream must not merge two runs into one.
      emit($page_number, $mcid, $tag, $text) if defined $current;
      if (defined $bdc_dict && $bdc_dict =~ m{/MCID\s+(\d+)}) {
        ($tag, $mcid, $text, $current) = ($bdc_tag, $1, '', 1);
      } else {
        ($tag, $mcid, $text, $current) = (undef, undef, undef, undef);
      }
    }
    elsif (defined $bmc_tag) {
      emit($page_number, $mcid, $tag, $text) if defined $current;
      ($tag, $mcid, $text, $current) = (undef, undef, undef, undef);
    }
    elsif (defined $tf) {
      $cmap = $font{$tf} || {};
    }
    elsif (defined $tj) {
      next unless defined $current;
      while ($tj =~ /<([0-9A-Fa-f\s]*)>/g) {
        $text .= decode_hex($1, $cmap);
      }
    }
    elsif (defined $tj_hex) {
      next unless defined $current;
      $text .= decode_hex($tj_hex, $cmap);
    }
    elsif (defined $tj_lit) {
      # Literal strings do not occur in this engine's output, but decoding
      # them as raw bytes is better than dropping the run.
      next unless defined $current;
      my $literal = $tj_lit;
      $literal =~ s/\\([nrtbf()\\])/$1 eq 'n' ? "\n" : $1 eq 'r' ? "\r" : $1/ge;
      $text .= $literal;
    }
    else {
      # EMC
      emit($page_number, $mcid, $tag, $text) if defined $current;
      ($tag, $mcid, $text, $current) = (undef, undef, undef, undef);
    }
  }
  emit($page_number, $mcid, $tag, $text) if defined $current;
}

die "$path: no marked-content runs decoded; is the document tagged?\n"
  unless $found;

sub decode_hex {
  my ($hex, $map) = @_;
  $hex =~ s/\s+//g;
  my $out = '';
  for my $code ($hex =~ /(....)/g) {
    my $value = hex $code;
    $out .= exists $map->{$value} ? $map->{$value} : sprintf('<U+?%04X>', $value);
  }
  return $out;
}

sub emit {
  my ($page, $mcid, $tag, $text) = @_;
  return unless defined $mcid;
  $found = 1;
  $text = '' unless defined $text;
  # Keep the text on one line so callers can grep it; a decoded newline would
  # be a defect in its own right and is made visible rather than printed.
  $text =~ s/\n/\\n/g;
  binmode STDOUT, ':encoding(UTF-8)';
  print "$page\t$mcid\t$tag\t$text\n";
}
