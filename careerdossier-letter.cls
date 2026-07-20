%% careerdossier-letter.cls
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
%% careerdossier-letter owns the English industry and academic cover-letter
%% families: US Letter geometry, the letter-specific metadata keys,
%% and prose structure: US Letter margins, the letter-specific metadata keys,
%% the collapsing recipient block, and the letterhead and closing commands.
%% Shared identity and contact logic (the centered sender block, contact line,
%% link wrappers) and the required-`name' validation live in
%% careerdossier-components and careerdossier-base; this class only arranges
%% that material and adds the letter body around it.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass {careerdossier-letter} {2026-07-19} {0.2.1}
  {CareerDossierTeX English cover-letter class}

%% ---------------------------------------------------------------------------
%% Class options. `family` is additive in v0.2.0; the existing industry family
%% remains the default. Paper, language, and theme are fixed. Any option is rejected
%% with an actionable message rather than silently ignored.
%% ---------------------------------------------------------------------------
\RequirePackage { l3keys2e }
\tl_new:N \l__cdossier_letter_family_tl
\tl_set:Nn \l__cdossier_letter_family_tl { industry }

\msg_new:nnnn { careerdossier-letter } { unknown-option }
  { Unknown~class~option~'#1'~for~careerdossier-letter. }
  {
    The~supported~option~is~'family'~(industry,~academic).~Paper,~language,~
    and~theme~are~fixed~and~cannot~be~set~here.
  }

\keys_define:nn { cdossier / letter }
  {
    family .choices:nn =
      { industry , academic }
      { \tl_set_eq:NN \l__cdossier_letter_family_tl \l_keys_choice_tl } ,
    family .value_required:n = true ,
    unknown .code:n =
      { \msg_error:nnx { careerdossier-letter } { unknown-option }
          { \l_keys_key_str } } ,
  }
\ProcessKeysOptions { cdossier / letter }

%% A prose letter reads best at a slightly larger body size than the résumé.
\LoadClass [ 11pt , letterpaper ] { article }

%% ---------------------------------------------------------------------------
%% Shared modules. careerdossier-components pulls in base (profile metadata and
%% required-field validation), typography (the XeLaTeX guard and fonts), and
%% theme; geometry and hyperref complete the page and link machinery. hyperref
%% loads last so the theme's print-safe link hook applies regardless of order.
%% ---------------------------------------------------------------------------
\RequirePackage { careerdossier-components }
\RequirePackage { geometry }
\RequirePackage { hyperref }

%% Declare the document type so the shared PDF-metadata code can title this
%% document distinctly from a résumé built off the same profile. The title
%% itself is assembled in careerdossier-components, which owns identity.
\str_if_eq:VnTF \l__cdossier_letter_family_tl { academic }
  { \__cdossier_components_doctype:n { Academic~Cover~Letter } }
  { \__cdossier_components_doctype:n { Cover~Letter } }

%% US Letter with conventional one-inch business-letter margins.
\str_if_eq:VnTF \l__cdossier_letter_family_tl { academic }
  { \geometry { letterpaper , top = 0.9in , bottom = 0.9in , left = 1in , right = 1in } }
  { \geometry { letterpaper , margin = 1in } }

%% Industry letters retain the v0.1 empty page style. Academic letters use a
%% print-oriented footer: identity at left and the current/total page count at
%% right. The LaTeX kernel persists the last absolute page in the auxiliary
%% file, avoiding an additional total-page package and resolving on a rerun.
\makeatletter
\def\ps@cdossieracademicletter{%
  \let\@mkboth\@gobbletwo
  \def\@oddhead{}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\footnotesize\sffamily\CDossierFieldValue{name}\hfil Page~\thepage\space of~\@abspage@last}%
  \let\@evenfoot\@oddfoot
}
\makeatother
\str_if_eq:VnTF \l__cdossier_letter_family_tl { academic }
  {
    \pagestyle { cdossieracademicletter }
  }
  { \pagestyle { empty } }

%% Block format: no paragraph indentation, paragraphs separated by vertical
%% space. \emergencystretch keeps justified prose from producing overfull boxes
%% when a paragraph has few break points.
\setlength { \parindent }       { 0pt }
\setlength { \parskip }         { 1ex plus 0.4ex minus 0.1ex }
\setlength { \emergencystretch }{ 2em }

%% ---------------------------------------------------------------------------
%% Vertical rhythm for the letterhead and closing. Collected here so the
%% letter's structural spacing stays easy to compare and adjust.
%% ---------------------------------------------------------------------------
\skip_new:N \l__cdossier_letter_afterhead_skip
\skip_new:N \l__cdossier_letter_block_skip
\skip_new:N \l__cdossier_letter_aftersalutation_skip
\skip_new:N \l__cdossier_letter_sigspace_skip
\skip_set:Nn \l__cdossier_letter_afterhead_skip      { 2ex   plus 0.6ex minus 0.2ex }
\skip_set:Nn \l__cdossier_letter_block_skip          { 1.6ex plus 0.4ex minus 0.2ex }
\skip_set:Nn \l__cdossier_letter_aftersalutation_skip { 1ex  plus 0.3ex }
\skip_set:Nn \l__cdossier_letter_sigspace_skip       { 2.5em }

%% ---------------------------------------------------------------------------
%% Letter metadata.
%%
%% These keys describe a single letter, so they are stored in class-scoped
%% token lists rather than the shared profile property list. Values are stored
%% without expansion so a recipient address may contain \\ and the date may
%% contain \today; a blank value (empty or spaces only) is treated as absent by
%% the rendering logic below. date, salutation, and closing carry English
%% defaults; the recipient fields and subject default to absent.
%% ---------------------------------------------------------------------------
\tl_new:N   \l__cdossier_letter_date_tl
\tl_set:Nn  \l__cdossier_letter_date_tl { \today }
\tl_new:N   \l__cdossier_letter_rcptname_tl
\tl_new:N   \l__cdossier_letter_rcpttitle_tl
\tl_new:N   \l__cdossier_letter_rcptorg_tl
\tl_new:N   \l__cdossier_letter_rcptaddr_tl
\tl_new:N   \l__cdossier_letter_subject_tl
\tl_new:N   \l__cdossier_letter_salutation_tl
\tl_set:Nn  \l__cdossier_letter_salutation_tl { Dear~Hiring~Manager, }
\tl_new:N   \l__cdossier_letter_closing_tl
\tl_set:Nn  \l__cdossier_letter_closing_tl { Sincerely, }

\bool_new:N \l__cdossier_letter_printed_bool

\msg_new:nnnn { careerdossier-letter } { unknown-meta-key }
  { Unknown~\c_backslash_str CDossierLetterSetup~key~'#1'. }
  {
    The~supported~keys~are:~date,~recipient-name,~recipient-title,~
    recipient-organization,~recipient-address,~subject,~salutation,~closing.
  }

\keys_define:nn { cdossier / letterdata }
  {
    date                   .tl_set:N = \l__cdossier_letter_date_tl ,
    date                   .value_required:n = true ,
    recipient-name         .tl_set:N = \l__cdossier_letter_rcptname_tl ,
    recipient-name         .value_required:n = true ,
    recipient-title        .tl_set:N = \l__cdossier_letter_rcpttitle_tl ,
    recipient-title        .value_required:n = true ,
    recipient-organization .tl_set:N = \l__cdossier_letter_rcptorg_tl ,
    recipient-organization .value_required:n = true ,
    recipient-address      .tl_set:N = \l__cdossier_letter_rcptaddr_tl ,
    recipient-address      .value_required:n = true ,
    subject                .tl_set:N = \l__cdossier_letter_subject_tl ,
    subject                .value_required:n = true ,
    salutation             .tl_set:N = \l__cdossier_letter_salutation_tl ,
    salutation             .value_required:n = true ,
    closing                .tl_set:N = \l__cdossier_letter_closing_tl ,
    closing                .value_required:n = true ,
    unknown                .code:n =
      { \msg_error:nnx { careerdossier-letter } { unknown-meta-key }
          { \l_keys_key_str } } ,
  }

%% \CDossierLetterSetup { key = value, ... }
\NewDocumentCommand \CDossierLetterSetup { m }
  { \keys_set:nn { cdossier / letterdata } {#1} }

%% ---------------------------------------------------------------------------
%% Recipient block.
%%
%% The recipient name, title, organization, and address are printed in a fixed
%% logical order, each on its own line, with a line break inserted only between
%% present lines. A missing field therefore leaves no blank line, and when every
%% field is absent the caller omits the block entirely (see the letterhead).
%% ---------------------------------------------------------------------------
\cs_new_protected:Npn \__cdossier_letter_rcptline:N #1
  {
    \tl_if_blank:VF #1
      {
        \bool_if:NT \l__cdossier_letter_printed_bool { \\ }
        \tl_use:N #1
        \bool_set_true:N \l__cdossier_letter_printed_bool
      }
  }
\cs_new_protected:Npn \__cdossier_letter_recipient:
  {
    \bool_set_false:N \l__cdossier_letter_printed_bool
    \__cdossier_letter_rcptline:N \l__cdossier_letter_rcptname_tl
    \__cdossier_letter_rcptline:N \l__cdossier_letter_rcpttitle_tl
    \__cdossier_letter_rcptline:N \l__cdossier_letter_rcptorg_tl
    \__cdossier_letter_rcptline:N \l__cdossier_letter_rcptaddr_tl
  }

%% True when at least one recipient field is present.
\prg_new_protected_conditional:Npnn \__cdossier_letter_has_recipient: { T }
  {
    \bool_lazy_any:nTF
      {
        { ! \tl_if_blank_p:V \l__cdossier_letter_rcptname_tl  }
        { ! \tl_if_blank_p:V \l__cdossier_letter_rcpttitle_tl }
        { ! \tl_if_blank_p:V \l__cdossier_letter_rcptorg_tl   }
        { ! \tl_if_blank_p:V \l__cdossier_letter_rcptaddr_tl  }
      }
      { \prg_return_true: }
      { \prg_return_false: }
  }

%% ---------------------------------------------------------------------------
%% \MakeCDossierLetterhead -- the letter opening: centered sender identity,
%% date, recipient block, optional subject, and salutation. Each optional block
%% and the vertical space that follows it are emitted together, so an absent
%% recipient or subject leaves no gap. \MakeCDossierHeader validates `name'.
%% ---------------------------------------------------------------------------
\NewDocumentCommand \MakeCDossierLetterhead { }
  {
    \MakeCDossierHeader
    \par
    \addvspace { \l__cdossier_letter_afterhead_skip }
    \noindent { \CDossierBodyStyle \tl_use:N \l__cdossier_letter_date_tl }
    \par
    \addvspace { \l__cdossier_letter_block_skip }
    \__cdossier_letter_has_recipient:T
      {
        \noindent { \CDossierBodyStyle \__cdossier_letter_recipient: }
        \par
        \addvspace { \l__cdossier_letter_block_skip }
      }
    \tl_if_blank:VF \l__cdossier_letter_subject_tl
      {
        \noindent { \CDossierEntryTitleStyle \tl_use:N \l__cdossier_letter_subject_tl }
        \par
        \addvspace { \l__cdossier_letter_block_skip }
      }
    \noindent { \CDossierBodyStyle \tl_use:N \l__cdossier_letter_salutation_tl }
    \par
    \addvspace { \l__cdossier_letter_aftersalutation_skip }
  }

%% ---------------------------------------------------------------------------
%% \MakeCDossierClosing -- the letter close: the configured closing, signature
%% space, and the profile name. Validates `name' because it prints it.
%% ---------------------------------------------------------------------------
\NewDocumentCommand \MakeCDossierClosing { }
  {
    \__cdossier_base_require_name:N \MakeCDossierClosing
    \par
    \addvspace { \l__cdossier_letter_block_skip }
    \noindent { \CDossierBodyStyle \tl_use:N \l__cdossier_letter_closing_tl }
    \par
    \vspace { \l__cdossier_letter_sigspace_skip }
    \noindent { \CDossierBodyStyle \CDossierPrintField { name } }
    \par
  }

\endinput
