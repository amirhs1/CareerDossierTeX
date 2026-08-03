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
\ProvidesExplClass {careerdossier-cv} {2026-07-30} {0.6.0}
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

\msg_new:nnnn { careerdossier-cv } { unknown-option }
  {
    Unknown~class~option~'#1'~for~careerdossier-cv.~
    Supported~options~are~'fontsize',~'margin',~'paper',~'bodyfont',~
    and~'medium'.
  }
  {
    Supported~options~are~'fontsize'~(10pt,~11pt,~12pt),~
    'margin'~(normal,~narrow),~
    'paper'~(letter,~a4),~
    'bodyfont'~(serif,~sans),~and~
    'medium'~(print,~screen).~Language~and~theme~cannot~be~set~here.
  }

%% l3keys' own choice error reports that the value is not one of a fixed set
%% without saying what that set is, so the accepted values are named here.
\msg_new:nnnn { careerdossier-cv } { unknown-medium }
  { Unknown~'medium'~value~'#1'~for~careerdossier-cv. }
  {
    The~accepted~values~are~'print'~(running~header~and~'Page~N~of~M'~folio)~
    and~'screen'~(neither).
  }

\keys_define:nn { cdossier / cv }
  {
    fontsize .choices:nn =
      { 10pt , 11pt , 12pt }
      { \tl_set_eq:NN \l__cdossier_cv_fontsize_tl \l_keys_choice_tl } ,
    fontsize .value_required:n = true ,
    margin .choices:nn =
      { normal , narrow }
      { \tl_set_eq:NN \l__cdossier_cv_margin_tl \l_keys_choice_tl } ,
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
    paper .value_required:n = true ,
    bodyfont .choices:nn =
      { serif , sans }
      { \tl_set_eq:NN \l__cdossier_cv_bodyfont_tl \l_keys_choice_tl } ,
    bodyfont .value_required:n = true ,
    medium .choices:nn =
      { print , screen }
      { \tl_set_eq:NN \l__cdossier_cv_medium_tl \l_keys_choice_tl } ,
    medium / unknown .code:n =
      { \msg_error:nnn { careerdossier-cv } { unknown-medium } {#1} } ,
    medium .value_required:n = true ,
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
%% Issue #184: the class validates the public value; careerdossier-components
%% owns the page furniture and therefore the resulting decision.
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      { medium = \l__cdossier_cv_medium_tl }
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
\CDossierApplyBodySize

\__cdossier_components_doctype:n { Curriculum\c_space_tl Vitae }

\exp_args:NV \CDossierApplyGeometry:n \l__cdossier_cv_paper_tl

\setlength { \parindent } { 0pt }
\setlength { \parskip }   { \CDossierRecordParSkip }

%% A4's narrower text block needs a little extra paragraph flexibility for
%% prose-heavy CV entries. Letter output retains its established line-breaking
%% behavior; this does not alter margins, type size, or page furniture.
\str_if_eq:VnT \l__cdossier_cv_paper_tl { a4paper }
  { \setlength { \emergencystretch } { 2em } }

\__cdossier_components_runninglabel:n { Curriculum~Vitae }
\MakeCDossierPageFurniture
\CDossierApplyPageBreakPenalties

%% The keep-together penalty (issue #145) after the heading and rule keeps the
%% title with the content that follows it, so a section heading is never
%% stranded alone at the foot of a page.
\NewDocumentCommand \CDossierSection { m }
  {
    \par
    \addvspace { \CDossierRecordSectionAboveSkip }
    \__cdossier_typography_heading:n
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
    \addvspace { \CDossierRecordEntryAboveSkip }
    \__cdossier_components_entryhead:VVVV
      \l__cdossier_cv_entry_title_tl
      \l__cdossier_cv_entry_org_tl
      \l__cdossier_cv_entry_loc_tl
      \l__cdossier_cv_entry_dates_tl
    %% Issue #145: keep the entry heading with the first line of its body, so
    %% the heading cannot be stranded alone at the foot of a page.
    \penalty \CDossierHeadingKeepPenalty
    %% Issue #204: `\addvspace', not `\vspace'. As a `\vspace' this was extra
    %% space that added to whatever the entry body opened with, so a bullet list
    %% sat further from the entry heading that owns it than from the next entry.
    %% As an `\addvspace' the token is the *floor* for the heading -> body
    %% boundary, which a list overrides with its own edge.
    \addvspace { \CDossierRecordEntryGapSkip }
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
