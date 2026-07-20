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
%% English industry dossier: US Letter geometry, the two supported class
%% options, disabled page numbers, and the section, entry, and list structures.
%% Reusable identity and contact logic lives in careerdossier-components; this
%% class only arranges it on the page.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass {careerdossier-resume} {2026-07-20} {0.4.0}
  {CareerDossierTeX English industry résumé class}

%% ---------------------------------------------------------------------------
%% Class options (l3keys). Only fontsize and density are user-facing; paper,
%% language, and theme are fixed in v0.1.0. Unsupported keys and choice values
%% are rejected with an actionable message rather than silently ignored.
%% ---------------------------------------------------------------------------
\RequirePackage { l3keys2e }

\tl_new:N \l__cdossier_resume_fontsize_tl
\tl_set:Nn \l__cdossier_resume_fontsize_tl { 10pt }
\tl_new:N \l__cdossier_resume_density_tl
\tl_set:Nn \l__cdossier_resume_density_tl { compact }

\msg_new:nnnn { careerdossier-resume } { unknown-option }
  { Unknown~class~option~'#1'~for~careerdossier-resume. }
  {
    Supported~options~are~'fontsize'~(10pt,~11pt)~and~
    'density'~(compact,~standard).~Paper,~language,~and~theme~are~fixed~
    in~v0.1.0~and~cannot~be~set~here.
  }

\keys_define:nn { cdossier / resume }
  {
    fontsize .choices:nn =
      { 10pt , 11pt }
      { \tl_set_eq:NN \l__cdossier_resume_fontsize_tl \l_keys_choice_tl } ,
    fontsize .value_required:n = true ,
    density  .choices:nn =
      { compact , standard }
      { \tl_set_eq:NN \l__cdossier_resume_density_tl \l_keys_choice_tl } ,
    density  .value_required:n = true ,
    unknown  .code:n =
      { \msg_error:nnx { careerdossier-resume } { unknown-option }
          { \l_keys_key_str } } ,
  }
\ProcessKeysOptions { cdossier / resume }

%% Load a minimal base class with the resolved body size and fixed paper. The
%% font size tl is expanded so article sees a literal option such as `10pt'.
\use:x
  {
    \exp_not:N \LoadClass
      [ \l__cdossier_resume_fontsize_tl , letterpaper ]
      { article }
  }

%% ---------------------------------------------------------------------------
%% Shared modules. careerdossier-components pulls in base, typography (the
%% LuaLaTeX engine guard and fonts), and theme; geometry, enumitem, and hyperref
%% complete the page and link machinery. hyperref loads last so the theme's
%% print-safe link hook applies regardless of order.
%% ---------------------------------------------------------------------------
\RequirePackage { careerdossier-components }
\RequirePackage { geometry }
\RequirePackage { enumitem }
\RequirePackage { hyperref }

%% Declare the document type so the shared PDF-metadata code can title this
%% document distinctly from a letter built off the same profile. The title
%% itself is assembled in careerdossier-components, which owns identity.
\__cdossier_components_doctype:n { Résumé }

%% US Letter geometry with compact but comfortable résumé margins.
\geometry
  {
    letterpaper ,
    top    = 0.5in ,
    bottom = 0.6in ,
    left   = 0.6in ,
    right  = 0.6in ,
  }

%% No page numbers by default: an industry résumé header carries identity, not
%% folios. Users who want them can restore a page style in their document.
\pagestyle { empty }

\setlength { \parindent } { 0pt }
\setlength { \parskip }   { 0pt plus 1pt }

%% ---------------------------------------------------------------------------
%% Density-dependent vertical rhythm. compact tightens spacing for short
%% one-page résumés; standard opens it up. All values are collected here so the
%% two modes stay easy to compare and adjust.
%% ---------------------------------------------------------------------------
\bool_new:N \l__cdossier_resume_compact_bool
\str_if_eq:VnTF \l__cdossier_resume_density_tl { compact }
  { \bool_set_true:N  \l__cdossier_resume_compact_bool }
  { \bool_set_false:N \l__cdossier_resume_compact_bool }

\skip_new:N \l__cdossier_resume_sectionabove_skip
\skip_new:N \l__cdossier_resume_sectiongap_skip
\skip_new:N \l__cdossier_resume_sectionbelow_skip
\skip_new:N \l__cdossier_resume_entryabove_skip
\skip_new:N \l__cdossier_resume_entrygap_skip
\skip_new:N \l__cdossier_resume_entrybelow_skip
\skip_new:N \l__cdossier_resume_itemsep_skip
\skip_new:N \l__cdossier_resume_itemtop_skip
\dim_new:N  \l__cdossier_resume_rule_dim
\dim_set:Nn \l__cdossier_resume_rule_dim { 0.4pt }

\bool_if:NTF \l__cdossier_resume_compact_bool
  {
    \skip_set:Nn \l__cdossier_resume_sectionabove_skip { 8pt  plus 2pt minus 1pt }
    \skip_set:Nn \l__cdossier_resume_sectiongap_skip   { 2pt }
    \skip_set:Nn \l__cdossier_resume_sectionbelow_skip { 4pt  plus 1pt }
    \skip_set:Nn \l__cdossier_resume_entryabove_skip   { 4pt  plus 1pt }
    \skip_set:Nn \l__cdossier_resume_entrygap_skip     { 1pt }
    \skip_set:Nn \l__cdossier_resume_entrybelow_skip   { 3pt  plus 1pt }
    \skip_set:Nn \l__cdossier_resume_itemsep_skip      { 1pt }
    \skip_set:Nn \l__cdossier_resume_itemtop_skip      { 1pt }
  }
  {
    \skip_set:Nn \l__cdossier_resume_sectionabove_skip { 12pt plus 3pt minus 2pt }
    \skip_set:Nn \l__cdossier_resume_sectiongap_skip   { 3pt }
    \skip_set:Nn \l__cdossier_resume_sectionbelow_skip { 6pt  plus 2pt }
    \skip_set:Nn \l__cdossier_resume_entryabove_skip   { 8pt  plus 2pt }
    \skip_set:Nn \l__cdossier_resume_entrygap_skip     { 2pt }
    \skip_set:Nn \l__cdossier_resume_entrybelow_skip   { 5pt  plus 2pt }
    \skip_set:Nn \l__cdossier_resume_itemsep_skip      { 3pt }
    \skip_set:Nn \l__cdossier_resume_itemtop_skip      { 2pt }
  }

%% ---------------------------------------------------------------------------
%% \CDossierSection {title} -- a résumé section heading followed by a full-width
%% rule. Uses the semantic section style with class-controlled size, spacing,
%% and rule colour. \nobreak after the heading and rule keeps the title with the
%% content that follows it.
%% ---------------------------------------------------------------------------
\NewDocumentCommand \CDossierSection { m }
  {
    \par
    \addvspace { \l__cdossier_resume_sectionabove_skip }
    \noindent { \CDossierSectionStyle \large #1 }
    \par \nobreak
    \vspace { \l__cdossier_resume_sectiongap_skip }
    \noindent
      { \CDossierRuleColor \rule { \linewidth } { \l__cdossier_resume_rule_dim } }
    \par \nobreak
    \vspace { \l__cdossier_resume_sectionbelow_skip }
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
    \addvspace { \l__cdossier_resume_entryabove_skip }
    \__cdossier_components_entryhead:VVVV
      \l__cdossier_resume_entry_title_tl
      \l__cdossier_resume_entry_org_tl
      \l__cdossier_resume_entry_loc_tl
      \l__cdossier_resume_entry_dates_tl
    \nobreak
    \vspace { \l__cdossier_resume_entrygap_skip }
  }
  {
    \par
    \addvspace { \l__cdossier_resume_entrybelow_skip }
  }

%% ---------------------------------------------------------------------------
%% CDossierItemize -- a résumé-appropriate bullet list with tight, density-aware
%% spacing and a modest indent. Prefer this over redefining itemize globally.
%% ---------------------------------------------------------------------------
\NewDocumentEnvironment { CDossierItemize } { }
  {
    \begin { itemize }
      [
        leftmargin = 1.4em ,
        labelsep   = 0.5em ,
        topsep     = \l__cdossier_resume_itemtop_skip ,
        itemsep    = \l__cdossier_resume_itemsep_skip ,
        parsep     = 0pt ,
        label      = \textbullet ,
      ]
  }
  { \end { itemize } }

\endinput
