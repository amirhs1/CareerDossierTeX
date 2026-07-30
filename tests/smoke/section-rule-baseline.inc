% Shared regression: the section rule sits a fixed distance below the heading
% baseline.
%
% Issue #169. `\CDossierSectionRuleSkip' is the distance from the section
% heading's baseline to the top of the decorative rule. That distance must not
% depend on the heading's glyphs.
%
% Before the fix the rule was placed relative to the heading's *box bottom*,
% whose depth grows when the heading contains a descender, so the rule dropped
% further from the baseline under `Experience' (p) than under `Education'. The
% rule read as sitting at two different heights in one document.
%
% The fixture also asserts that the rule clears the heading's descenders. A
% baseline-relative offset smaller than the heading's depth would draw the rule
% through descender ink, so the token has a lower bound the design must respect.
\CDossierSetup{name = {Ada Lovelace}}

\newbox\CDossierRuleDescenderBox
\newbox\CDossierRulePlainBox

\begin{document}

\setbox\CDossierRuleDescenderBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \CDossierSection{Experience}
  \noindent Content line.\par
}

\setbox\CDossierRulePlainBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \CDossierSection{Education}
  \noindent Content line.\par
}

\directlua{
  local expected = \number\dimexpr\CDossierSectionRuleSkip\relax

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

  % Walk to the rule's line, accumulating the vertical material after the
  % heading. The heading baseline sits its own depth above the heading box's
  % bottom edge, so baseline-to-rule is that depth plus everything between.
  local function baseline_to_rule(boxnumber)
    local depth = nil
    local between = 0
    for item in node.traverse(tex.box[boxnumber].list) do
      local kind = node.type(item.id)
      if kind == "hlist" and item.height <= 65536 and contains_rule(item.list) then
        if depth == nil then return nil, nil end
        return depth + between, depth
      elseif kind == "hlist" or kind == "vlist" then
        depth = item.depth
        between = 0
      elseif depth ~= nil then
        if kind == "glue" then
          between = between + item.width
        elseif kind == "kern" then
          between = between + item.kern
        end
      end
    end
    return nil, nil
  end

  local function pt(sp)
    return tostring(math.floor(sp / 65536 * 1000 + 0.5) / 1000) .. "pt"
  end

  local measured = {}

  local function check(label, boxnumber)
    local offset, depth = baseline_to_rule(boxnumber)
    if offset == nil then
      tex.error("Section rule not found in the " .. label .. " fixture")
      return
    end
    measured[label] = offset
    if math.abs(offset - expected) > 655 then
      tex.error(
        "Section rule is not placed from the heading baseline (" .. label .. ")",
        {
          "CDossierSectionRuleSkip is " .. pt(expected) .. ", so the rule must",
          "sit that far below the heading baseline; measured " .. pt(offset) .. ".",
          "The heading box depth is " .. pt(depth) .. "."
        }
      )
    end
    if expected <= depth then
      tex.error(
        "Section rule would cross the heading's descenders (" .. label .. ")",
        {
          "CDossierSectionRuleSkip is " .. pt(expected) .. " but the heading",
          "descends " .. pt(depth) .. " below its baseline. The token must",
          "exceed the heading's depth so the rule clears descender ink."
        }
      )
    end
  end

  check("descender heading", \number\CDossierRuleDescenderBox)
  check("plain heading", \number\CDossierRulePlainBox)

  local a = measured["descender heading"]
  local b = measured["plain heading"]
  if a ~= nil and b ~= nil and math.abs(a - b) > 655 then
    tex.error(
      "Section rule height depends on the heading's glyphs",
      {
        "A heading with a descender put the rule " .. pt(a) .. " below its",
        "baseline; one without put it " .. pt(b) .. ". The two must agree."
      }
    )
  end
}

\box\CDossierRuleDescenderBox
\box\CDossierRulePlainBox

\end{document}
