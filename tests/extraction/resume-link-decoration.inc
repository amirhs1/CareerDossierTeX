% Shared body for the link-decoration extraction pair (issue #278).
%
% Both fixtures that \input this differ in exactly one class option, `medium'.
% Their committed baselines must therefore be identical, character for
% character, and that identity is the assertion: the screen medium adds a
% visible rule and must add nothing whatsoever to the text layer. An ATS, a
% recruiter's copy-paste, and a screen reader all read the same document under
% either medium.
%
% The body carries all three link shapes on purpose:
%   - an author-written \href anchor, the only one the screen medium decorates;
%   - \CDossierLink, whose visible text is the address;
%   - the contact line, whose items are addresses too.
% A decoration that leaked into the text layer of any of them shows up here as a
% baseline diff.
\CDossierSetup{
  name     = {Ada Lovelace},
  headline = {Data Scientist},
  email    = {ada@example.com},
  phone    = {+1 416 555 0142},
  website  = {example.com/ada},
}
\begin{document}
\MakeCDossierHeader
\CDossierSection{Experience}
\begin{CDossierEntry}[
  title        = {Senior Data Scientist},
  organization = {Example Research Laboratory},
  location     = {Toronto, ON},
  dates        = {2024--Present}
]
  \begin{CDossierItemize}
    \item Shipped the analytical engine, documented in a
          \href{https://example.com/work}{public write-up} that a reader
          can follow.
    \item An address the reader sees in full:
          \CDossierLink{example.com/notes}.
  \end{CDossierItemize}
\end{CDossierEntry}
\end{document}
