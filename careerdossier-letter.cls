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
%% families: Letter/A4 geometry, class options, letter-specific metadata keys,
%% and prose structure driven by the shared design tokens,
%% the collapsing recipient block, and the letterhead and closing commands.
%% Shared identity and contact logic (the centered sender block, contact line,
%% link wrappers) and the required-`name' validation live in
%% careerdossier-components and careerdossier-base; this class only arranges
%% that material and adds the letter body around it.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass {careerdossier-letter} {2026-07-30} {0.6.0}
  {CareerDossierTeX English cover-letter class}

%% ---------------------------------------------------------------------------
%% Class options. The industry family, 12pt body, normal margin, Letter paper,
%% and serif body remain the defaults. Any unsupported option is rejected with
%% an actionable message.
%% ---------------------------------------------------------------------------
\RequirePackage { l3keys2e }
\tl_new:N \l__cdossier_letter_family_tl
\tl_set:Nn \l__cdossier_letter_family_tl { industry }
\tl_new:N \l__cdossier_letter_paper_tl
\tl_set:Nn \l__cdossier_letter_paper_tl { letterpaper }
\tl_new:N \l__cdossier_letter_fontsize_tl
\tl_set:Nn \l__cdossier_letter_fontsize_tl { 12pt }
\tl_new:N \l__cdossier_letter_margin_tl
\tl_set:Nn \l__cdossier_letter_margin_tl { normal }
\tl_new:N \l__cdossier_letter_bodyfont_tl
\tl_set:Nn \l__cdossier_letter_bodyfont_tl { serif }
\tl_new:N \l__cdossier_letter_medium_tl
\tl_set:Nn \l__cdossier_letter_medium_tl { print }

\msg_new:nnnn { careerdossier-letter } { unknown-option }
  { Unknown~class~option~'#1'~for~careerdossier-letter. }
  {
    Supported~options~are~'family'~(industry,~academic),~
    'fontsize'~(10pt,~11pt,~12pt),~'margin'~(normal,~narrow),~
    'paper'~(letter,~a4),~'bodyfont'~(serif,~sans),~and~
    'medium'~(print,~screen).~Language~and~theme~cannot~be~set~here.
  }

%% l3keys' own choice error reports that the value is not one of a fixed set
%% without saying what that set is, so every choice-valued option below names
%% its own accepted values. Each message is reached through the matching
%% `<key> / unknown' sub-key, which l3keys runs in place of its stock error.
\msg_new:nnnn { careerdossier-letter } { unknown-family }
  { Unknown~'family'~value~'#1'~for~careerdossier-letter. }
  {
    The~accepted~values~are~'industry'~(the~default~cover~letter)~and~
    'academic'~(the~academic~cover-letter~family).
  }

\msg_new:nnnn { careerdossier-letter } { unknown-fontsize }
  { Unknown~'fontsize'~value~'#1'~for~careerdossier-letter. }
  { The~accepted~values~are~'10pt',~'11pt',~and~'12pt'. }

\msg_new:nnnn { careerdossier-letter } { unknown-margin }
  { Unknown~'margin'~value~'#1'~for~careerdossier-letter. }
  {
    The~accepted~values~are~'normal'~(one-inch~margins)~and~
    'narrow'~(half-inch~margins).
  }

\msg_new:nnnn { careerdossier-letter } { unknown-paper }
  { Unknown~'paper'~value~'#1'~for~careerdossier-letter. }
  { The~accepted~values~are~'letter'~(US~Letter)~and~'a4'~(ISO~A4). }

\msg_new:nnnn { careerdossier-letter } { unknown-bodyfont }
  { Unknown~'bodyfont'~value~'#1'~for~careerdossier-letter. }
  {
    The~accepted~values~are~'serif'~(TeX~Gyre~Termes~body)~and~
    'sans'~(TeX~Gyre~Heros~body).
  }

\msg_new:nnnn { careerdossier-letter } { unknown-medium }
  { Unknown~'medium'~value~'#1'~for~careerdossier-letter. }
  {
    The~accepted~values~are~'print'~(running~header~and~'Page~N~of~M'~folio)~
    and~'screen'~(neither).
  }

\keys_define:nn { cdossier / letter }
  {
    family .choices:nn =
      { industry , academic }
      { \tl_set_eq:NN \l__cdossier_letter_family_tl \l_keys_choice_tl } ,
    family / unknown .code:n =
      { \msg_error:nnn { careerdossier-letter } { unknown-family } {#1} } ,
    family .value_required:n = true ,
    fontsize .choices:nn =
      { 10pt , 11pt , 12pt }
      { \tl_set_eq:NN \l__cdossier_letter_fontsize_tl \l_keys_choice_tl } ,
    fontsize / unknown .code:n =
      { \msg_error:nnn { careerdossier-letter } { unknown-fontsize } {#1} } ,
    fontsize .value_required:n = true ,
    margin .choices:nn =
      { normal , narrow }
      { \tl_set_eq:NN \l__cdossier_letter_margin_tl \l_keys_choice_tl } ,
    margin / unknown .code:n =
      { \msg_error:nnn { careerdossier-letter } { unknown-margin } {#1} } ,
    margin .value_required:n = true ,
    paper .choices:nn =
      { letter , a4 }
      {
        \str_case:Vn \l_keys_choice_tl
          {
            { letter } { \tl_set:Nn \l__cdossier_letter_paper_tl { letterpaper } }
            { a4 }     { \tl_set:Nn \l__cdossier_letter_paper_tl { a4paper } }
          }
      } ,
    paper / unknown .code:n =
      { \msg_error:nnn { careerdossier-letter } { unknown-paper } {#1} } ,
    paper .value_required:n = true ,
    bodyfont .choices:nn =
      { serif , sans }
      { \tl_set_eq:NN \l__cdossier_letter_bodyfont_tl \l_keys_choice_tl } ,
    bodyfont / unknown .code:n =
      { \msg_error:nnn { careerdossier-letter } { unknown-bodyfont } {#1} } ,
    bodyfont .value_required:n = true ,
    medium .choices:nn =
      { print , screen }
      { \tl_set_eq:NN \l__cdossier_letter_medium_tl \l_keys_choice_tl } ,
    medium / unknown .code:n =
      { \msg_error:nnn { careerdossier-letter } { unknown-medium } {#1} } ,
    medium .value_required:n = true ,
    unknown .code:n =
      { \msg_error:nnx { careerdossier-letter } { unknown-option }
          { \l_keys_key_str } } ,
  }
\ProcessKeysOptions { cdossier / letter }

\str_if_eq:VnT \l__cdossier_letter_bodyfont_tl { sans }
  { \PassOptionsToPackage { bodyfont = sans } { careerdossier-typography } }
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      {
        fontsize = \l__cdossier_letter_fontsize_tl ,
        margin = \l__cdossier_letter_margin_tl
      }
      { careerdossier-tokens }
  }
%% Issue #184: the class validates the public value; careerdossier-components
%% owns the page furniture and therefore the resulting decision.
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      { medium = \l__cdossier_letter_medium_tl }
      { careerdossier-components }
  }

%% A prose letter reads best at a slightly larger default body size than the
%% résumé. Explicit fontsize options remain available for all letter families.
\use:x
  {
    \exp_not:N \LoadClass
      [ \l__cdossier_letter_fontsize_tl , \l__cdossier_letter_paper_tl ]
      { article }
  }

%% ---------------------------------------------------------------------------
%% Shared modules. careerdossier-components pulls in base (profile metadata and
%% required-field validation), typography (the LuaLaTeX guard and fonts), and
%% theme; geometry and hyperref complete the page and link machinery. hyperref
%% loads last so the theme's print-safe link hook applies regardless of order.
%% ---------------------------------------------------------------------------
\RequirePackage { careerdossier-components }
\RequirePackage { careerdossier-tokens }
\RequirePackage { hyperref }
\__cdossier_tokens_apply_body_size:

%% Declare the document type so the shared PDF-metadata code can title this
%% document distinctly from a résumé built off the same profile. The title
%% itself is assembled in careerdossier-components, which owns identity.
\str_if_eq:VnTF \l__cdossier_letter_family_tl { academic }
  { \__cdossier_components_doctype:n { Academic~Cover~Letter } }
  { \__cdossier_components_doctype:n { Cover~Letter } }

\exp_args:NV \__cdossier_tokens_apply_geometry:n \l__cdossier_letter_paper_tl

\__cdossier_components_runninglabel:n { Cover~Letter }
\__cdossier_components_apply_page_furniture:

%% Block format: no paragraph indentation, paragraphs separated by the shared
%% prose token. \emergencystretch keeps justified prose from producing overfull
%% boxes when a paragraph has few break points.
\setlength { \parindent }       { 0pt }
\setlength { \parskip }         { \CDossierLetterParSkip }
\setlength { \emergencystretch }{ 2em }

%% Typographic page-break penalties (issue #171): see careerdossier-tokens for
%% the shared values and the reasoning for using one strength across families.
\CDossierApplyPageBreakPenalties

%% Issue #223: nothing that follows a letter header is a section -- the next
%% block is the date line, at \CDossierLetterBlockSkip. The letter therefore
%% names its own gap below the header stack instead of carrying a floor set by
%% a section boundary the class does not have.
\__cdossier_components_headerbelow:N \CDossierLetterHeaderBelowSkip

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
%%
%% Issue #204: the break carries \CDossierLetterRecipientLineGapSkip. Until then
%% it was a bare `\\', which is plain `\baselineskip' -- the only vertical
%% distance in the letter that the token system did not express. The token
%% defaults to 0.00, which is that same plain `\baselineskip'.
%% ---------------------------------------------------------------------------
\cs_new_protected:Npn \__cdossier_letter_rcptline:N #1
  {
    \tl_if_blank:VF #1
      {
        \bool_if:NT \l__cdossier_letter_printed_bool
          { \\ [ \CDossierLetterRecipientLineGapSkip ] }
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
%%
%% Issue #204: the header -> date boundary is owned by the header stack's own
%% below-token, which \MakeCDossierHeader has already contributed -- for this
%% class \CDossierLetterHeaderBelowSkip (issue #223). The retired
%% \CDossierLetterheadBelowSkip claimed the same boundary immediately
%% afterwards with a smaller value (0.75 against 0.8125), and `\addvspace'
%% takes the maximum, so it never reached the page.
%% ---------------------------------------------------------------------------
\NewDocumentCommand \MakeCDossierLetterhead { }
  {
    \MakeCDossierHeader
    \par
    \noindent { \CDossierBodyStyle \tl_use:N \l__cdossier_letter_date_tl }
    \par
    \addvspace { \CDossierLetterBlockSkip }
    \__cdossier_letter_has_recipient:T
      {
        \noindent { \CDossierBodyStyle \__cdossier_letter_recipient: }
        \par
        \addvspace { \CDossierLetterBlockSkip }
      }
    \tl_if_blank:VF \l__cdossier_letter_subject_tl
      {
        \noindent { \CDossierEntryTitleStyle \tl_use:N \l__cdossier_letter_subject_tl }
        \par
        \addvspace { \CDossierLetterBlockSkip }
      }
    \noindent { \CDossierBodyStyle \tl_use:N \l__cdossier_letter_salutation_tl }
    \par
    \addvspace { \CDossierLetterBodyAboveSkip }
  }

%% ---------------------------------------------------------------------------
%% \MakeCDossierClosing -- the letter close: the configured closing, signature
%% space, and the profile name. Validates `name' because it prints it.
%%
%% Issue #204: the body's closing edge is \CDossierLetterBodyBelowSkip, the pair
%% of \CDossierLetterBodyAboveSkip that opens it. It previously borrowed
%% \CDossierLetterBlockSkip, which names the boundary *between letterhead
%% blocks*; the two are separate boundaries and the default value is unchanged.
%% ---------------------------------------------------------------------------
\NewDocumentCommand \MakeCDossierClosing { }
  {
    \__cdossier_base_require_name:N \MakeCDossierClosing
    \par
    \addvspace { \CDossierLetterBodyBelowSkip }
    \noindent { \CDossierBodyStyle \tl_use:N \l__cdossier_letter_closing_tl }
    \par
    \vspace { \CDossierLetterSignatureGapSkip }
    \noindent { \CDossierBodyStyle \CDossierPrintField { name } }
    \par
  }

\endinput
