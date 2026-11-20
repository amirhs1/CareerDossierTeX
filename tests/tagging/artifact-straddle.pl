#!/usr/bin/env perl
# artifact-straddle.pl -- list every text-bearing layout artifact that sits
# inside one structure element's own content, in a tagged PDF.
#
# A ` | ' separator is typeset as `/Artifact<</Type /Layout>> BDC ... EMC',
# which tells assistive technology to skip it, and veraPDF UA-2 accepts it
# wherever it falls. Where it falls appears to matter. On the statement's
# application line one `text' structure element owned the marked content on
# both sides of the separator, and VoiceOver announced "vertical line" between
# the context and the application ID (#759; 2026-11-20, macOS 15.7.5,
# Preview). On the contact line each field is its own element, the separator
# falls between two elements, and VoiceOver said nothing for it. Extraction
# baselines, structure-text.pl, and veraPDF all passed both lines alike,
# because each reads marked content and none asks which element owns the
# content around an artifact.
#
# This script asks exactly that. It maps every MCID on every page to the
# structure element whose /K holds it, walks each page's content stream in
# order, and for each layout artifact that shows text (a Tj or TJ before its
# EMC) finds the nearest MCID run before it and after it on the same page.
# When both runs belong to one element the artifact is inside that element's
# content, and the script prints
#
#   <page>\t<mcid before>\t<mcid after>\t<element object>\t<element /S>
#
# A layout artifact with no text, such as a rule, is not listed: it has no
# glyph to read. A pagination artifact (`/Artifact BMC') is not a layout
# artifact and is not considered. An artifact with no marked content on one
# side of it on its page is between elements by definition.
#
# It is a property check with no reference value: no output means no
# straddle. Like structure-text.pl it needs an uncompressed PDF (the tagging
# fixtures set compresslevel=0 and objcompresslevel=0) and core Perl only, and
# a file it cannot read is an error rather than an empty, passing report.

use strict;
use warnings;

my $path = shift @ARGV or die "usage: artifact-straddle.pl <uncompressed.pdf>\n";
open my $fh, '<:raw', $path or die "open $path: $!\n";
my $pdf = do { local $/; <$fh> };
close $fh;

my %obj;
while ($pdf =~ /(\d+)\s+0\s+obj\b(.*?)\bendobj/gs) {
  $obj{$1} = $2;
}
die "$path: no indirect objects found; not a PDF?\n" unless %obj;
die "$path: contains object streams; rerun with objcompresslevel=0\n"
  if $pdf =~ m{/ObjStm};
die "$path: has no structure tree; is the document tagged?\n"
  unless $pdf =~ m{/StructTreeRoot};

# --- MCID owners -----------------------------------------------------------
# owner{page object}{mcid} = [element object, /S]. An MCR names its page; a
# bare integer kid takes the element's own /Pg.
my %owner;
for my $num (keys %obj) {
  my $body = $obj{$num};
  next unless $body =~ m{/Type\s*/StructElem\b};
  my $role = $body =~ m{/S\s*/([^\s/<>\[\]()]+)} ? $1 : '?';
  my $elem_pg = $body =~ m{/Pg\s+(\d+)\s+0\s+R} ? $1 : undef;
  next unless $body =~ m{/K\s*(\[(?:[^\[\]]|<<.*?>>)*\]|<<.*?>>|(?>\d+)(?!\s+\d+\s+R))}s;
  my $kids = $1;
  # MCR dictionaries first, then remove them so their numbers are not
  # mistaken for bare MCIDs or object references.
  while ($kids =~ m{<<(.*?)>>}gs) {
    my $mcr = $1;
    next unless $mcr =~ m{/MCID\s+(\d+)};
    my $mcid = $1;
    my $pg = $mcr =~ m{/Pg\s+(\d+)\s+0\s+R} ? $1 : $elem_pg;
    $owner{$pg}{$mcid} = [ $num, $role ] if defined $pg;
  }
  (my $bare = $kids) =~ s{<<.*?>>}{}gs;
  $bare =~ s{\d+\s+0\s+R}{}g;
  while ($bare =~ m{(\d+)}g) {
    $owner{$elem_pg}{$1} = [ $num, $role ] if defined $elem_pg;
  }
}

# --- pages -----------------------------------------------------------------
# Sorted by object number, as structure-text.pl does, so the page numbers
# printed here match the ones it prints.
my @pages;
for my $num (sort { $a <=> $b } keys %obj) {
  my $body = $obj{$num};
  next unless $body =~ m{/Type\s*/Page\b} && $body !~ m{/Type\s*/Pages\b};
  next unless $body =~ m{/Contents\s+(\d+)\s+0\s+R};
  push @pages, [ $num, $1 ];
}
die "$path: no page objects found\n" unless @pages;

my $page_number = 0;
for my $page (@pages) {
  my ($page_obj, $contents) = @$page;
  $page_number++;
  my $stream = $obj{$contents} =~ /stream\r?\n(.*?)\r?\nendstream/s ? $1 : undef;
  die "$path: page $page_number has no readable content stream\n"
    unless defined $stream;

  # One event per marked-content run, in stream order: an MCID, or a layout
  # artifact together with whether it showed any text.
  my @events;
  my $open;    # the event the innermost open BDC/BMC started, if recorded
  while ($stream =~ m{
        /([A-Za-z][\w.-]*) \s* (<<.*?>>) \s* BDC
      | /([A-Za-z][\w.-]*) \s+ BMC
      | \b (EMC) \b
      | \b (Tj|TJ) \b
    }gsx) {
    my ($bdc_tag, $bdc_dict, $bmc_tag, $emc, $show) = ($1, $2, $3, $4, $5);
    if (defined $bdc_tag) {
      if ($bdc_dict =~ m{/MCID\s+(\d+)}) {
        push @events, { mcid => $1 };
        $open = undef;
      } elsif ($bdc_tag eq 'Artifact' && $bdc_dict =~ m{/Type\s*/Layout\b}) {
        push @events, { layout => 1, text => 0 };
        $open = $events[-1];
      } else {
        $open = undef;
      }
    } elsif (defined $bmc_tag) {
      $open = undef;
    } elsif (defined $emc) {
      $open = undef;
    } elsif (defined $show) {
      $open->{text} = 1 if defined $open;
    }
  }

  for my $i (0 .. $#events) {
    my $event = $events[$i];
    next unless $event->{layout} && $event->{text};
    my ($before) = grep { defined $_->{mcid} } reverse @events[0 .. $i - 1];
    my ($after)  = grep { defined $_->{mcid} } @events[$i + 1 .. $#events];
    next unless defined $before && defined $after;
    my $first = $owner{$page_obj}{ $before->{mcid} };
    my $second = $owner{$page_obj}{ $after->{mcid} };
    next unless defined $first && defined $second && $first->[0] == $second->[0];
    print join("\t", $page_number, $before->{mcid}, $after->{mcid},
      "$first->[0] 0 obj", $first->[1]), "\n";
  }
}
