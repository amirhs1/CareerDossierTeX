% Shared fixture for the body-text link matrix (issue #308).
%
% A long link in body text has no supported break point of its own: plain text
% sets it as one token, and \emergencystretch cannot rescue a line that holds
% one over-wide token because there is no interword glue on it to stretch.
% \CDossierLink supplies the break points.
%
% This is a rendered assertion, not a report. The path segment below carries no
% punctuation and no hyphenation point, so with \CDossierLink replaced by the
% bare URL the runner's "no overfull boxes" check fails at every size and both
% margins -- measured 114.57 pt over at fontsize=10pt/margin=narrow, rising to
% 318.15 pt at 12pt/normal. The same string inside \url is still overfull,
% because url.sty breaks at punctuation only.
%
% The link appears in a bullet inside an entry and in a prose paragraph: the two
% places a user writes one.
%
% The second bullet is a real, publicly resolvable address rather than a
% constructed one — a Wikipedia advanced-search result, 262 characters, with the
% query string an ordinary search produces. It covers what the constructed URLs
% above do not: `+' separators, a `%'-escaped octet, and `&' between parameters.
% The first two are ordinary characters here, but `%' and `&' are TeX's, so the
% source escapes them as `\%' and `\&' exactly as it would anywhere else — the
% argument is read as ordinary text, not as \url's verbatim argument. Both
% render as themselves and reach the link target unescaped;
% tests/links/resume-body-link.tex asserts that end to end.
\CDossierSetup{
  name  = {Alexandria Montgomery-Fitzgerald},
  email = {alexandria@example.org},
}
\begin{document}
\MakeCDossierHeader
\CDossierSection{Experience}
\begin{CDossierEntry}[
  title        = {Principal Data Scientist},
  organization = {Digital Services Laboratory},
  location     = {Ontario, Canada},
  dates        = {September 2024--Present}
]
  \begin{CDossierItemize}
    \item Delivered the reproducible archival interoperability framework,
          documented at
          \CDossierLink{https://example.org/programs/analytics-modernization/2024/final-report/8f3a9c1b7e2d4f6a8c0e2b4d6f8a1c3e5b7d9f1a3c5e7b9d/notes.html}
          for downstream consumers.
    \item Consulted the published search index at
          \CDossierLink{https://en.wikipedia.org/w/index.php?search=research-creation+sound-producing+Iranian+adornments+museum+conservation+archival+silencing+diasporic+futurism+embodied+performance+sound+studies+material+culture+museum+collections+classification+preservation\&title=Special\%3ASearch\&profile=advanced\&fulltext=1\&ns0=1}
          throughout the programme.
  \end{CDossierItemize}
\end{CDossierEntry}

The programme's validation notes and reproducibility appendix are deposited at
\CDossierLink{https://records.example.invalid/collections/analytical-engine/1843/4d7e0b2a6c9f1e3b5d8a0c2e4f6b8d1a3c5e7f9b/appendix-g.html}
and remain publicly available for review.
\end{document}
