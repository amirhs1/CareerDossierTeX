%% careerdossier-resume.cls
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
%% careerdossier-resume owns résumé-specific page behaviour for the v0.1.0
%% English industry dossier: Letter/A4 geometry, class options, and the
%% section, entry, and list structures.
%% Reusable identity and contact logic lives in careerdossier-components; this
%% class only arranges it on the page.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass {careerdossier-resume} {2026-08-04} {0.7.0}
  {CareerDossierTeX English industry résumé class}

%% ---------------------------------------------------------------------------
%% Class options (l3keys). Unsupported keys and choice values are rejected with
%% an actionable message rather than silently ignored.
%% ---------------------------------------------------------------------------
\RequirePackage { l3keys2e }

\tl_new:N \l__cdossier_resume_fontsize_tl
\tl_set:Nn \l__cdossier_resume_fontsize_tl { 11pt }
\tl_new:N \l__cdossier_resume_margin_tl
\tl_set:Nn \l__cdossier_resume_margin_tl { narrow }
\tl_new:N \l__cdossier_resume_paper_tl
\tl_set:Nn \l__cdossier_resume_paper_tl { letterpaper }
\tl_new:N \l__cdossier_resume_bodyfont_tl
\tl_set:Nn \l__cdossier_resume_bodyfont_tl { serif }
\tl_new:N \l__cdossier_resume_medium_tl
\tl_set:Nn \l__cdossier_resume_medium_tl { print }
\tl_new:N \l__cdossier_resume_muted_tl
\tl_set:Nn \l__cdossier_resume_muted_tl { italic }

\msg_new:nnnn { careerdossier-resume } { unknown-option }
  {
    Unknown~class~option~'#1'~for~careerdossier-resume.~
    Supported~options~are~'fontsize',~'margin',~'paper',~'bodyfont',~
    'medium',~and~'muted'.
  }
  {
    Supported~options~are~'fontsize'~(10pt,~11pt,~12pt),~
    'margin'~(normal,~narrow),~
    'paper'~(letter,~a4),~
    'bodyfont'~(serif,~sans),~
    'medium'~(print,~screen),~and~
    'muted'~(italic,~gray,~both).~Language~and~theme~cannot~be~set~here.
  }

%% l3keys' own choice error reports that the value is not one of a fixed set
%% without saying what that set is, so every choice-valued option below names
%% its own accepted values. Each message is reached through the matching
%% `<key> / unknown' sub-key, which l3keys runs in place of its stock error.
\msg_new:nnnn { careerdossier-resume } { unknown-fontsize }
  { Unknown~'fontsize'~value~'#1'~for~careerdossier-resume. }
  { The~accepted~values~are~'10pt',~'11pt',~and~'12pt'. }

\msg_new:nnnn { careerdossier-resume } { unknown-margin }
  { Unknown~'margin'~value~'#1'~for~careerdossier-resume. }
  {
    The~accepted~values~are~'normal'~(one-inch~margins)~and~
    'narrow'~(half-inch~margins).
  }

\msg_new:nnnn { careerdossier-resume } { unknown-paper }
  { Unknown~'paper'~value~'#1'~for~careerdossier-resume. }
  { The~accepted~values~are~'letter'~(US~Letter)~and~'a4'~(ISO~A4). }

\msg_new:nnnn { careerdossier-resume } { unknown-bodyfont }
  { Unknown~'bodyfont'~value~'#1'~for~careerdossier-resume. }
  {
    The~accepted~values~are~'serif'~(TeX~Gyre~Termes~body)~and~
    'sans'~(TeX~Gyre~Heros~body).
  }

\msg_new:nnnn { careerdossier-resume } { unknown-medium }
  { Unknown~'medium'~value~'#1'~for~careerdossier-resume. }
  {
    The~accepted~values~are~'print'~(running~header~and~'Page~N~of~M'~folio)~
    and~'screen'~(neither).
  }

\msg_new:nnnn { careerdossier-resume } { unknown-muted }
  { Unknown~'muted'~value~'#1'~for~careerdossier-resume. }
  {
    The~accepted~values~are~'italic'~(italic,~black),~
    'gray'~(upright,~gray~0.30),~and~'both'~(italic~and~gray).
  }

\keys_define:nn { cdossier / resume }
  {
    fontsize .choices:nn =
      { 10pt , 11pt , 12pt }
      { \tl_set_eq:NN \l__cdossier_resume_fontsize_tl \l_keys_choice_tl } ,
    fontsize / unknown .code:n =
      { \msg_error:nnn { careerdossier-resume } { unknown-fontsize } {#1} } ,
    fontsize .value_required:n = true ,
    margin .choices:nn =
      { normal , narrow }
      { \tl_set_eq:NN \l__cdossier_resume_margin_tl \l_keys_choice_tl } ,
    margin / unknown .code:n =
      { \msg_error:nnn { careerdossier-resume } { unknown-margin } {#1} } ,
    margin .value_required:n = true ,
    paper .choices:nn =
      { letter , a4 }
      {
        \str_case:Vn \l_keys_choice_tl
          {
            { letter } { \tl_set:Nn \l__cdossier_resume_paper_tl { letterpaper } }
            { a4 }     { \tl_set:Nn \l__cdossier_resume_paper_tl { a4paper } }
          }
      } ,
    paper / unknown .code:n =
      { \msg_error:nnn { careerdossier-resume } { unknown-paper } {#1} } ,
    paper .value_required:n = true ,
    bodyfont .choices:nn =
      { serif , sans }
      { \tl_set_eq:NN \l__cdossier_resume_bodyfont_tl \l_keys_choice_tl } ,
    bodyfont / unknown .code:n =
      { \msg_error:nnn { careerdossier-resume } { unknown-bodyfont } {#1} } ,
    bodyfont .value_required:n = true ,
    medium .choices:nn =
      { print , screen }
      { \tl_set_eq:NN \l__cdossier_resume_medium_tl \l_keys_choice_tl } ,
    medium / unknown .code:n =
      { \msg_error:nnn { careerdossier-resume } { unknown-medium } {#1} } ,
    medium .value_required:n = true ,
    muted .choices:nn =
      { italic , gray , both }
      { \tl_set_eq:NN \l__cdossier_resume_muted_tl \l_keys_choice_tl } ,
    muted / unknown .code:n =
      { \msg_error:nnn { careerdossier-resume } { unknown-muted } {#1} } ,
    muted .value_required:n = true ,
    unknown  .code:n =
      { \msg_error:nnx { careerdossier-resume } { unknown-option }
          { \l_keys_key_str } } ,
  }
\ProcessKeysOptions { cdossier / resume }

\str_if_eq:VnT \l__cdossier_resume_bodyfont_tl { sans }
  { \PassOptionsToPackage { bodyfont = sans } { careerdossier-typography } }
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      {
        fontsize = \l__cdossier_resume_fontsize_tl ,
        margin = \l__cdossier_resume_margin_tl
      }
      { careerdossier-tokens }
  }
%% Issues #184 and #271: the class validates the public values;
%% careerdossier-components owns the page furniture and the de-emphasis role,
%% and therefore owns both resulting decisions.
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      {
        medium = \l__cdossier_resume_medium_tl ,
        muted  = \l__cdossier_resume_muted_tl
      }
      { careerdossier-components }
  }

%% Load a minimal base class with the resolved body size and paper. The token
%% lists are expanded so article sees literal options such as `10pt,a4paper'.
\use:x
  {
    \exp_not:N \LoadClass
      [ \l__cdossier_resume_fontsize_tl , \l__cdossier_resume_paper_tl ]
      { article }
  }

%% ---------------------------------------------------------------------------
%% Shared modules. careerdossier-components pulls in base, typography (the
%% LuaLaTeX engine guard and fonts), and theme; geometry, enumitem, and hyperref
%% complete the page and link machinery. hyperref loads last so the theme's
%% print-safe link hook applies regardless of order.
%% ---------------------------------------------------------------------------
\RequirePackage { careerdossier-components }
\RequirePackage { careerdossier-tokens }
\RequirePackage { enumitem }
\RequirePackage { hyperref }
\__cdossier_tokens_apply_body_size:

%% Declare the document type so the shared PDF-metadata code can title this
%% document distinctly from a letter built off the same profile. The title
%% itself is assembled in careerdossier-components, which owns identity.
\__cdossier_components_doctype:n { Résumé }

\exp_args:NV \__cdossier_tokens_apply_geometry:n \l__cdossier_resume_paper_tl

\__cdossier_components_runninglabel:n { Résumé }
\__cdossier_components_apply_page_furniture:

\setlength { \parindent } { 0pt }
\setlength { \parskip }   { \CDossierRecordParSkip }
\CDossierApplyPageBreakPenalties

%% Issue #223: the shared header stack ends at a boundary against whatever the
%% class puts next -- here a ruled \CDossierSection -- so the class names the
%% token that owns it rather than sharing one gap with the letter and the
%% statement, whose next block is not a ruled section at all.
\__cdossier_components_headerbelow:N \CDossierRecordHeaderBelowSkip

%% ---------------------------------------------------------------------------
%% \CDossierSection {title} -- a résumé section heading followed by a full-width
%% rule. Uses the semantic section style with class-controlled size, spacing,
%% and rule colour. The keep-together penalty (issue #145) after the heading
%% and rule keeps the title with the content that follows it, so a section
%% heading is never stranded alone at the foot of a page.
%%
%% Issue #267: depth 2, not 1 -- the document identity (the name, in
%% \MakeCDossierHeader) is the document's one depth-1 heading, so every
%% résumé/CV section heading sits one level under it.
%% ---------------------------------------------------------------------------
\NewDocumentCommand \CDossierSection { m }
  {
    \par
    \addvspace { \CDossierRecordSectionAboveSkip }
    \__cdossier_typography_heading:nn { 2 }
      { { \CDossierSectionStyle \CDossierSizeSection #1 \par } }
    \__cdossier_components_section_rule:
  }

%% ---------------------------------------------------------------------------
%% CDossierEntry -- one résumé entry (job, degree, project, ...). Named keys are
%% self-documenting and extensible; only title is required. The heading itself
%% is rendered by the shared components primitive so the optional-field and
%% separator rules stay in one place; this environment supplies only résumé
%% spacing around it. The body is free content, typically a CDossierItemize.
%% ---------------------------------------------------------------------------
\tl_new:N \l__cdossier_resume_entry_title_tl
\tl_new:N \l__cdossier_resume_entry_org_tl
\tl_new:N \l__cdossier_resume_entry_loc_tl
\tl_new:N \l__cdossier_resume_entry_dates_tl

\msg_new:nnnn { careerdossier-resume } { unknown-entry-key }
  { Unknown~CDossierEntry~key~'#1'. }
  { The~supported~keys~are:~title,~organization,~location,~dates. }

\msg_new:nnnn { careerdossier-resume } { entry-missing-title }
  { A~CDossierEntry~is~missing~its~required~'title'. }
  {
    Add~a~title,~for~example: \\
    \c_backslash_str begin \c_left_brace_str CDossierEntry \c_right_brace_str
    [title~=~Data~Scientist]
  }

\keys_define:nn { cdossier / entry }
  {
    title        .tl_set:N = \l__cdossier_resume_entry_title_tl ,
    organization .tl_set:N = \l__cdossier_resume_entry_org_tl ,
    location     .tl_set:N = \l__cdossier_resume_entry_loc_tl ,
    dates        .tl_set:N = \l__cdossier_resume_entry_dates_tl ,
    unknown      .code:n =
      { \msg_error:nnx { careerdossier-resume } { unknown-entry-key }
          { \l_keys_key_str } } ,
  }

\NewDocumentEnvironment { CDossierEntry } { O{} }
  {
    \tl_clear:N \l__cdossier_resume_entry_title_tl
    \tl_clear:N \l__cdossier_resume_entry_org_tl
    \tl_clear:N \l__cdossier_resume_entry_loc_tl
    \tl_clear:N \l__cdossier_resume_entry_dates_tl
    \keys_set:nn { cdossier / entry } {#1}
    \tl_if_blank:VT \l__cdossier_resume_entry_title_tl
      { \msg_error:nn { careerdossier-resume } { entry-missing-title } }
    \par
    \addvspace { \CDossierRecordEntryAboveSkip }
    \__cdossier_components_entryhead:VVVV
      \l__cdossier_resume_entry_title_tl
      \l__cdossier_resume_entry_org_tl
      \l__cdossier_resume_entry_loc_tl
      \l__cdossier_resume_entry_dates_tl
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

%% ---------------------------------------------------------------------------
%% CDossierItemize -- a résumé-appropriate flush-left bullet list using shared
%% list and rhythm tokens. Prefer this over redefining itemize globally.
%%
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
%% ---------------------------------------------------------------------------
\dim_new:N \l__cdossier_resume_label_width_dim

\NewDocumentEnvironment { CDossierItemize } { }
  {
    \tag_if_active:TF
      {
        %% LaTeX Lab emulates enumitem while tagging is active and parses
        %% leftmargin as a dimension, so its interface cannot accept enumitem's
        %% `*' calculation. Measure the fixed bullet and supply the equivalent
        %% flush-left dimensions explicitly on that path.
        \hbox_set:Nn \l_tmpa_box { \textbullet }
        \dim_set:Nn \l__cdossier_resume_label_width_dim
          { \box_wd:N \l_tmpa_box }
        \begin { itemize }
          [
            leftmargin =
              \dim_eval:n
                {
                  \l__cdossier_resume_label_width_dim
                  + \CDossierListLabelSep
                } ,
            labelwidth = \l__cdossier_resume_label_width_dim ,
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

\endinput
