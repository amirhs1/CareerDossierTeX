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
\ProvidesExplClass {careerdossier-resume} {2026-07-30} {0.6.0}
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

\msg_new:nnnn { careerdossier-resume } { unknown-option }
  {
    Unknown~class~option~'#1'~for~careerdossier-resume.~
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
\msg_new:nnnn { careerdossier-resume } { unknown-medium }
  { Unknown~'medium'~value~'#1'~for~careerdossier-resume. }
  {
    The~accepted~values~are~'print'~(running~header~and~'Page~N~of~M'~folio)~
    and~'screen'~(neither).
  }

\keys_define:nn { cdossier / resume }
  {
    fontsize .choices:nn =
      { 10pt , 11pt , 12pt }
      { \tl_set_eq:NN \l__cdossier_resume_fontsize_tl \l_keys_choice_tl } ,
    fontsize .value_required:n = true ,
    margin .choices:nn =
      { normal , narrow }
      { \tl_set_eq:NN \l__cdossier_resume_margin_tl \l_keys_choice_tl } ,
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
    paper .value_required:n = true ,
    bodyfont .choices:nn =
      { serif , sans }
      { \tl_set_eq:NN \l__cdossier_resume_bodyfont_tl \l_keys_choice_tl } ,
    bodyfont .value_required:n = true ,
    medium .choices:nn =
      { print , screen }
      { \tl_set_eq:NN \l__cdossier_resume_medium_tl \l_keys_choice_tl } ,
    medium / unknown .code:n =
      { \msg_error:nnn { careerdossier-resume } { unknown-medium } {#1} } ,
    medium .value_required:n = true ,
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
%% Issue #184: the class validates the public value; careerdossier-components
%% owns the page furniture and therefore the resulting decision.
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      { medium = \l__cdossier_resume_medium_tl }
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
\CDossierApplyBodySize

%% Declare the document type so the shared PDF-metadata code can title this
%% document distinctly from a letter built off the same profile. The title
%% itself is assembled in careerdossier-components, which owns identity.
\__cdossier_components_doctype:n { Résumé }

\exp_args:NV \CDossierApplyGeometry:n \l__cdossier_resume_paper_tl

\__cdossier_components_runninglabel:n { Résumé }
\MakeCDossierPageFurniture

\setlength { \parindent } { 0pt }
\setlength { \parskip }   { \CDossierParSkip }
\CDossierApplyPageBreakPenalties

%% ---------------------------------------------------------------------------
%% \CDossierSection {title} -- a résumé section heading followed by a full-width
%% rule. Uses the semantic section style with class-controlled size, spacing,
%% and rule colour. The keep-together penalty (issue #145) after the heading
%% and rule keeps the title with the content that follows it, so a section
%% heading is never stranded alone at the foot of a page.
%% ---------------------------------------------------------------------------
\NewDocumentCommand \CDossierSection { m }
  {
    \par
    \addvspace { \CDossierSectionAboveSkip }
    \__cdossier_typography_heading:n
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
    \addvspace { \CDossierEntryAboveSkip }
    \__cdossier_components_entryhead:VVVV
      \l__cdossier_resume_entry_title_tl
      \l__cdossier_resume_entry_org_tl
      \l__cdossier_resume_entry_loc_tl
      \l__cdossier_resume_entry_dates_tl
    %% Issue #145: keep the entry heading with the first line of its body, so
    %% the heading cannot be stranded alone at the foot of a page.
    \penalty \CDossierHeadingKeepPenalty
    \vspace { \CDossierEntryGapSkip }
  }
  {
    \par
    \addvspace { \CDossierEntryBelowSkip }
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
%% so `\CDossierListEdgeSkipBefore' passes through it and the shared component
%% call below substitutes `\CDossierListEdgeSkipAfter' for the closing edge.
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
            topsep     = \CDossierListEdgeSkipBefore ,
            itemsep    = \CDossierItemSepSkip ,
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
            topsep     = \CDossierListEdgeSkipBefore ,
            itemsep    = \CDossierItemSepSkip ,
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
