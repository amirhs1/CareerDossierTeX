% resume-entry-dates-page-furniture.inc — the body shared by
% resume-entry-dates-page-furniture.tex and resume-entry-dates-default-medium.tex,
% which differ only in their `medium' class option; each wrapper states its
% own purpose.
\CDossierSetup{
  name     = {Ada Lovelace},
  headline = {Accessibility Engineer},
  email    = {ada@example.com},
  phone    = {+1 416 555 0142},
  website  = {example.com/ada},
}
\begin{document}
\MakeCDossierHeader
\CDossierSection{Experience}
\begin{CDossierEntry}[
  title        = {Senior Engineer},
  organization = {Example Labs},
  location     = {Toronto, ON},
  dates        = {2024--Present}
]
  \begin{CDossierItemize}
    \item First achievement in source order.
    \item Second achievement with a measurable reporting outcome.
  \end{CDossierItemize}
\end{CDossierEntry}
\newpage
\CDossierSection{Additional Experience}
\begin{CDossierEntry}[
  title        = {Engineer},
  organization = {Example Services},
  location     = {Ottawa, ON},
  dates        = {2022--2024}
]
  \begin{CDossierItemize}
    \item Second-page content that follows the shared page furniture.
  \end{CDossierItemize}
\end{CDossierEntry}
\end{document}
