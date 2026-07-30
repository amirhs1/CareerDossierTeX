% Shared regression: \CDossierListEdgeSkip owns the whole list-edge gap.
%
% Issue #176. The token is documented as the sole owner of the vertical
% distance between preceding content and a list that follows it, and the
% vertical-rhythm table in docs/ARCHITECTURE.md reports its value as that
% distance. LaTeX's `\list' adds `\partopsep' on top of `topsep' whenever the
% list opens a new paragraph, and the `article' default is a fixed 3 pt that no
% CDossier token owns and that does not rescale with `fontsize'. Without an
% explicit `partopsep = 0pt' the real gap was the token plus 3 pt -- wrong in
% absolute terms, and proportionally larger at 10pt than at 12pt.
%
% The fixture measures the paragraph-to-list case, which is exactly the case
% `\partopsep' applies to. It sums only the explicit vertical skips (glue
% subtype 0, what `\vskip' and `\addvspace' contribute) between the paragraph's
% last line and the list's first line. Interline `\baselineskip' glue and
% `\parskip' are deliberately excluded: they are set elsewhere and depend on the
% font and the body size, so including them would make the assertion brittle
% without testing anything this token owns.
\CDossierSetup{name = {Ada Lovelace}}

\newbox\CDossierListEdgeBox

\begin{document}

\setbox\CDossierListEdgeBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \noindent Prose line before the list.\par
  \begin{CDossierItemize}
    \item Bullet line.
  \end{CDossierItemize}
}

\directlua{
  local listedge = \number\dimexpr\CDossierListEdgeSkip\relax
  local boxnumber = \number\CDossierListEdgeBox

  % Report in points without a literal per-cent sign inside the string, which
  % TeX would read as a comment and use to truncate this Lua source.
  local function pt(sp)
    return tostring(math.floor(sp / 65536 * 1000 + 0.5) / 1000) .. "pt"
  end

  % Sum the explicit skips between the first line box (the paragraph) and the
  % second (the list's first item). Comments here must use TeX's comment
  % character, not Lua's: this argument is tokenised by TeX first, which folds
  % every newline into a space, so a Lua comment would swallow the rest.
  local function list_edge_skip()
    local seen = false
    local total = 0
    for item in node.traverse(tex.box[boxnumber].list) do
      local kind = node.type(item.id)
      if kind == "hlist" then
        if seen then return total end
        seen = true
      elseif seen and kind == "glue" and item.subtype == 0 then
        total = total + item.width
      end
    end
    return nil
  end

  local measured = list_edge_skip()
  if measured == nil then
    tex.error("The list-edge fixture found no list line after the paragraph")
  elseif measured ~= listedge then
    tex.error(
      "The list-edge gap is not owned by its token",
      {
        "CDossierListEdgeSkip is " .. pt(listedge) .. ", so that must be the",
        "whole explicit skip before a list opening a new paragraph;",
        "measured " .. pt(measured) .. ". A stray 3pt is LaTeX's partopsep,",
        "which the list must set to 0pt."
      }
    )
  end
}

\box\CDossierListEdgeBox

\end{document}
