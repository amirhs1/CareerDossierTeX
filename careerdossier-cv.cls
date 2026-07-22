%% careerdossier-cv.cls
%% Part of the CareerDossierTeX project.
%%
%% Copyright (C) 2026 Amir Sadeghi.
%%
%% This work may be distributed and/or modified under the conditions of the
%% LaTeX Project Public License, either version 1.3c of this license or (at
%% your option) any later version. The latest version of this license is in
%%   https://www.latex-project.org/lppl.txt
%% and version 1.3c or later is part of all distributions of LaTeX version
%% 2008 or later.
%%
%% This work has the LPPL maintenance status `maintained'.
%% The Current Maintainer of this work is Amir Sadeghi.
%%
%% This work consists of the files listed in manifest.txt.
%%
%% careerdossier-cv owns the academic-CV vertical slice: Letter/A4 geometry,
%% density, multi-page flow, running headers, page numbers, and CV-local
%% section/entry/list spacing, including the dependency-free manual-publication
%% list. Shared profile, links, typography, and BibLaTeX formatting remain in
%% their corresponding modules. BibLaTeX is intentionally not loaded here; a
%% CV without an external bibliography must build without BibLaTeX or Biber.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass {careerdossier-cv} {2026-07-22} {0.5.0}
  {CareerDossierTeX English academic CV class}

\RequirePackage { l3keys2e }

\tl_new:N \l__cdossier_cv_fontsize_tl
\tl_set:Nn \l__cdossier_cv_fontsize_tl { 11pt }
\tl_new:N \l__cdossier_cv_density_tl
\tl_set:Nn \l__cdossier_cv_density_tl { standard }
\tl_new:N \l__cdossier_cv_paper_tl
\tl_set:Nn \l__cdossier_cv_paper_tl { letterpaper }

\msg_new:nnnn { careerdossier-cv } { unknown-option }
  { Unknown~class~option~'#1'~for~careerdossier-cv. }
  {
    Supported~options~are~'fontsize'~(10pt,~11pt),~
    'density'~(compact,~standard),~and~'paper'~(letter,~a4).~Language~and~
    theme~cannot~be~set~here.
  }

\keys_define:nn { cdossier / cv }
  {
    fontsize .choices:nn =
      { 10pt , 11pt }
      { \tl_set_eq:NN \l__cdossier_cv_fontsize_tl \l_keys_choice_tl } ,
    fontsize .value_required:n = true ,
    density  .choices:nn =
      { compact , standard }
      { \tl_set_eq:NN \l__cdossier_cv_density_tl \l_keys_choice_tl } ,
    density  .value_required:n = true ,
    paper .choices:nn =
      { letter , a4 }
      {
        \str_case:Vn \l_keys_choice_tl
          {
            { letter } { \tl_set:Nn \l__cdossier_cv_paper_tl { letterpaper } }
            { a4 }     { \tl_set:Nn \l__cdossier_cv_paper_tl { a4paper } }
          }
      } ,
    paper .value_required:n = true ,
    unknown  .code:n =
      { \msg_error:nnx { careerdossier-cv } { unknown-option } { \l_keys_key_str } } ,
  }
\ProcessKeysOptions { cdossier / cv }

\use:x
  {
    \exp_not:N \LoadClass
      [ \l__cdossier_cv_fontsize_tl , \l__cdossier_cv_paper_tl ]
      { article }
  }

\RequirePackage { careerdossier-components }
\RequirePackage { geometry }
\RequirePackage { enumitem }
\RequirePackage { hyperref }

\__cdossier_components_doctype:n { Curriculum\c_space_tl Vitae }

\use:x
  {
    \exp_not:N \geometry
      {
        \l__cdossier_cv_paper_tl ,
        top    = 0.72in ,
        bottom = 0.72in ,
        left   = 0.78in ,
        right  = 0.78in ,
      }
  }

\setlength { \parindent } { 0pt }
\setlength { \parskip }   { 0pt plus 1pt }

%% A4's narrower text block needs a little extra paragraph flexibility for
%% prose-heavy CV entries. Letter output retains its established line-breaking
%% behavior; this does not alter margins, type size, or page furniture.
\str_if_eq:VnT \l__cdossier_cv_paper_tl { a4paper }
  { \setlength { \emergencystretch } { 2em } }

%% A minimal kernel page style supplies a human-readable header after page one
%% and a folio on every page. The first page has no running header because the
%% body header already carries the person's full identity and contact details.
%%
%% The folio reads "Page N of M", matching careerdossier-letter. A bare "Page N"
%% cannot tell a reader holding page two whether the document ended, which
%% matters most for the printed and separated pages a multi-page CV produces.
%% As in the letter class, the total comes from the LaTeX kernel's last absolute
%% page recorded in the auxiliary file, so no total-page package is required and
%% the value resolves on the second pass.
\makeatletter
\def\ps@cdossiercv{%
  \let\@mkboth\@gobbletwo
  \def\@oddhead{\hfil{\sffamily\small\CDossierFieldValue{name}\enspace--\enspace Curriculum\space Vitae}\hfil}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\hfil{\sffamily\small Page~\thepage\space of~\@abspage@last}\hfil}%
  \let\@evenfoot\@oddfoot
}
\def\ps@cdossiercvfirst{%
  \let\@mkboth\@gobbletwo
  \def\@oddhead{}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\hfil{\sffamily\small Page~\thepage\space of~\@abspage@last}\hfil}%
  \let\@evenfoot\@oddfoot
}
\makeatother
\pagestyle { cdossiercv }
\AtBeginDocument { \thispagestyle { cdossiercvfirst } }

\bool_new:N \l__cdossier_cv_compact_bool
\str_if_eq:VnTF \l__cdossier_cv_density_tl { compact }
  { \bool_set_true:N \l__cdossier_cv_compact_bool }
  { \bool_set_false:N \l__cdossier_cv_compact_bool }

\skip_new:N \l__cdossier_cv_sectionabove_skip
\skip_new:N \l__cdossier_cv_sectiongap_skip
\skip_new:N \l__cdossier_cv_sectionbelow_skip
\skip_new:N \l__cdossier_cv_entryabove_skip
\skip_new:N \l__cdossier_cv_entrygap_skip
\skip_new:N \l__cdossier_cv_entrybelow_skip
\skip_new:N \l__cdossier_cv_itemsep_skip
\skip_new:N \l__cdossier_cv_itemtop_skip
\dim_new:N  \l__cdossier_cv_rule_dim
\dim_set:Nn \l__cdossier_cv_rule_dim { 0.4pt }

\bool_if:NTF \l__cdossier_cv_compact_bool
  {
    \skip_set:Nn \l__cdossier_cv_sectionabove_skip { 9pt plus 2pt minus 1pt }
    \skip_set:Nn \l__cdossier_cv_sectiongap_skip   { 2pt }
    \skip_set:Nn \l__cdossier_cv_sectionbelow_skip { 4pt plus 1pt }
    \skip_set:Nn \l__cdossier_cv_entryabove_skip   { 4pt plus 1pt }
    \skip_set:Nn \l__cdossier_cv_entrygap_skip     { 1pt }
    \skip_set:Nn \l__cdossier_cv_entrybelow_skip   { 4pt plus 1pt }
    \skip_set:Nn \l__cdossier_cv_itemsep_skip      { 1pt }
    \skip_set:Nn \l__cdossier_cv_itemtop_skip      { 1pt }
  }
  {
    \skip_set:Nn \l__cdossier_cv_sectionabove_skip { 14pt plus 3pt minus 2pt }
    \skip_set:Nn \l__cdossier_cv_sectiongap_skip   { 3pt }
    \skip_set:Nn \l__cdossier_cv_sectionbelow_skip { 7pt plus 2pt }
    \skip_set:Nn \l__cdossier_cv_entryabove_skip   { 8pt plus 2pt }
    \skip_set:Nn \l__cdossier_cv_entrygap_skip     { 2pt }
    \skip_set:Nn \l__cdossier_cv_entrybelow_skip   { 6pt plus 2pt }
    \skip_set:Nn \l__cdossier_cv_itemsep_skip      { 3pt }
    \skip_set:Nn \l__cdossier_cv_itemtop_skip      { 2pt }
  }

\NewDocumentCommand \CDossierSection { m }
  {
    \par
    \addvspace { \l__cdossier_cv_sectionabove_skip }
    \__cdossier_typography_heading:n
      { { \CDossierSectionStyle \large #1 } }
    \vspace { \l__cdossier_cv_sectiongap_skip }
    \noindent { \CDossierRuleColor \__cdossier_typography_layout_artifact:n
      { \rule { \linewidth } { \l__cdossier_cv_rule_dim } } }
    \par \nobreak
    \vspace { \l__cdossier_cv_sectionbelow_skip }
  }

\tl_new:N \l__cdossier_cv_entry_title_tl
\tl_new:N \l__cdossier_cv_entry_org_tl
\tl_new:N \l__cdossier_cv_entry_loc_tl
\tl_new:N \l__cdossier_cv_entry_dates_tl

\msg_new:nnnn { careerdossier-cv } { unknown-entry-key }
  { Unknown~CDossierEntry~key~'#1'. }
  { The~supported~keys~are:~title,~organization,~location,~dates. }
\msg_new:nnnn { careerdossier-cv } { entry-missing-title }
  { A~CDossierEntry~is~missing~its~required~'title'. }
  { Add~a~title,~for~example:~\c_backslash_str begin\c_left_brace_str CDossierEntry\c_right_brace_str [title~=~Research~Fellow]. }

\keys_define:nn { cdossier / cv / entry }
  {
    title        .tl_set:N = \l__cdossier_cv_entry_title_tl ,
    organization .tl_set:N = \l__cdossier_cv_entry_org_tl ,
    location     .tl_set:N = \l__cdossier_cv_entry_loc_tl ,
    dates        .tl_set:N = \l__cdossier_cv_entry_dates_tl ,
    unknown      .code:n =
      { \msg_error:nnx { careerdossier-cv } { unknown-entry-key } { \l_keys_key_str } } ,
  }

\NewDocumentEnvironment { CDossierEntry } { O{} }
  {
    \tl_clear:N \l__cdossier_cv_entry_title_tl
    \tl_clear:N \l__cdossier_cv_entry_org_tl
    \tl_clear:N \l__cdossier_cv_entry_loc_tl
    \tl_clear:N \l__cdossier_cv_entry_dates_tl
    \keys_set:nn { cdossier / cv / entry } {#1}
    \tl_if_blank:VT \l__cdossier_cv_entry_title_tl
      { \msg_error:nn { careerdossier-cv } { entry-missing-title } }
    \par
    \addvspace { \l__cdossier_cv_entryabove_skip }
    \__cdossier_components_entryhead:VVVV
      \l__cdossier_cv_entry_title_tl
      \l__cdossier_cv_entry_org_tl
      \l__cdossier_cv_entry_loc_tl
      \l__cdossier_cv_entry_dates_tl
    \nobreak
    \vspace { \l__cdossier_cv_entrygap_skip }
  }
  {
    \par
    \addvspace { \l__cdossier_cv_entrybelow_skip }
  }

\NewDocumentEnvironment { CDossierItemize } { }
  {
    \begin { itemize }
      [
        leftmargin = 1.4em ,
        labelsep   = 0.5em ,
        topsep     = \l__cdossier_cv_itemtop_skip ,
        itemsep    = \l__cdossier_cv_itemsep_skip ,
        parsep     = 0pt ,
        label      = \textbullet ,
      ]
  }
  { \end { itemize } }

%% ---------------------------------------------------------------------------
%% Manual publications.
%%
%% This source-order list belongs to the CV class because it is ordinary CV
%% content, not bibliography-database interoperability. It deliberately uses no
%% BibLaTeX command, so users can maintain a small publication list without
%% installing BibLaTeX or running Biber.
%% ---------------------------------------------------------------------------
\bool_new:N \l__cdossier_cv_publications_active_bool
\tl_new:N   \l__cdossier_cv_publication_authors_tl
\tl_new:N   \l__cdossier_cv_publication_title_tl
\tl_new:N   \l__cdossier_cv_publication_venue_tl
\tl_new:N   \l__cdossier_cv_publication_date_tl
\tl_new:N   \l__cdossier_cv_publication_doi_tl
\tl_new:N   \l__cdossier_cv_publication_url_tl
\tl_new:N   \l__cdossier_cv_publication_note_tl
\tl_new:N   \l__cdossier_cv_publication_target_tl
\str_new:N  \l__cdossier_cv_publication_target_str
\seq_new:N  \l__cdossier_cv_publication_details_seq

\msg_new:nnnn { careerdossier-cv } { publication-outside-list }
  { \c_backslash_str CDossierPublication~may~only~be~used~inside~CDossierPublications. }
  {
    Wrap~publication~entries~in~
    \c_backslash_str begin\c_left_brace_str CDossierPublications\c_right_brace_str
    ~...~
    \c_backslash_str end\c_left_brace_str CDossierPublications\c_right_brace_str .
  }
\msg_new:nnnn { careerdossier-cv } { publication-missing-field }
  { A~manual~publication~is~missing~its~required~'#1'~field. }
  {
    Every~\c_backslash_str CDossierPublication~needs~nonblank~'authors'~and~
    'title'~keys.
  }
\msg_new:nnnn { careerdossier-cv } { unknown-publication-key }
  { Unknown~\c_backslash_str CDossierPublication~key~'#1'. }
  { The~supported~keys~are:~authors,~title,~venue,~date,~doi,~url,~note. }

\keys_define:nn { cdossier / publication }
  {
    authors .tl_set:N = \l__cdossier_cv_publication_authors_tl ,
    title   .tl_set:N = \l__cdossier_cv_publication_title_tl ,
    venue   .tl_set:N = \l__cdossier_cv_publication_venue_tl ,
    date    .tl_set:N = \l__cdossier_cv_publication_date_tl ,
    doi     .tl_set:N = \l__cdossier_cv_publication_doi_tl ,
    url     .tl_set:N = \l__cdossier_cv_publication_url_tl ,
    note    .tl_set:N = \l__cdossier_cv_publication_note_tl ,
    unknown .code:n =
      { \msg_error:nnx { careerdossier-cv } { unknown-publication-key } { \l_keys_key_str } } ,
  }

\cs_new_protected:Npn \__cdossier_cv_publication_clear:
  {
    \tl_clear:N \l__cdossier_cv_publication_authors_tl
    \tl_clear:N \l__cdossier_cv_publication_title_tl
    \tl_clear:N \l__cdossier_cv_publication_venue_tl
    \tl_clear:N \l__cdossier_cv_publication_date_tl
    \tl_clear:N \l__cdossier_cv_publication_doi_tl
    \tl_clear:N \l__cdossier_cv_publication_url_tl
    \tl_clear:N \l__cdossier_cv_publication_note_tl
  }

\cs_new_protected:Npn \__cdossier_cv_publication_trim:
  {
    \tl_trim_spaces:N \l__cdossier_cv_publication_authors_tl
    \tl_trim_spaces:N \l__cdossier_cv_publication_title_tl
    \tl_trim_spaces:N \l__cdossier_cv_publication_venue_tl
    \tl_trim_spaces:N \l__cdossier_cv_publication_date_tl
    \tl_trim_spaces:N \l__cdossier_cv_publication_doi_tl
    \tl_trim_spaces:N \l__cdossier_cv_publication_url_tl
    \tl_trim_spaces:N \l__cdossier_cv_publication_note_tl
  }

%% Normalize a DOI or fallback URL target while leaving the displayed value
%% unchanged. A DOI may be a bare identifier, doi.org path, or complete URL.
\cs_new_protected:Npn \__cdossier_cv_publication_link:nn #1#2
  {
    \tl_set:Nn \l__cdossier_cv_publication_target_tl {#2}
    \str_set:NV \l__cdossier_cv_publication_target_str
      \l__cdossier_cv_publication_target_tl
    \str_if_in:NnF \l__cdossier_cv_publication_target_str { :// }
      {
        \str_if_eq:nnTF {#1} { DOI }
          {
            \str_if_in:NnTF \l__cdossier_cv_publication_target_str { doi.org/ }
              { \tl_put_left:Nn \l__cdossier_cv_publication_target_tl { https:// } }
              { \tl_put_left:Nn \l__cdossier_cv_publication_target_tl { https://doi.org/ } }
          }
          { \tl_put_left:Nn \l__cdossier_cv_publication_target_tl { https:// } }
      }
    \cs_if_exist:NTF \href
      {
        \href { \l__cdossier_cv_publication_target_tl }
          { #1:\nobreakspace \nolinkurl {#2} }
      }
      { #1:\nobreakspace #2 }
  }

\cs_new_protected:Npn \__cdossier_cv_publication_render:
  {
    \item
    \tl_use:N \l__cdossier_cv_publication_authors_tl .\space
    \emph { \tl_use:N \l__cdossier_cv_publication_title_tl } .
    \seq_clear:N \l__cdossier_cv_publication_details_seq
    \tl_if_blank:VF \l__cdossier_cv_publication_venue_tl
      {
        \seq_put_right:NV \l__cdossier_cv_publication_details_seq
          \l__cdossier_cv_publication_venue_tl
      }
    \tl_if_blank:VF \l__cdossier_cv_publication_date_tl
      {
        \seq_put_right:NV \l__cdossier_cv_publication_details_seq
          \l__cdossier_cv_publication_date_tl
      }
    \seq_if_empty:NF \l__cdossier_cv_publication_details_seq
      { \space \seq_use:Nn \l__cdossier_cv_publication_details_seq { ,~ } . }
    \tl_if_blank:VF \l__cdossier_cv_publication_note_tl
      { \space \tl_use:N \l__cdossier_cv_publication_note_tl . }
    %% DOI wins when both identifiers are present; URL is the fallback.
    \tl_if_blank:VTF \l__cdossier_cv_publication_doi_tl
      {
        \tl_if_blank:VF \l__cdossier_cv_publication_url_tl
          {
            \space
            \exp_args:NnV \__cdossier_cv_publication_link:nn { URL }
              \l__cdossier_cv_publication_url_tl
          }
      }
      {
        \space
        \exp_args:NnV \__cdossier_cv_publication_link:nn { DOI }
          \l__cdossier_cv_publication_doi_tl
      }
  }

\NewDocumentEnvironment { CDossierPublications } { }
  {
    \bool_set_true:N \l__cdossier_cv_publications_active_bool
    \begin { enumerate }
      [
        label      = \textbf { \arabic*) } ,
        leftmargin = * ,
        labelsep   = 0.6em ,
        topsep     = \l__cdossier_cv_itemtop_skip ,
        itemsep    = \l__cdossier_cv_itemsep_skip ,
        parsep     = 0pt ,
      ]
  }
  {
    \end { enumerate }
    \bool_set_false:N \l__cdossier_cv_publications_active_bool
  }

\NewDocumentCommand \CDossierPublication { m }
  {
    \bool_if:NTF \l__cdossier_cv_publications_active_bool
      {
        \__cdossier_cv_publication_clear:
        \keys_set:nn { cdossier / publication } {#1}
        \__cdossier_cv_publication_trim:
        \tl_if_blank:VT \l__cdossier_cv_publication_authors_tl
          {
            \msg_error:nnn { careerdossier-cv }
              { publication-missing-field } { authors }
          }
        \tl_if_blank:VT \l__cdossier_cv_publication_title_tl
          {
            \msg_error:nnn { careerdossier-cv }
              { publication-missing-field } { title }
          }
        \__cdossier_cv_publication_render:
      }
      { \msg_error:nn { careerdossier-cv } { publication-outside-list } }
  }

\endinput
