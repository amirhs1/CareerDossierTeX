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
%% careerdossier-resume owns resume-specific page behaviour for the English
%% industry dossier: Letter/A4 geometry, class options, and the section,
%% entry, and list structures.
%% Reusable identity and contact logic lives in careerdossier-components; this
%% class only arranges it on the page.
%%
%% Responsibilities: load an appropriate base class; select Letter or A4 and
%% delegate geometry to careerdossier-tokens; process the fontsize, margin,
%% paper, bodyfont, medium, muted, and entrymeta options, forwarding medium,
%% muted, and entrymeta to careerdossier-components, which owns the furniture,
%% de-emphasis, and entry-metadata decisions; register the `Resume' running
%% label and enable shared page furniture; render sections, entries, and lists
%% from the shared type, rhythm, rule, and list tokens; expose the shared second
%% heading level as \CDossierSubsection (#337), so a resume, CV, and statement
%% are all written with two heading levels; and preserve logical source and
%% extraction order.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass {careerdossier-resume} {2026-11-06} {0.10.0}
  {CareerDossierTeX English industry resume class}

%% ---------------------------------------------------------------------------
%% Class options (l3keys). Unsupported keys and choice values are rejected with
%% an actionable message rather than silently ignored.
%% ---------------------------------------------------------------------------
\RequirePackage { l3keys2e }

%% careerdossier-base declares the six options every class shares
%% and the entrymeta option the two record classes share, each with its
%% storage, its accepted values, and its class-named message; see `Shared class
%% options' there (#266). The class adds its unknown-option message and its
%% unknown-key handler to the same key path, and sets the two defaults that
%% differ by class.
%% careerdossier-components would load base later anyway; it is loaded here
%% because the declarations must exist before \ProcessKeysOptions.
\RequirePackage { careerdossier-base }
\__cdossier_base_declare_shared_options:nn
  { careerdossier-resume } { cdossier / resume }
\__cdossier_base_declare_record_options:nn
  { careerdossier-resume } { cdossier / resume }
\tl_set:Nn \l__cdossier_resume_fontsize_tl { 11pt }
\tl_set:Nn \l__cdossier_resume_margin_tl { narrow }

\msg_new:nnnn { careerdossier-resume } { unknown-option }
  {
    Unknown~class~option~'#1'~for~careerdossier-resume.~
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

\keys_define:nn { cdossier / resume }
  {
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
%% The class validates the public values;
%% careerdossier-components owns the page furniture, the de-emphasis role, and
%% the entry-heading primitive, and therefore owns all three resulting
%% decisions (#184, #271, #230).
\use:x
  {
    \exp_not:N \PassOptionsToPackage
      {
        medium    = \l__cdossier_resume_medium_tl ,
        muted     = \l__cdossier_resume_muted_tl ,
        entrymeta = \l__cdossier_resume_entrymeta_tl
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
%% itself is assembled in careerdossier-metadata from the profile name.
\__cdossier_metadata_doctype:n { Resume }

\exp_args:NV \__cdossier_tokens_apply_geometry:n \l__cdossier_resume_paper_tl

\__cdossier_components_runninglabel:n { Resume }
\__cdossier_components_apply_page_furniture:

\setlength { \parindent } { 0pt }
\setlength { \parskip }   { \CDossierRecordParSkip }
%% The shared line-breaking flexibility every family applies (#272). The
%% resume set none until then, though it is fully justified and its bullet text
%% carries the toolkit's longest unbreakable strings. The policy and its
%% reasoning live with the token in careerdossier-tokens.
\setlength { \emergencystretch } { \CDossierEmergencyStretch }
\CDossierApplyPageBreakPenalties

%% The shared header stack ends at a boundary against whatever the
%% class puts next -- here a ruled \CDossierSection -- so the class names the
%% token that owns it rather than sharing one gap with the letter and the
%% statement, whose next block is not a ruled section at all (#223).
\__cdossier_components_headerbelow:N \CDossierRecordHeaderBelowSkip

%% ---------------------------------------------------------------------------
%% \CDossierSection {title} -- a resume section heading followed by a full-width
%% rule. Uses the semantic section style with class-controlled size, spacing,
%% and rule colour. The keep-together penalty (#145) after the heading
%% and rule keeps the title with the content that follows it, so a section
%% heading is never stranded alone at the foot of a page.
%%
%% Depth 2, not 1 -- the document identity (the name, in
%% \MakeCDossierHeader) is the document's one depth-1 heading, so every
%% resume/CV section heading sits one level under it (#267).
%%
%% The heading also opens the division that encloses it and the
%% entries it introduces, and passes its plain title so the heading element
%% records it (#268). The division opens *after* the `\addvspace' so that the skip is
%% still contributed against the previous section's vertical list, and *before*
%% the heading so the heading is the division's first child. The rule that
%% follows is drawn inside the division but stays a layout artifact, so it adds
%% nothing to the structure tree.
%%
%% The optional argument takes `entrymeta = column|inline' for this section
%% alone (#569): every entry in a section shares one layout, and the next
%% \CDossierSection reverts to the document value whether or not it carries
%% the key. careerdossier-components owns the option, so the key hands its
%% value to that package's setter, which validates it against the declaration
%% the class option reaches, and the reset that precedes it is that package's
%% too. Any other key is rejected here, since this class decides what its
%% section command accepts.
%% ---------------------------------------------------------------------------
\msg_new:nnnn { careerdossier-resume } { unknown-section-key }
  { Unknown~CDossierSection~key~'#1'. }
  { The~supported~key~is:~entrymeta. }

\keys_define:nn { cdossier / section }
  {
    entrymeta .code:n = { \__cdossier_components_set_entrymeta:n {#1} } ,
    entrymeta .value_required:n = true ,
    unknown   .code:n =
      { \msg_error:nnx { careerdossier-resume } { unknown-section-key }
          { \l_keys_key_str } } ,
  }

\NewDocumentCommand \CDossierSection { O{} m }
  {
    \par
    \__cdossier_components_entrymeta_reset:
    \keys_set:nn { cdossier / section } {#1}
    %% The section keep, applied before the heading contributes
    %% anything, so the bound is on what the heading commits rather than a
    %% prohibition on breaking after it (#333).
    \__cdossier_components_section_need:
    \addvspace { \CDossierRecordSectionAboveSkip }
    \__cdossier_typography_division_begin:n { 2 }
    \__cdossier_typography_heading:nnn { 2 } { #2 }
      { { \CDossierSectionStyle \CDossierSizeSection #2 \par } }
    \__cdossier_components_section_rule:
  }

%% ---------------------------------------------------------------------------
%% \CDossierSubsection {title} -- the level between a section and an entry
%% (#337), for a section with natural groupings that are not themselves
%% sections: Experience split into industry and academic, say. Promoting such a
%% group to a full ruled section is what this replaces, and it flattened the
%% hierarchy it was meant to show.
%%
%% The name matches `careerdossier-statement.cls' and `careerdossier-cv.cls', so
%% one profile's documents are written the same way. The renderer is shared with
%% the CV in careerdossier-components, which is where the depth, the rule-less
%% styling, and the section-opens-with-a-subsection guard are all explained.
%% ---------------------------------------------------------------------------
\NewDocumentCommand \CDossierSubsection { m }
  { \__cdossier_components_subsection:n {#1} }

%% ---------------------------------------------------------------------------
%% CDossierEntry -- one resume entry (job, degree, project, ...). Named keys are
%% self-documenting and extensible; only title is required. The heading itself
%% is rendered by the shared components primitive so the optional-field and
%% separator rules stay in one place; this environment supplies only resume
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

\NewDocumentEnvironment { CDossierEntry } { O{} +b }
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
    %% Keep the entry heading with the first line of its body, so
    %% the heading cannot be stranded alone at the foot of a page (#145).
    %%
    %% Guarded on a non-empty body (#332). Emitted unconditionally, this
    %% penalty outlives the heading it was meant to bind: with no body there is
    %% no first line to bind to, so it is left sitting immediately before the
    %% gap glue. A break at glue is legal only when a non-discardable item
    %% precedes it, and a penalty is discardable, so the boundary stops being a
    %% breakpoint at all -- and because the next entry opens with `\addvspace',
    %% which collapses into the skip already present rather than appending after
    %% a box, nothing ever intervenes to restore it. Chained across the body-less
    %% entries that make up a normal Education or Certificates section, the
    %% effect accumulates into one unbreakable block.
    %%
    %% The body is taken as a `+b' argument purely so this test can be made. The
    %% issue proposed contributing the penalty at the start of the body instead,
    %% but no start-of-body hook can do it: `\everypar' fires in horizontal mode
    %% while the breakpoint being guarded is in the vertical list, and removing
    %% the penalty afterwards is not reliable either, because the page builder
    %% may already have migrated the material off the contribution list where
    %% `\unpenalty' can no longer reach it.
    %%
    %% The cost is that the body is read as an argument, so catcode-sensitive
    %% content -- `\verb', `listings' -- cannot appear directly in an entry body.
    %% Neither the classes nor the examples use any, and a v0.8.0 entry body is
    %% prose or a CDossierItemize.
    \tl_if_blank:nF {#2}
      { \penalty \CDossierHeadingKeepPenalty }
    %% `\addvspace', not `\vspace' (#204). As a `\vspace' this was extra
    %% space that added to whatever the entry body opened with, so a bullet list
    %% sat further from the entry heading that owns it than from the next entry.
    %% As an `\addvspace' the token is the *floor* for the heading -> body
    %% boundary, which a list overrides with its own edge.
    \addvspace { \CDossierRecordEntryGapSkip }
    #2
  }
  {
    %% The entry's closing boundary is owned by whatever opens next
    %% -- \CDossierRecordEntryAboveSkip or \CDossierRecordSectionAboveSkip (#204). The
    %% retired \CDossierRecordEntryBelowSkip lost both of those maxima.
    \par
  }

%% ---------------------------------------------------------------------------
%% CDossierItemize -- a resume-appropriate flush-left bullet list using shared
%% list and rhythm tokens. Prefer this over redefining itemize globally.
%%
%% `beginpenalty' keeps the first bullet with whatever precedes the
%% list -- here the entry heading (#145). The inter-item boundaries are governed by
%% the shared position-aware policy in careerdossier-components, which forbids
%% the boundaries that would strand a single bullet and merely discourages the
%% rest, so a list longer than a page still breaks.
%%
%% `partopsep' is zeroed so the list-edge tokens alone own the
%% distance between the list and the content around it, as documented (#176). LaTeX
%% adds `\partopsep' on top of `topsep' whenever a list opens a new paragraph,
%% and the `article' default is 3 pt plus stretch: a quantity no token owns and
%% that does not rescale with `fontsize'. Left in place it would make the list
%% edge both wider than the token says and proportionally wider at 10pt than
%% at 12pt. The token's own ratio absorbs the 3 pt instead.
%%
%% `topsep' is LaTeX's only list-edge key and applies at both ends,
%% so `\CDossierRecordListEdgeAboveSkip' passes through it and the shared
%% component call below substitutes `\CDossierRecordListEdgeBelowSkip' for the
%% closing edge (#191).
%%
%% That substitution works on the untagged path only, because a
%% tagged list is built by LaTeX Lab's block templates and never reads the
%% register it assigns (#193). The tagged branch names the same token through
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
