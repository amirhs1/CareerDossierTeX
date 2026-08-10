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
%% careerdossier-cv owns the academic-CV vertical slice: Letter/A4 selection,
%% multi-page flow, and the dependency-free manual-publication list. Shared
%% geometry, page furniture, type, rhythm, rules, list metrics, profile, links,
%% typography, and BibLaTeX formatting remain in their corresponding modules.
%% BibLaTeX is intentionally not loaded here; a CV without an external
%% bibliography must build without BibLaTeX or Biber.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass {careerdossier-cv} {2026-08-04} {0.7.0}
  {CareerDossierTeX English academic CV class}

\RequirePackage { l3keys2e }

\tl_new:N \l__cdossier_cv_fontsize_tl
\tl_set:Nn \l__cdossier_cv_fontsize_tl { 12pt }
\tl_new:N \l__cdossier_cv_margin_tl
\tl_set:Nn \l__cdossier_cv_margin_tl { normal }
\tl_new:N \l__cdossier_cv_paper_tl
\tl_set:Nn \l__cdossier_cv_paper_tl { letterpaper }
\tl_new:N \l__cdossier_cv_bodyfont_tl
\tl_set:Nn \l__cdossier_cv_bodyfont_tl { serif }
\tl_new:N \l__cdossier_cv_medium_tl
\tl_set:Nn \l__cdossier_cv_medium_tl { print }
\tl_new:N \l__cdossier_cv_muted_tl
\tl_set:Nn \l__cdossier_cv_muted_tl { plain }
\tl_new:N \l__cdossier_cv_entrymeta_tl
\tl_set:Nn \l__cdossier_cv_entrymeta_tl { column }

\msg_new:nnnn { careerdossier-cv } { unknown-option }
  {
    Unknown~class~option~'#1'~for~careerdossier-cv.~
    Supported~options~are~'fontsize',~'margin',~'paper',~'bodyfont',~
    'medium',~'muted',~and~'entrymeta'.
  }
  {
    Supported~options~are~'fontsize'~(10pt,~11pt,~12pt),~
    'margin'~(normal,~narrow),~
    'paper'~(letter,~a4),~
    'bodyfont'~(serif,~sans),~
    'medium'~(print,~screen),~
    'muted'~(italic,~gray,~both,~plain),~and~
    'entrymeta'~(column,~inline).~Language~and~theme~cannot~be~set~here.
  }

%% l3keys' own choice error reports that the value is not one of a fixed set
%% without saying what that set is, so every choice-valued option below names
%% its own accepted values. Each message is reached through the matching
%% `<key> / unknown' sub-key, which l3keys runs in place of its stock error.
\msg_new:nnnn { careerdossier-cv } { unknown-fontsize }
  { Unknown~'fontsize'~value~'#1'~for~careerdossier-cv. }
  { The~accepted~values~are~'10pt',~'11pt',~and~'12pt'. }

\msg_new:nnnn { careerdossier-cv } { unknown-margin }
  { Unknown~'margin'~value~'#1'~for~careerdossier-cv. }
  {
    The~accepted~values~are~'normal'~(one-inch~margins)~and~
    'narrow'~(half-inch~margins).
  }

\msg_new:nnnn { careerdossier-cv } { unknown-paper }
  { Unknown~'paper'~value~'#1'~for~careerdossier-cv. }
  { The~accepted~values~are~'letter'~(US~Letter)~and~'a4'~(ISO~A4). }

\msg_new:nnnn { careerdossier-cv } { unknown-bodyfont }
  { Unknown~'bodyfont'~value~'#1'~for~careerdossier-cv. }
  {
    The~accepted~values~are~'serif'~(TeX~Gyre~Termes~body)~and~
    'sans'~(TeX~Gyre~Heros~body).
  }

\msg_new:nnnn { careerdossier-cv } { unknown-medium }
  { Unknown~'medium'~value~'#1'~for~careerdossier-cv. }
  {
    The~accepted~values~are~'print'~(running~header~and~'Page~N~of~M'~folio)~
    and~'screen'~(neither).
  }

\msg_new:nnnn { careerdossier-cv } { unknown-muted }
  { Unknown~'muted'~value~'#1'~for~careerdossier-cv. }
  {
    The~accepted~values~are~'italic'~(italic,~black),~
    'gray'~(upright,~gray~0.30),~'both'~(italic~and~gray),~and~
    'plain'~(upright,~black:~no~de-emphasis).
  }

\msg_new:nnnn { careerdossier-cv } { unknown-entrymeta }
  { Unknown~'entrymeta'~value~'#1'~for~careerdossier-cv. }
  {
    The~accepted~values~are~'column'~(dates~and~location~flush~right)~
    and~'inline'~(dates~and~location~on~the~same~line~as~the~title~
    and~organization).
  }

\keys_define:nn { cdossier / cv }
  {
    fontsize .choices:nn =
      { 10pt , 11pt , 12pt }
      { \tl_set_eq:NN \l__cdossier_cv_fontsize_tl \l_keys_choice_tl } ,
    fontsize / unknown .code:n =
      { \msg_error:nnn { careerdossier-cv } { unknown-fontsize } {#1} } ,
    fontsize .value_required:n = true ,
    margin .choices:nn =
      { normal , narrow }
      { \tl_set_eq:NN \l__cdossier_cv_margin_tl \l_keys_choice_tl } ,
    margin / unknown .code:n =
      { \msg_error:nnn { careerdossier-cv } { unknown-margin } {#1} } ,
    margin .value_required:n = true ,
    paper .choices:nn =
      { letter , a4 }
      {
        \str_case:Vn \l_keys_choice_tl
          {
            { letter } { \tl_set:Nn \l__cdossier_cv_paper_tl { letterpaper } }
            { a4 }     { \tl_set:Nn \l__cdossier_cv_paper_tl { a4paper } }
          }
      } ,
    paper / unknown .code:n =
      { \msg_error:nnn { careerdossier-cv } { unknown-paper } {#1} } ,
    paper .value_required:n = true ,
    bodyfont .choices:nn =
      { serif , sans }
      { \tl_set_eq:NN \l__cdossier_cv_bodyfont_tl \l_keys_choice_tl } ,
    bodyfont / unknown .code:n =
      { \msg_error:nnn { careerdossier-cv } { unknown-bodyfont } {#1} } ,
    bodyfont .value_required:n = true ,
    medium .choices:nn =
      { print , screen }
      { \tl_set_eq:NN \l__cdossier_cv_medium_tl \l_keys_choice_tl } ,
    medium / unknown .code:n =
      { \msg_error:nnn { careerdossier-cv } { unknown-medium } {#1} } ,
    medium .value_required:n = true ,
    muted .choices:nn =
      { italic , gray , both , plain }
      { \tl_set_eq:NN \l__cdossier_cv_muted_tl \l_keys_choice_tl } ,
    muted / unknown .code:n =
      { \msg_error:nnn { careerdossier-cv } { unknown-muted } {#1} } ,
    muted .value_required:n = true ,
    entrymeta .choices:nn =
      { column , inline }
      { \tl_set_eq:NN \l__cdossier_cv_entrymeta_tl \l_keys_choice_tl } ,
    entrymeta / unknown .code:n =
      { \msg_error:nnn { careerdossier-cv } { unknown-entrymeta } {#1} } ,
    entrymeta .value_required:n = true ,
    unknown  .code:n =
      { \msg_error:nnx { careerdossier-cv } { unknown-option } { \l_keys_key_str } } ,
  }
\ProcessKeysOptions { cdossier / cv }

\str_if_eq:VnT \l__cdossier_cv_bodyfont_tl { sans }
  { \PassOptionsToPackage { bodyfont = sans } { careerdossier-typography } }
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      {
        fontsize = \l__cdossier_cv_fontsize_tl ,
        margin = \l__cdossier_cv_margin_tl
      }
      { careerdossier-tokens }
  }
%% Issues #184, #271, and #230: the class validates the public values;
%% careerdossier-components owns the page furniture, the de-emphasis role, and
%% the entry-heading primitive, and therefore owns all three resulting
%% decisions.
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      {
        medium    = \l__cdossier_cv_medium_tl ,
        muted     = \l__cdossier_cv_muted_tl ,
        entrymeta = \l__cdossier_cv_entrymeta_tl
      }
      { careerdossier-components }
  }

\use:x
  {
    \exp_not:N \LoadClass
      [ \l__cdossier_cv_fontsize_tl , \l__cdossier_cv_paper_tl ]
      { article }
  }

\RequirePackage { careerdossier-components }
\RequirePackage { careerdossier-tokens }
\RequirePackage { enumitem }
\RequirePackage { hyperref }
\__cdossier_tokens_apply_body_size:

\__cdossier_components_doctype:n { Curriculum\c_space_tl Vitae }

\exp_args:NV \__cdossier_tokens_apply_geometry:n \l__cdossier_cv_paper_tl

\setlength { \parindent } { 0pt }
\setlength { \parskip }   { \CDossierRecordParSkip }

%% Issue #272: the shared line-breaking flexibility every family applies. This
%% was previously spent only at `a4paper', on the reasoning that A4's narrower
%% text block needs more paragraph flexibility for prose-heavy CV entries --
%% true, but not a reason to withhold it from letter paper, which is only less
%% likely to need it, never harmed by having it. The policy and its reasoning
%% live with the token in careerdossier-tokens.
\setlength { \emergencystretch } { \CDossierEmergencyStretch }

\__cdossier_components_runninglabel:n { Curriculum~Vitae }
\__cdossier_components_apply_page_furniture:
\CDossierApplyPageBreakPenalties

%% Issue #223: the shared header stack ends at a boundary against whatever the
%% class puts next -- here a ruled \CDossierSection -- so the class names the
%% token that owns it rather than sharing one gap with the letter and the
%% statement, whose next block is not a ruled section at all.
\__cdossier_components_headerbelow:N \CDossierRecordHeaderBelowSkip

%% The keep-together penalty (issue #145) after the heading and rule keeps the
%% title with the content that follows it, so a section heading is never
%% stranded alone at the foot of a page.
%% Issue #267: depth 2, not 1 -- the document identity (the name, in
%% \MakeCDossierHeader) is the document's one depth-1 heading, so every
%% résumé/CV section heading sits one level under it.
%%
%% Issue #268: the heading also opens the division that encloses it and the
%% entries it introduces, and passes its plain title so the heading element
%% records it. A CV's publication list has no sectioning of its own -- it is a
%% list placed under an ordinary \CDossierSection -- so this one division is
%% what encloses it too. The division opens after the `\addvspace' and before
%% the heading; see the note on the primitive in careerdossier-typography.sty.
\NewDocumentCommand \CDossierSection { m }
  {
    \par
    %% Issue #333: the section keep, applied before the heading contributes
    %% anything, so the bound is on what the heading commits rather than a
    %% prohibition on breaking after it.
    \__cdossier_components_section_need:
    \addvspace { \CDossierRecordSectionAboveSkip }
    \__cdossier_typography_division_begin:n { 2 }
    \__cdossier_typography_heading:nnn { 2 } { #1 }
      { { \CDossierSectionStyle \CDossierSizeSection #1 \par } }
    \__cdossier_components_section_rule:
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

\NewDocumentEnvironment { CDossierEntry } { O{} +b }
  {
    \tl_clear:N \l__cdossier_cv_entry_title_tl
    \tl_clear:N \l__cdossier_cv_entry_org_tl
    \tl_clear:N \l__cdossier_cv_entry_loc_tl
    \tl_clear:N \l__cdossier_cv_entry_dates_tl
    \keys_set:nn { cdossier / cv / entry } {#1}
    \tl_if_blank:VT \l__cdossier_cv_entry_title_tl
      { \msg_error:nn { careerdossier-cv } { entry-missing-title } }
    \par
    \addvspace { \CDossierRecordEntryAboveSkip }
    \__cdossier_components_entryhead:VVVV
      \l__cdossier_cv_entry_title_tl
      \l__cdossier_cv_entry_org_tl
      \l__cdossier_cv_entry_loc_tl
      \l__cdossier_cv_entry_dates_tl
    %% Issue #145: keep the entry heading with the first line of its body, so
    %% the heading cannot be stranded alone at the foot of a page.
    %%
    %% Issue #332: guarded on a non-empty body, for the reasons set out at the
    %% matching guard in careerdossier-resume.cls. In short: emitted with no body
    %% to bind to, the penalty is left immediately before the gap glue, which
    %% makes that boundary unbreakable, and the next entry's `\addvspace'
    %% collapses rather than intervening -- so a run of body-less entries welds
    %% into one block. The body is taken as a `+b' argument only so this test can
    %% be made, at the cost of catcode-sensitive content in an entry body.
    \tl_if_blank:nF {#2}
      { \penalty \CDossierHeadingKeepPenalty }
    %% Issue #204: `\addvspace', not `\vspace'. As a `\vspace' this was extra
    %% space that added to whatever the entry body opened with, so a bullet list
    %% sat further from the entry heading that owns it than from the next entry.
    %% As an `\addvspace' the token is the *floor* for the heading -> body
    %% boundary, which a list overrides with its own edge.
    \addvspace { \CDossierRecordEntryGapSkip }
    #2
  }
  {
    %% Issue #204: the entry's closing boundary is owned by whatever opens next
    %% -- \CDossierRecordEntryAboveSkip or \CDossierRecordSectionAboveSkip. The
    %% retired \CDossierRecordEntryBelowSkip lost both of those maxima.
    \par
  }

%% Issue #145: `beginpenalty' keeps the first bullet with whatever precedes the
%% list -- here the entry heading. The inter-item boundaries are governed by
%% the shared position-aware policy in careerdossier-components, which forbids
%% the boundaries that would strand a single bullet and merely discourages the
%% rest, so a list longer than a page still breaks.
%%
%% Issue #176: `partopsep' is zeroed so the list-edge tokens alone own the
%% distance between the list and the content around it, as documented. LaTeX
%% adds `\partopsep' on top of `topsep' whenever a list opens a new paragraph,
%% and the `article' default is 3 pt plus stretch: a quantity no token owns and
%% that does not rescale with `fontsize'. Left in place it would make the list
%% edge both wider than the token says and proportionally wider at 10pt than
%% at 12pt. The token's own ratio absorbs the 3 pt instead.
%%
%% Issue #191: `topsep' is LaTeX's only list-edge key and applies at both ends,
%% so `\CDossierRecordListEdgeAboveSkip' passes through it and the shared
%% component call below substitutes `\CDossierRecordListEdgeBelowSkip' for the
%% closing edge.
%%
%% Issue #193: that substitution works on the untagged path only, because a
%% tagged list is built by LaTeX Lab's block templates and never reads the
%% register it assigns. The tagged branch names the same token through
%% `cdossier-closing-edge' instead -- the shared key careerdossier-components
%% declares for exactly this -- so both paths place the same gap below a list.
\dim_new:N \l__cdossier_cv_label_width_dim

\NewDocumentEnvironment { CDossierItemize } { }
  {
    \tag_if_active:TF
      {
        %% LaTeX Lab's tagged-list emulation requires an explicit dimension
        %% instead of enumitem's `*' calculation. Measure the fixed bullet so
        %% its label box remains flush with the section and entry edge.
        \hbox_set:Nn \l_tmpa_box { \textbullet }
        \dim_set:Nn \l__cdossier_cv_label_width_dim
          { \box_wd:N \l_tmpa_box }
        \begin { itemize }
          [
            leftmargin =
              \dim_eval:n
                {
                  \l__cdossier_cv_label_width_dim
                  + \CDossierListLabelSep
                } ,
            labelwidth = \l__cdossier_cv_label_width_dim ,
            labelsep   = \CDossierListLabelSep ,
            topsep     = \CDossierRecordListEdgeAboveSkip ,
            cdossier-closing-edge = \CDossierRecordListEdgeBelowSkip ,
            itemsep    = \CDossierRecordItemSepSkip ,
            parsep     = 0pt ,
            partopsep  = 0pt ,
            label      = \textbullet ,
            beginpenalty = \CDossierHeadingKeepPenalty ,
          ]
      }
      {
        \begin { itemize }
          [
            leftmargin = * ,
            labelsep   = \CDossierListLabelSep ,
            topsep     = \CDossierRecordListEdgeAboveSkip ,
            itemsep    = \CDossierRecordItemSepSkip ,
            parsep     = 0pt ,
            partopsep  = 0pt ,
            label      = \textbullet ,
            beginpenalty = \CDossierHeadingKeepPenalty ,
          ]
      }
    \__cdossier_components_listpolicy_begin:
  }
  {
    \__cdossier_components_listpolicy_end:
    \__cdossier_components_listedge_after:
    \end { itemize }
  }

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
%%
%% The scheme goes in with :Ne and \tl_to_str:n so its colon is an ordinary
%% character. A literal colon here is a letter under expl3, and hyperref finds
%% an \href target's scheme by splitting on a catcode-12 colon: a catcode-11
%% one is invisible to that split, so hyperref takes the target for a local
%% file, appends `.pdf', and emits a GoToR "open a remote PDF" action rather
%% than a URI action -- silently, and only in the annotation. See the same note
%% at \__cdossier_components_scheme:N in careerdossier-components (issue #328).
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
              { \tl_put_left:Ne \l__cdossier_cv_publication_target_tl
                  { \tl_to_str:n { https:// } } }
              { \tl_put_left:Ne \l__cdossier_cv_publication_target_tl
                  { \tl_to_str:n { https://doi.org/ } } }
          }
          { \tl_put_left:Ne \l__cdossier_cv_publication_target_tl
              { \tl_to_str:n { https:// } } }
      }
    %% The visible text is the identifier itself, so this link needs no
    %% decoration under `medium=screen' -- and must not get one: ulem would
    %% rebox the \nolinkurl into a single unbreakable token. See
    %% \CDossierPlainLinks in careerdossier-components (issue #278).
    \cs_if_exist:NTF \href
      {
        \group_begin:
          \CDossierPlainLinks
          \href { \l__cdossier_cv_publication_target_tl }
            { #1:\nobreakspace \nolinkurl {#2} }
        \group_end:
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

%% The numbered list takes the same two paths as CDossierItemize, and for the
%% same two reasons: LaTeX Lab's emulation parses `leftmargin' as a dimension
%% and cannot accept enumitem's `*' calculation, and it places the closing edge
%% from `cdossier-closing-edge' rather than from `\@topsepadd'. CDossierItemize
%% gained the first branch with the calibrated token system and this list did
%% not, so until now it had no tagged path at all (issues #218 and #193).
%%
%% enumitem's `*' resolves the label box from the *first* item's label and keeps
%% that width however long the list runs, so `\textbf{1)}' is the box the
%% untagged path measures and the one the tagged path has to reproduce. It is
%% written out rather than derived from the `label' key above it because the
%% label is a template for every item and this is one rendered instance of it;
%% CDossierItemize states its own `\textbullet' twice for the same reason.
\dim_new:N \l__cdossier_cv_publication_label_width_dim

\NewDocumentEnvironment { CDossierPublications } { }
  {
    \bool_set_true:N \l__cdossier_cv_publications_active_bool
    \tag_if_active:TF
      {
        \hbox_set:Nn \l_tmpa_box { \textbf { 1) } }
        \dim_set:Nn \l__cdossier_cv_publication_label_width_dim
          { \box_wd:N \l_tmpa_box }
        \begin { enumerate }
          [
            label      = \textbf { \arabic*) } ,
            leftmargin =
              \dim_eval:n
                {
                  \l__cdossier_cv_publication_label_width_dim
                  + \CDossierListLabelSep
                } ,
            labelwidth = \l__cdossier_cv_publication_label_width_dim ,
            labelsep   = \CDossierListLabelSep ,
            topsep     = \CDossierRecordListEdgeAboveSkip ,
            cdossier-closing-edge = \CDossierRecordListEdgeBelowSkip ,
            itemsep    = \CDossierRecordItemSepSkip ,
            parsep     = 0pt ,
            partopsep  = 0pt ,
          ]
      }
      {
        \begin { enumerate }
          [
            label      = \textbf { \arabic*) } ,
            leftmargin = * ,
            labelsep   = \CDossierListLabelSep ,
            topsep     = \CDossierRecordListEdgeAboveSkip ,
            itemsep    = \CDossierRecordItemSepSkip ,
            parsep     = 0pt ,
            partopsep  = 0pt ,
          ]
      }
  }
  {
    \__cdossier_components_listedge_after:
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
