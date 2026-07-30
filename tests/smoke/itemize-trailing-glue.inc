% Shared regression: a full-measure bullet must not emit a blank line.
%
% Issue #170. Readable source puts `\end{CDossierItemize}' on its own line, so
% the newline after the final item's text is a space token at the end of that
% item's paragraph. When the item's last line already fills the measure, TeX
% carries the space onto a line of its own: a box with no glyphs, zero height,
% and zero depth, preceded by a full `\baselineskip'. Nothing is visible, but the
% following `\addvspace' cannot see past it, so the next structural gap grows by
% a whole line -- 27.84 pt instead of 14.28 pt above the section that follows, in
% the shipped default résumé.
%
% Whether a given item fills the measure depends on the font, the body size, and
% the line width, so the fixture does not rely on one magic sentence. It steps
% through a range of item lengths and requires every one of them to be free of
% blank lines: some length in the range lands on the boundary, and a change to
% the fonts or the type scale moves which one rather than disabling the test.
\CDossierSetup{name = {Ada Lovelace}}

\begin{document}

\directlua{
  local blank = {}
  local count = 0

  local function has_content(list)
    if not list then return false end
    for item in node.traverse(list) do
      local kind = node.type(item.id)
      if kind == "glyph" or kind == "rule" then return true end
      if (kind == "hlist" or kind == "vlist") and has_content(item.list) then
        return true
      end
    end
    return false
  end

  % A blank line is a line box carrying no glyph and no rule, with neither
  % height nor depth: everything the trailing space contributed and nothing else.
  %
  % Note the explicit counter. TeX doubles a macro-parameter character while it
  % expands this argument, so Lua's length operator cannot be used here.
  function CDossierCountBlankLines(boxnumber, label)
    for item in node.traverse(tex.box[boxnumber].list) do
      if node.type(item.id) == "hlist" and item.height == 0
         and item.depth == 0 and not has_content(item.list) then
        count = count + 1
        blank[count] = label
      end
    end
  end

  function CDossierAssertNoBlankLines()
    if count > 0 then
      tex.error(
        "A full-measure bullet emitted a blank line",
        {
          "The final item's trailing space was carried onto a line of its own.",
          "Affected item lengths: " .. table.concat(blank, ", ") .. "."
        }
      )
    end
  end
}

\ExplSyntaxOn
\tl_new:N \l__cdossier_test_text_tl
\clist_const:Nn \c__cdossier_test_words_clist
  {
    alpha , beta , gamma , delta , epsilon , zeta , eta , theta , iota ,
    kappa , lambda , mu , nu , xi , omicron , pi , rho , sigma , tau ,
    upsilon , phi , chi , psi , omega , quantum , vector , matrix , tensor ,
    scalar , gradient , divergence , manifold
  }

\int_step_inline:nnn { 4 } { \clist_count:N \c__cdossier_test_words_clist }
  {
    \tl_clear:N \l__cdossier_test_text_tl
    \int_step_inline:nnn { 1 } { #1 }
      {
        \tl_put_right:Nx \l__cdossier_test_text_tl
          { \clist_item:Nn \c__cdossier_test_words_clist { ##1 } ~ }
      }
    \vbox_set:Nn \l_tmpa_box
      {
        \dim_set:Nn \tex_hsize:D { 20em }
        \dim_set:Nn \linewidth { \tex_hsize:D }
        \begin { CDossierItemize }
          \item \tl_use:N \l__cdossier_test_text_tl
        \end { CDossierItemize }
      }
    \directlua
      { CDossierCountBlankLines(\number\l_tmpa_box, "#1~words") }
  }
\ExplSyntaxOff

\directlua{ CDossierAssertNoBlankLines() }

\end{document}
