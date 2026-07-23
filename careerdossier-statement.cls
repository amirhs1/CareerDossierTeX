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
\ProvidesExplClass {careerdossier-statement} {2026-07-22} {0.5.0}
  {CareerDossierTeX English statement class}

%% ---------------------------------------------------------------------------
%% Statement type. General-interest is the default so authors can create a
%% statement without opting into a type-specific validation contract.
%% ---------------------------------------------------------------------------
\RequirePackage { l3keys2e }
\tl_new:N   \l__cdossier_statement_type_tl
\tl_new:N   \l__cdossier_statement_paper_tl
\tl_new:N   \l__cdossier_statement_bodyfont_tl
\tl_new:N   \l__cdossier_statement_theme_tl
\tl_new:N   \l__cdossier_statement_accent_tl
\bool_new:N \l__cdossier_statement_accent_explicit_bool
\tl_set:Nn  \l__cdossier_statement_type_tl { general-interest }
\tl_set:Nn  \l__cdossier_statement_paper_tl { letterpaper }
\tl_set:Nn  \l__cdossier_statement_bodyfont_tl { serif }
\tl_set:Nn  \l__cdossier_statement_theme_tl { monochrome }
\tl_set:Nn  \l__cdossier_statement_accent_tl { navy }

\msg_new:nnnn { careerdossier-statement } { unknown-type }
  { Unknown~statement~type~'#1'. }
  {
    The~accepted~types~are:~general-interest,~research,~teaching,~
    teaching-philosophy,~diversity,~artist,~purpose.
  }

\msg_new:nnnn { careerdossier-statement } { unknown-option }
  { Unknown~class~option~'#1'~for~careerdossier-statement. }
  {
    Supported~options~are~'type'~(general-interest,~research,~teaching,~
    teaching-philosophy,~diversity,~artist,~purpose),~'paper'~(letter,~a4),~and~
    'bodyfont'~(serif,~sans),~'theme'~(monochrome,~accent),~and~
    'accent'~(navy,~teal,~magenta).~Language~and~named~font~combinations~
    cannot~be~set~here.
  }
\msg_new:nnnn { careerdossier-statement } { accent-without-theme }
  { The~'accent'~option~requires~'theme=accent'. }
  { Add~'theme=accent'~or~remove~the~'accent'~option. }

\keys_define:nn { cdossier / statement }
  {
    type .code:n =
      {
        \str_case:nnF {#1}
          {
            { general-interest }
              { \tl_set:Nn \l__cdossier_statement_type_tl { general-interest } }
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
    theme .choices:nn =
      { monochrome , accent }
      { \tl_set_eq:NN \l__cdossier_statement_theme_tl \l_keys_choice_tl } ,
    theme .value_required:n = true ,
    accent .choices:nn =
      { navy , teal , magenta }
      {
        \tl_set_eq:NN \l__cdossier_statement_accent_tl \l_keys_choice_tl
        \bool_set_true:N \l__cdossier_statement_accent_explicit_bool
      } ,
    accent .value_required:n = true ,
    unknown .code:n =
      { \msg_error:nnx { careerdossier-statement } { unknown-option }
          { \l_keys_key_str } } ,
  }
\ProcessKeysOptions { cdossier / statement }
\bool_if:NT \l__cdossier_statement_accent_explicit_bool
  {
    \str_if_eq:VnF \l__cdossier_statement_theme_tl { accent }
      { \msg_error:nn { careerdossier-statement } { accent-without-theme } }
  }

\str_if_eq:VnT \l__cdossier_statement_bodyfont_tl { sans }
  { \PassOptionsToPackage { bodyfont = sans } { careerdossier-typography } }
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      { theme = \l__cdossier_statement_theme_tl }
      { careerdossier-theme }
  }
\str_if_eq:VnT \l__cdossier_statement_theme_tl { accent }
  {
    \use:x
      {
        \exp_not:N \PassOptionsToPackage
          { accent = \l__cdossier_statement_accent_tl }
          { careerdossier-theme }
      }
  }

\use:x
  {
    \exp_not:N \LoadClass
      [ 11pt , \l__cdossier_statement_paper_tl ]
      { article }
  }

\RequirePackage { careerdossier-components }
\RequirePackage { geometry }
\RequirePackage { hyperref }

%% Academic-letter geometry and prose rhythm are the initial statement design.
\use:x
  {
    \exp_not:N \geometry
      {
        \l__cdossier_statement_paper_tl ,
        top = 0.9in , bottom = 0.9in , left = 1in , right = 1in
      }
  }
\setlength { \parindent }        { 0pt }
\setlength { \parskip }          { 1ex plus 0.4ex minus 0.1ex }
\setlength { \emergencystretch } { 2em }

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
        { general-interest }
          {
            \tl_set:Nn \l__cdossier_statement_default_title_tl
              { General~Interest~Statement }
            \tl_set:Nn \l__cdossier_statement_default_running_title_tl
              { General~Interest~Statement }
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

%% ---------------------------------------------------------------------------
%% Continuation-page furniture: no running header on page one; a centered name
%% and short title from page two; and a centered Page N of M folio throughout.
%% The kernel's page-style tagging path treats this repeated furniture as an
%% artifact, matching the academic letter.
%% ---------------------------------------------------------------------------
\makeatletter
\def\ps@cdossierstatement{%
  \let\@mkboth\@gobbletwo
  \def\@oddhead{%
    \hfil
    {\sffamily\small
      \CDossierFieldValue{name}\enspace--\enspace
      \tl_use:N\l__cdossier_statement_running_title_tl}%
    \hfil
  }%
  \let\@evenhead\@oddhead
  \def\@oddfoot{%
    \hfil{\sffamily\small Page~\thepage\space of~\@abspage@last}\hfil
  }%
  \let\@evenfoot\@oddfoot
}
\def\ps@cdossierstatementfirst{%
  \let\@mkboth\@gobbletwo
  \def\@oddhead{}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{%
    \hfil{\sffamily\small Page~\thepage\space of~\@abspage@last}\hfil
  }%
  \let\@evenfoot\@oddfoot
}
\makeatother
\pagestyle { cdossierstatement }
\AtBeginDocument { \thispagestyle { cdossierstatementfirst } }

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
    \begin { center }
      { \CDossierNameStyle \Huge \CDossierPrintField { name } \par }
      \smallskip
      \__cdossier_typography_heading:n
        { \CDossierSectionStyle \Large \tl_use:N \l__cdossier_statement_title_tl }
      \tl_if_blank:VF \l__cdossier_statement_subtitle_tl
        {
          \smallskip
          { \CDossierHeadlineStyle \large
            \tl_use:N \l__cdossier_statement_subtitle_tl \par }
        }
      \CDossierIfFieldTF { affiliation }
        {
          \smallskip
          { \CDossierBodyStyle \CDossierPrintField { affiliation } \par }
        }
        { }
      \bool_lazy_or:nnT
        { ! \tl_if_blank_p:V \l__cdossier_statement_context_tl }
        { ! \tl_if_blank_p:V \l__cdossier_statement_application_id_tl }
        {
          \smallskip
          { \CDossierMutedStyle \small \__cdossier_statement_contextline: \par }
        }
      \smallskip
      { \CDossierBodyStyle \small
        \__cdossier_components_contactline:N
          \l__cdossier_statement_contacts_clist
        \par }
    \end { center }
    \par
    \addvspace { 1.5ex plus 0.5ex minus 0.2ex }
  }

\endinput
