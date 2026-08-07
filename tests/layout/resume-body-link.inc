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
% The link appears twice: in a bullet inside an entry, and in a prose paragraph.
% Those are the two places a user writes one.
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
  \end{CDossierItemize}
\end{CDossierEntry}

The programme's validation notes and reproducibility appendix are deposited at
\CDossierLink{https://records.example.invalid/collections/analytical-engine/1843/4d7e0b2a6c9f1e3b5d8a0c2e4f6b8d1a3c5e7f9b/appendix-g.html}
and remain publicly available for review.
\end{document}
