% Shared regression: the section-rule tokens own the rule-to-content gap.
%
% Issue #168. `\CDossierSectionBelowSkip' must own the complete distance from
% the decorative section rule to the first line of section content, for every
% kind of content that can follow a section heading.
%
% LaTeX vertical spacing composes by collapsing, not by adding: adjacent
% `\addvspace' skips yield their maximum. The gap after a section rule is
% therefore the larger of `\CDossierSectionBelowSkip' and whatever leading
% space the following block contributes -- never their sum. This fixture
% asserts that contract for the three content paths a section can open with:
%
%   entry-led  -- CDossierEntry, contributing \CDossierEntryAboveSkip
%   list-led   -- CDossierItemize, contributing \CDossierListEdgeSkipBefore
%                 as topsep
%   prose-led  -- an ordinary paragraph, contributing nothing
%
% Before the fix the gap was the *sum* in the entry-led and list-led cases,
% because `\@vspace' appends `\vskip\z@skip' and so hides the preceding skip
% from the following `\addvspace'.
\CDossierSetup{name = {Ada Lovelace}}

\newbox\CDossierGapEntryBox
\newbox\CDossierGapListBox
\newbox\CDossierGapProseBox

\begin{document}

\setbox\CDossierGapEntryBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \CDossierSection{Experience}
  \begin{CDossierEntry}[title = {Engineer}]
    \noindent Entry body line.\par
  \end{CDossierEntry}
}

\setbox\CDossierGapListBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \CDossierSection{Skills}
  \begin{CDossierItemize}
    \item Bullet line.
  \end{CDossierItemize}
}

\setbox\CDossierGapProseBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \CDossierSection{Summary}
  \noindent Prose body line.\par
}

\directlua{
  local below = \number\dimexpr\CDossierSectionBelowSkip\relax
  local entryabove = \number\dimexpr\CDossierEntryAboveSkip\relax
  local listedge = \number\dimexpr\CDossierListEdgeSkipBefore\relax

  local function contains_rule(list)
    if not list then return false end
    for item in node.traverse(list) do
      local kind = node.type(item.id)
      if kind == "rule" then return true end
      if (kind == "hlist" or kind == "vlist") and contains_rule(item.list) then
        return true
      end
    end
    return false
  end

  % Sum every glue and kern between the rule's line and the next box: that
  % total is the gap a reader sees between the rule and the section's content.
  % Comments here must use TeX's comment character, not Lua's: this argument is
  % tokenised by TeX first, which folds every newline into a space, so a Lua
  % comment would swallow the remainder of the program.
  local function gap_after_rule(boxnumber)
    local seen = false
    local total = 0
    for item in node.traverse(tex.box[boxnumber].list) do
      local kind = node.type(item.id)
      if seen then
        if kind == "glue" then
          total = total + item.width
        elseif kind == "kern" then
          total = total + item.kern
        elseif kind == "hlist" or kind == "vlist" then
          return total
        end
      elseif kind == "hlist" and item.height <= 65536 and contains_rule(item.list) then
        seen = true
      end
    end
    return nil
  end

  % Report in points without a literal per-cent sign inside the string, which
  % TeX would read as a comment and use to truncate this Lua source.
  local function pt(sp)
    return tostring(math.floor(sp / 65536 * 1000 + 0.5) / 1000) .. "pt"
  end

  local function check(label, boxnumber, blockskip)
    local expected = below
    if blockskip > expected then expected = blockskip end
    local measured = gap_after_rule(boxnumber)
    if measured == nil then
      tex.error("Section rule not found in the " .. label .. " fixture")
    elseif math.abs(measured - expected) > 655 then
      tex.error(
        "Section rule gap is not owned by its token (" .. label .. ")",
        {
          "CDossierSectionBelowSkip is " .. pt(below) .. " and the following",
          "block contributes " .. pt(blockskip) .. ", so the gap must collapse",
          "to " .. pt(expected) .. "; measured " .. pt(measured) .. "."
        }
      )
    end
  end

  check("entry-led", \number\CDossierGapEntryBox, entryabove)
  check("list-led", \number\CDossierGapListBox, listedge)
  check("prose-led", \number\CDossierGapProseBox, 0)
}

\box\CDossierGapEntryBox
\box\CDossierGapListBox
\box\CDossierGapProseBox

\end{document}
