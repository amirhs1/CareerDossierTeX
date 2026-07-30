%% careerdossier-statement.cls
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
%% careerdossier-statement owns the shared English statement document model:
%% Letter/A4 geometry, statement-scoped metadata, type-specific validation,
%% the first-page identity block, and continuation-page furniture. Shared
%% profile storage and link/separator rendering remain in the base and
%% components modules.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass {careerdossier-statement} {2026-07-30} {0.6.0}
  {CareerDossierTeX English statement class}

%% ---------------------------------------------------------------------------
%% Statement type. Interest is the default so authors can create a
%% statement without opting into a type-specific validation contract.
%% ---------------------------------------------------------------------------
\RequirePackage { l3keys2e }
\tl_new:N   \l__cdossier_statement_type_tl
\tl_new:N   \l__cdossier_statement_paper_tl
\tl_new:N   \l__cdossier_statement_bodyfont_tl
\tl_new:N   \l__cdossier_statement_fontsize_tl
\tl_new:N   \l__cdossier_statement_margin_tl
\tl_set:Nn  \l__cdossier_statement_type_tl { interest }
\tl_set:Nn  \l__cdossier_statement_paper_tl { letterpaper }
\tl_set:Nn  \l__cdossier_statement_bodyfont_tl { serif }
\tl_set:Nn  \l__cdossier_statement_fontsize_tl { 12pt }
\tl_set:Nn  \l__cdossier_statement_margin_tl { normal }

\msg_new:nnnn { careerdossier-statement } { unknown-type }
  { Unknown~statement~type~'#1'. }
  {
    The~accepted~types~are:~interest,~research,~teaching,~
    teaching-philosophy,~diversity,~artist,~purpose.
  }

\msg_new:nnnn { careerdossier-statement } { unknown-option }
  { Unknown~class~option~'#1'~for~careerdossier-statement. }
  {
    Supported~options~are~'type'~(interest,~research,~teaching,~
    teaching-philosophy,~diversity,~artist,~purpose),~
    'fontsize'~(10pt,~11pt,~12pt),~'margin'~(normal,~narrow),~
    'paper'~(letter,~a4),~and~
    'bodyfont'~(serif,~sans).~Language,~theme,~and~named~font~combinations~
    cannot~be~set~here.
  }

\keys_define:nn { cdossier / statement }
  {
    type .code:n =
      {
        \str_case:nnF {#1}
          {
            { interest }
              { \tl_set:Nn \l__cdossier_statement_type_tl { interest } }
            { research }            { \tl_set:Nn \l__cdossier_statement_type_tl { research } }
            { teaching }            { \tl_set:Nn \l__cdossier_statement_type_tl { teaching } }
            { teaching-philosophy }
              { \tl_set:Nn \l__cdossier_statement_type_tl { teaching-philosophy } }
            { diversity }           { \tl_set:Nn \l__cdossier_statement_type_tl { diversity } }
            { artist }              { \tl_set:Nn \l__cdossier_statement_type_tl { artist } }
            { purpose }             { \tl_set:Nn \l__cdossier_statement_type_tl { purpose } }
          }
          { \msg_error:nnn { careerdossier-statement } { unknown-type } {#1} }
      } ,
    type .value_required:n = true ,
    fontsize .choices:nn =
      { 10pt , 11pt , 12pt }
      { \tl_set_eq:NN \l__cdossier_statement_fontsize_tl \l_keys_choice_tl } ,
    fontsize .value_required:n = true ,
    margin .choices:nn =
      { normal , narrow }
      { \tl_set_eq:NN \l__cdossier_statement_margin_tl \l_keys_choice_tl } ,
    margin .value_required:n = true ,
    paper .choices:nn =
      { letter , a4 }
      {
        \str_case:Vn \l_keys_choice_tl
          {
            { letter } { \tl_set:Nn \l__cdossier_statement_paper_tl { letterpaper } }
            { a4 }     { \tl_set:Nn \l__cdossier_statement_paper_tl { a4paper } }
          }
      } ,
    paper .value_required:n = true ,
    bodyfont .choices:nn =
      { serif , sans }
      { \tl_set_eq:NN \l__cdossier_statement_bodyfont_tl \l_keys_choice_tl } ,
    bodyfont .value_required:n = true ,
    unknown .code:n =
      { \msg_error:nnx { careerdossier-statement } { unknown-option }
          { \l_keys_key_str } } ,
  }
\ProcessKeysOptions { cdossier / statement }

\str_if_eq:VnT \l__cdossier_statement_bodyfont_tl { sans }
  { \PassOptionsToPackage { bodyfont = sans } { careerdossier-typography } }
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      {
        fontsize = \l__cdossier_statement_fontsize_tl ,
        margin = \l__cdossier_statement_margin_tl
      }
      { careerdossier-tokens }
  }

\use:x
  {
    \exp_not:N \LoadClass
      [ \l__cdossier_statement_fontsize_tl , \l__cdossier_statement_paper_tl ]
      { article }
  }

\RequirePackage { careerdossier-components }
\RequirePackage { careerdossier-tokens }
\RequirePackage { hyperref }
\CDossierApplyBodySize

\exp_args:NV \CDossierApplyGeometry:n \l__cdossier_statement_paper_tl
\setlength { \parindent }        { 0pt }
\setlength { \parskip }          { \CDossierProseParSkip }
\setlength { \emergencystretch } { 2em }

%% Typographic page-break penalties (issue #171): see careerdossier-tokens for
%% the shared values and the reasoning for using one strength across families.
\CDossierApplyPageBreakPenalties

%% ---------------------------------------------------------------------------
%% Section headings (issue #177).
%%
%% A statement is continuous prose, so its headings are not the résumé's ruled
%% section furniture: no decorative rule, and a smaller, quieter break in the
%% text. What they are is `article''s heading defaults -- \Large (17.28 pt at a
%% 12 pt base), the body typeface, and `article''s own display skips -- none of
%% which belong to the calibrated design.
%%
%% The heading is therefore restyled rather than replaced. `\@startsection' is
%% kept because the kernel's tagging support hooks into it: with tagging
%% active, `\section*' opens a `Sect' division that encloses the heading *and*
%% the content it introduces, and records the heading text as that element's
%% title. A hand-rolled heading built on the shared display primitive emits a
%% bare heading element with neither, so replacing the mechanism to gain the
%% tokens would have paid for them in structure. Only the four arguments that
%% carry visual design change here; the sectioning mechanism does not.
%%
%% Size and typeface come from the shared semantic role and type scale, so a
%% statement heading is the same size as a résumé or CV section heading, and
%% the sans heading face is used in both body-font modes. A subsection is set
%% in the same role one step down the scale, at body size: the level is carried
%% by size and spacing, not by a second heading typeface.
%%
%% Both skips are stated as the *complete* gap a reader sees, which costs an
%% explicit subtraction. A heading is a paragraph, and so is the text under it,
%% so TeX contributes `\parskip' on each side beyond whatever the skip asks
%% for -- and in this class `\parskip' is a visible 0.50 line. Passing the raw
%% token would render every gap half a line wider than the token says, which is
%% precisely the failure #168 removed from the section rule. Subtracting
%% `\parskip' here keeps the token's stated value and the rendered gap the same
%% number, and the smoke fixture asserts that.
%%
%% The subtraction has a hard lower bound: `\@xsect' treats a non-positive
%% after-skip as a request for a *run-in* heading, so a below-token that fell
%% to `\parskip' would silently turn every statement heading into a run-in one.
%% The tokens are set well clear of that, and the fixture asserts the bound
%% rather than clamping it here, so an unusable retune fails loudly.
%% ---------------------------------------------------------------------------
\ExplSyntaxOff
\makeatletter
\renewcommand \section
  {
    \@startsection {section} {1} {\z@}
      {-\dimexpr \CDossierProseSectionAboveSkip - \parskip \relax}
      {\dimexpr \CDossierProseSectionBelowSkip - \parskip \relax}
      {\CDossierSectionStyle \CDossierSizeSection}
  }
\renewcommand \subsection
  {
    \@startsection {subsection} {2} {\z@}
      {-\dimexpr \CDossierProseSubsectionAboveSkip - \parskip \relax}
      {\dimexpr \CDossierProseSubsectionBelowSkip - \parskip \relax}
      {\CDossierSectionStyle \CDossierSizeBody}
  }
\makeatother
\ExplSyntaxOn

%% \CDossierSection {title} and \CDossierSubsection {title} -- the class's own
%% names for the two calibrated heading levels, matching the résumé and CV
%% interface so one profile's documents are written the same way. Each is a
%% thin wrapper over the restyled unnumbered heading above rather than a second
%% implementation: a statement numbers nothing, and one renderer means the
%% tokens and the tagged structure cannot drift between the two spellings.
\NewDocumentCommand \CDossierSection { m }
  { \section* {#1} }
\NewDocumentCommand \CDossierSubsection { m }
  { \subsection* {#1} }

%% ---------------------------------------------------------------------------
%% Type defaults and displayed contact set.
%% ---------------------------------------------------------------------------
\tl_new:N \l__cdossier_statement_default_title_tl
\tl_new:N \l__cdossier_statement_default_running_title_tl
\tl_new:N \l__cdossier_statement_title_tl
\tl_new:N \l__cdossier_statement_running_title_tl
\clist_new:N \l__cdossier_statement_contacts_clist

\cs_new_protected:Npn \__cdossier_statement_select_defaults:
  {
    \str_case:VnF \l__cdossier_statement_type_tl
      {
        { interest }
          {
            \tl_set:Nn \l__cdossier_statement_default_title_tl
              { Statement~of~Interest }
            \tl_set:Nn \l__cdossier_statement_default_running_title_tl
              { Statement~of~Interest }
            \clist_set:Nn \l__cdossier_statement_contacts_clist
              { email , phone , website }
          }
        { research }
          {
            \tl_set:Nn \l__cdossier_statement_default_title_tl { Research~Statement }
            \tl_set:Nn \l__cdossier_statement_default_running_title_tl { Research~Statement }
            \clist_set:Nn \l__cdossier_statement_contacts_clist
              { email , phone , website , scholar , orcid }
          }
        { teaching }
          {
            \tl_set:Nn \l__cdossier_statement_default_title_tl { Teaching~Statement }
            \tl_set:Nn \l__cdossier_statement_default_running_title_tl { Teaching~Statement }
            \clist_set:Nn \l__cdossier_statement_contacts_clist
              { email , phone , website }
          }
        { teaching-philosophy }
          {
            \tl_set:Nn \l__cdossier_statement_default_title_tl
              { Statement~of~Teaching~Philosophy }
            \tl_set:Nn \l__cdossier_statement_default_running_title_tl
              { Teaching~Philosophy }
            \clist_set:Nn \l__cdossier_statement_contacts_clist
              { email , phone , website }
          }
        { diversity }
          {
            \tl_set:Nn \l__cdossier_statement_default_title_tl
              { Statement~of~Contributions~to~Equity,~Diversity,~Inclusion,~and~Accessibility }
            \tl_set:Nn \l__cdossier_statement_default_running_title_tl
              { EDIA~Statement }
            \clist_set:Nn \l__cdossier_statement_contacts_clist
              { email , phone , website }
          }
        { artist }
          {
            \tl_set:Nn \l__cdossier_statement_default_title_tl { Artist~Statement }
            \tl_set:Nn \l__cdossier_statement_default_running_title_tl { Artist~Statement }
            \clist_set:Nn \l__cdossier_statement_contacts_clist
              { email , phone , website }
          }
        { purpose }
          {
            \tl_set:Nn \l__cdossier_statement_default_title_tl { Statement~of~Purpose }
            \tl_set:Nn \l__cdossier_statement_default_running_title_tl { Statement~of~Purpose }
            \clist_set:Nn \l__cdossier_statement_contacts_clist
              { email , phone , website }
          }
      }
      { }
    \tl_set_eq:NN \l__cdossier_statement_title_tl
      \l__cdossier_statement_default_title_tl
    \tl_set_eq:NN \l__cdossier_statement_running_title_tl
      \l__cdossier_statement_default_running_title_tl
  }
\__cdossier_statement_select_defaults:

%% The full display title, not its abbreviated page-furniture counterpart,
%% becomes the shared PDF document type.
\exp_args:NV \__cdossier_components_doctype:n
  \l__cdossier_statement_title_tl

%% ---------------------------------------------------------------------------
%% Statement-scoped metadata. Blank title overrides restore their type default;
%% other blank values are simply absent when the header renders.
%% ---------------------------------------------------------------------------
\tl_new:N \l__cdossier_statement_subtitle_tl
\tl_new:N \l__cdossier_statement_context_tl
\tl_new:N \l__cdossier_statement_application_id_tl

\msg_new:nnnn { careerdossier-statement } { unknown-meta-key }
  { Unknown~\c_backslash_str CDossierStatementSetup~key~'#1'. }
  {
    The~supported~keys~are:~title,~running-title,~subtitle,~
    application-context,~application-id.
  }

\cs_new_protected:Npn \__cdossier_statement_set_title:n #1
  {
    \tl_set:Nn \l__cdossier_statement_title_tl {#1}
    \tl_if_blank:VT \l__cdossier_statement_title_tl
      {
        \tl_set_eq:NN \l__cdossier_statement_title_tl
          \l__cdossier_statement_default_title_tl
      }
    \exp_args:NV \__cdossier_components_doctype:n
      \l__cdossier_statement_title_tl
  }

\cs_new_protected:Npn \__cdossier_statement_set_running_title:n #1
  {
    \tl_set:Nn \l__cdossier_statement_running_title_tl {#1}
    \tl_if_blank:VT \l__cdossier_statement_running_title_tl
      {
        \tl_set_eq:NN \l__cdossier_statement_running_title_tl
          \l__cdossier_statement_default_running_title_tl
      }
  }

\keys_define:nn { cdossier / statementdata }
  {
    title .code:n = { \__cdossier_statement_set_title:n {#1} } ,
    title .value_required:n = true ,
    running-title .code:n =
      { \__cdossier_statement_set_running_title:n {#1} } ,
    running-title .value_required:n = true ,
    subtitle .tl_set:N = \l__cdossier_statement_subtitle_tl ,
    subtitle .value_required:n = true ,
    application-context .tl_set:N = \l__cdossier_statement_context_tl ,
    application-context .value_required:n = true ,
    application-id .tl_set:N = \l__cdossier_statement_application_id_tl ,
    application-id .value_required:n = true ,
    unknown .code:n =
      { \msg_error:nnx { careerdossier-statement } { unknown-meta-key }
          { \l_keys_key_str } } ,
  }

\NewDocumentCommand \CDossierStatementSetup { m }
  { \keys_set:nn { cdossier / statementdata } {#1} }

\__cdossier_components_runninglabel:n
  { \tl_use:N \l__cdossier_statement_running_title_tl }
\MakeCDossierPageFurniture

%% ---------------------------------------------------------------------------
%% Header rendering and validation.
%% ---------------------------------------------------------------------------
\cs_new_protected:Npn \__cdossier_statement_validate:
  {
    \__cdossier_base_require_name:N \MakeCDossierStatementHeader
    \__cdossier_base_require_field:n { email }
    \str_if_eq:VnT \l__cdossier_statement_type_tl { research }
      { \__cdossier_base_require_field:n { affiliation } }
    \str_if_eq:VnT \l__cdossier_statement_type_tl { artist }
      { \__cdossier_base_require_field:n { website } }
  }

\cs_new_protected:Npn \__cdossier_statement_contextline:
  {
    \tl_if_blank:VF \l__cdossier_statement_context_tl
      { \tl_use:N \l__cdossier_statement_context_tl }
    \bool_lazy_and:nnT
      { ! \tl_if_blank_p:V \l__cdossier_statement_context_tl }
      { ! \tl_if_blank_p:V \l__cdossier_statement_application_id_tl }
      { \__cdossier_components_sep: }
    \tl_if_blank:VF \l__cdossier_statement_application_id_tl
      { Application~ID:~\tl_use:N \l__cdossier_statement_application_id_tl }
  }

\NewDocumentCommand \MakeCDossierStatementHeader { }
  {
    \__cdossier_statement_validate:
    \par
    \addvspace { \CDossierHeaderAboveSkip }
    \group_begin:
      \centering
      {
        \CDossierNameStyle \CDossierSizeName
        \CDossierPrintField { name } \par
      }
      \vspace { \CDossierHeaderNameGapSkip }
      \__cdossier_typography_heading:n
        {
          \CDossierSectionStyle \CDossierSizeTitle
          \tl_use:N \l__cdossier_statement_title_tl
        }
      \tl_if_blank:VF \l__cdossier_statement_subtitle_tl
        {
          \vspace { \CDossierHeaderMetaGapSkip }
          { \CDossierHeadlineStyle \CDossierSizeHeadline
            \tl_use:N \l__cdossier_statement_subtitle_tl \par }
        }
      \CDossierIfFieldTF { affiliation }
        {
          \vspace { \CDossierHeaderMetaGapSkip }
          {
            \CDossierBodyStyle \CDossierSizeBody
            \CDossierPrintField { affiliation } \par
          }
        }
        { }
      \bool_lazy_or:nnT
        { ! \tl_if_blank_p:V \l__cdossier_statement_context_tl }
        { ! \tl_if_blank_p:V \l__cdossier_statement_application_id_tl }
        {
          \vspace { \CDossierHeaderMetaGapSkip }
          {
            \CDossierMutedStyle \CDossierSizeSmall
            \__cdossier_statement_contextline: \par
          }
        }
      \vspace { \CDossierHeaderMetaGapSkip }
      { \CDossierBodyStyle \CDossierSizeSmall
        \__cdossier_components_contactparagraph:N
          \l__cdossier_statement_contacts_clist
      }
    \group_end:
    \addvspace { \CDossierHeaderBelowSkip }
  }

\endinput
