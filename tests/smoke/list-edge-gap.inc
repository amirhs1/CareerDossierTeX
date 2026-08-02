% Shared regression: the list-edge tokens own the whole gap at both ends of a
% list, and the two ends are independently controlled.
%
% Issue #176. The tokens are documented as the sole owners of the vertical
% distance between a list and the content around it, and the vertical-rhythm
% table in docs/ARCHITECTURE.md reports their values as those distances.
% LaTeX's `\list' adds `\partopsep' on top of `topsep' whenever the list opens
% a new paragraph, and the `article' default is a fixed 3 pt that no CDossier
% token owns and that does not rescale with `fontsize'. Without an explicit
% `partopsep = 0pt' the real gap was the token plus 3 pt -- wrong in absolute
% terms, and proportionally larger at 10pt than at 12pt.
%
% Issue #191. `topsep' is LaTeX's only list-edge key and is used at both ends,
% so a class that passes one token through it cannot give the closing edge a
% different value. The second fixture below perturbs
% `\CDossierRecordListEdgeBelowSkip' alone: without the closing-edge
% mechanism the list would still emit `\CDossierRecordListEdgeAboveSkip' below
% itself and the assertion would fail. Keeping the perturbed value distinct
% from every other rhythm token is what stops the check from passing vacuously
% while both ratios share one calibrated value.
%
% Both fixtures measure the paragraph-to-list-to-paragraph case, which is
% exactly the case `\partopsep' applies to. They sum only the explicit vertical
% skips (glue subtype 0, what `\vskip' and `\addvspace' contribute) between the
% adjacent line boxes. Interline `\baselineskip' glue and `\parskip' are
% deliberately excluded: they are set elsewhere and depend on the font and the
% body size, so including them would make the assertion brittle without testing
% anything these tokens own.
\CDossierSetup{name = {Ada Lovelace}}

% The list under test. A fixture may define this before \input to point the
% same contract at another list environment built on the shared tokens.
\providecommand\CDossierListEdgeList{%
  \begin{CDossierItemize}
    \item Bullet line.
  \end{CDossierItemize}%
}

% Whether the closing edge is asserted. A tagged build replaces LaTeX's list
% internals with LaTeX Lab's block templates, which do not take their closing
% spacing from `\@topsepadd', so the class cannot place the closing token there
% and the measured gap is LaTeX Lab's own. That divergence predates #191 and
% is tracked as #193 --
% it is present on the tagged path with a single shared list-edge token too --
% so a fixture on that path asserts the opening edge only.
\providecommand\CDossierListEdgeClosingOwned{1}

\newbox\CDossierListEdgeBox
\newbox\CDossierListEdgeAfterBox

\begin{document}

\setbox\CDossierListEdgeBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \noindent Prose line before the list.\par
  \CDossierListEdgeList
  \noindent Prose line after the list.\par
}

% A value no rhythm token resolves to at any supported body size, so a gap that
% matches it can only have come from the closing-edge token.
\setbox\CDossierListEdgeAfterBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \CDossierRecordListEdgeBelowSkip=17pt\relax
  \noindent Prose line before the list.\par
  \CDossierListEdgeList
  \noindent Prose line after the list.\par
}

\directlua{
  local before = \number\dimexpr\CDossierRecordListEdgeAboveSkip\relax
  local after = \number\dimexpr\CDossierRecordListEdgeBelowSkip\relax
  local perturbed = \number\dimexpr 17pt\relax

  % Report in points without a literal per-cent sign inside the string, which
  % TeX would read as a comment and use to truncate this Lua source.
  local function pt(sp)
    return tostring(math.floor(sp / 65536 * 1000 + 0.5) / 1000) .. "pt"
  end

  % Sum the explicit skips between consecutive line boxes: the paragraph, the
  % list's only item, and the paragraph after the list. The first total is the
  % opening edge and the second is the closing edge.
  %
  % Comments here must use TeX's comment character, not Lua's: this argument is
  % tokenised by TeX first, which folds every newline into a space, so a Lua
  % comment would swallow the rest.
  local function list_edge_skips(boxnumber)
    local lines = 0
    local totals = {}
    for item in node.traverse(tex.box[boxnumber].list) do
      local kind = node.type(item.id)
      if kind == "hlist" then
        lines = lines + 1
        if lines == 3 then return totals[1], totals[2] end
        totals[lines] = 0
      elseif lines > 0 and kind == "glue" and item.subtype == 0 then
        totals[lines] = totals[lines] + item.width
      end
    end
    return nil, nil
  end

  local function check(label, boxnumber, expected_before, expected_after)
    local measured_before, measured_after = list_edge_skips(boxnumber)
    if measured_before == nil then
      tex.error("The " .. label .. " fixture found no list line after the paragraph")
      return
    end
    if expected_after == nil then measured_after = nil end
    if measured_before ~= expected_before then
      tex.error(
        "The opening list-edge gap is not owned by its token (" .. label .. ")",
        {
          "CDossierRecordListEdgeAboveSkip is " .. pt(expected_before) ..
          ", so that",
          "must be the whole explicit skip before a list opening a new",
          "paragraph; measured " .. pt(measured_before) .. ". A stray 3pt is",
          "LaTeX's partopsep, which the list must set to 0pt."
        }
      )
    end
    if measured_after ~= expected_after then
      tex.error(
        "The closing list-edge gap is not owned by its token (" .. label .. ")",
        {
          "CDossierRecordListEdgeBelowSkip is " .. pt(expected_after) ..
          ", so that",
          "must be the whole explicit skip after the list; measured " ..
          pt(measured_after) .. ". LaTeX uses topsep at both ends, so the list",
          "must substitute the closing token before it ends."
        }
      )
    end
  end

  local closing_owned = \CDossierListEdgeClosingOwned == 1

  check("default", \number\CDossierListEdgeBox, before,
        closing_owned and after or nil)
  check("perturbed-closing-edge", \number\CDossierListEdgeAfterBox, before,
        closing_owned and perturbed or nil)
}

\box\CDossierListEdgeBox
\box\CDossierListEdgeAfterBox

\end{document}
