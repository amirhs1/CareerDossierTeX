% itemize-nested.inc — shared regression (#686): a CDossierItemize nested
% inside an \item of another CDossierItemize builds, as a nested `itemize'
% does. If this fixture stops with "TeX capacity exceeded ... input stack
% size", the inner list's `\item' has called itself: the list policy saved the
% outer list's wrapper as the real `\item'.
%
% Three levels, with the inner lists in the first and in the last outer item,
% so the nesting is exercised both before the outer list's item-2 measurement
% and at the outer list's end.
%
% Each list must also record its page-break inputs under its own serial. A
% list that holds a nested list ends after the nested one began, so a record
% written under the serial counter's current value lands on the nested list's
% serial, and every later pass reads the wrong list's counts and warns that the
% page breaks need another run. The runner compiles once, so that warning
% never shows here; the wrapper below turns the duplicate serial into an error
% on the first pass instead.
%
% Property test: the fixture asserts that the document compiles with a clean
% log and that no two lists share a serial; no reference rendering exists.
\CDossierSetup{name = {Ada Lovelace}}

\makeatletter
\let\cdtest@writelistlen\cdossier@writelistlen
\renewcommand\cdossier@writelistlen[2]{%
  \@ifundefined{cdtest@listserial@#1}{}{%
    \PackageError{cdossier-test}{Two lists recorded under serial #1}{}}%
  \expandafter\gdef\csname cdtest@listserial@#1\endcsname{}%
  \cdtest@writelistlen{#1}{#2}%
}
\makeatother

\begin{document}
\begin{CDossierItemize}
  \item Outer first item.
    \begin{CDossierItemize}
      \item Inner first item.
        \begin{CDossierItemize}
          \item Innermost item.
        \end{CDossierItemize}
      \item Inner second item.
    \end{CDossierItemize}
  \item Outer second item.
  \item Outer last item.
    \begin{CDossierItemize}
      \item Inner item of the last outer item.
    \end{CDossierItemize}
\end{CDossierItemize}
\end{document}
