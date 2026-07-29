% Shared zero-token regression for the CV and résumé section rule.
%
% The heading, decorative rule, and first content line intentionally form one
% short vertical list. With every explicit section skip at zero, that list must
% contain no implicit baseline glue: the calibrated tokens, rather than a rule
% paragraph's line spacing, own the two visible gaps.
\CDossierSetup{name = {Ada Lovelace}}

\ExplSyntaxOn
\dim_zero:N \CDossierSectionAboveSkip
\dim_zero:N \CDossierSectionRuleSkip
\dim_zero:N \CDossierSectionBelowSkip
\ExplSyntaxOff

\newbox\CDossierSectionSpacingBox

\begin{document}

\setbox\CDossierSectionSpacingBox=\vbox{%
  \hsize=20em
  \linewidth=\hsize
  \CDossierSection{Experience}
  \noindent First content line.\par
}

\directlua{
  local baseline_glue = 0
  local glue_subtypes = node.subtypes("glue")
  local list = tex.box[\number\CDossierSectionSpacingBox].list
  for item in node.traverse(list) do
    if item.id == node.id("glue")
        and glue_subtypes[item.subtype] == "baselineskip" then
      baseline_glue = baseline_glue + 1
    end
  end
  if baseline_glue ~= 0 then
    tex.error(
      "Section rule retained implicit baseline glue",
      {
        "Expected zero baseline-glue nodes with all section skips at 0pt;",
        "found " .. baseline_glue .. "."
      }
    )
  end
}

\box\CDossierSectionSpacingBox

\end{document}
