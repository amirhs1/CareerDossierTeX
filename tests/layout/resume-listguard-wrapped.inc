% resume-listguard-wrapped.inc — shared body for the list-guard pair (#562).
%
% Shared so that the tagged and untagged arms cannot drift: the parity they
% assert is only meaningful while both compile the same document. See
% resume-listguard-wrapped.tex for what the pair measures.
\CDossierSetup{
  name     = {Grace Hopper},
  headline = {Systems Engineer},
  email    = {grace.hopper@example.com},
  phone    = {+1 416 555 0198},
  location = {Toronto, Ontario, Canada},
}
\begin{document}
\MakeCDossierHeader

\CDossierSection{Experience}
\begin{CDossierEntry}[title = {Modernization Program}, organization = {Continental Reliability Consortium}, location = {Ottawa, ON}, dates = {2019--Present}]
  \begin{CDossierItemize}
    \item Filler line 1 covering additional operational reporting responsibilities and review duties.
    \item Filler line 2 covering additional operational reporting responsibilities and review duties.
    \item Filler line 3 covering additional operational reporting responsibilities and review duties.
    \item Filler line 4 covering additional operational reporting responsibilities and review duties.
    \item Filler line 5 covering additional operational reporting responsibilities and review duties.
    \item Filler line 6 covering additional operational reporting responsibilities and review duties.
    \item Filler line 7 covering additional operational reporting responsibilities and review duties.
    \item Filler line 8 covering additional operational reporting responsibilities and review duties.
    \item Filler line 9 covering additional operational reporting responsibilities and review duties.
    \item Filler line 10 covering additional operational reporting responsibilities and review duties.
    \item Filler line 11 covering additional operational reporting responsibilities and review duties.
    \item Filler line 12 covering additional operational reporting responsibilities and review duties.
    \item Filler line 13 covering additional operational reporting responsibilities and review duties.
    \item Filler line 14 covering additional operational reporting responsibilities and review duties.
    \item Filler line 15 covering additional operational reporting responsibilities and review duties.
    \item Filler line 16 covering additional operational reporting responsibilities and review duties.
    \item Filler line 17 covering additional operational reporting responsibilities and review duties.
    \item Filler line 18 covering additional operational reporting responsibilities and review duties.
    \item Filler line 19 covering additional operational reporting responsibilities and review duties.
    \item Filler line 20 covering additional operational reporting responsibilities and review duties.
    \item Filler line 21 covering additional operational reporting responsibilities and review duties.
    \item Filler line 22 covering additional operational reporting responsibilities and review duties.
    \item Filler line 23 covering additional operational reporting responsibilities and review duties.
    \item Filler line 24 covering additional operational reporting responsibilities and review duties.
    \item Filler line 25 covering additional operational reporting responsibilities and review duties.
    \item Filler line 26 covering additional operational reporting responsibilities and review duties.
    \item Filler line 27 covering additional operational reporting responsibilities and review duties.
    \item Filler line 28 covering additional operational reporting responsibilities and review duties.
    \item Filler line 29 covering additional operational reporting responsibilities and review duties.
    \item Filler line 30 covering additional operational reporting responsibilities and review duties.
    \item Filler line 31 covering additional operational reporting responsibilities and review duties.
    \item Filler line 32 covering additional operational reporting responsibilities and review duties.
    \item Filler line 33 covering additional operational reporting responsibilities and review duties.
    \item Filler line 34 covering additional operational reporting responsibilities and review duties.
    \item Filler line 35 covering additional operational reporting responsibilities and review duties.
    \item Filler line 36 covering additional operational reporting responsibilities and review duties.
  \end{CDossierItemize}
\end{CDossierEntry}
\begin{CDossierEntry}[title = {Reporting Platform Review}, organization = {Regional Data Cooperative}, location = {Kitchener, ON}, dates = {2015--2019}]
  \begin{CDossierItemize}
    \item Probe item one is written at a length that wraps to three typeset lines in this measure, so that the atom this entry forms is tall enough for the hole it opens to be worth measuring rather than a rounding difference in the page total, and so that the list has a wrapped item at each of its two guarded edges.
    \item Probe item two is written at a length that wraps to two typeset lines in this measure, so no edge item of this list is a single line.
    \item Probe item three is written at a length that wraps to two typeset lines as well, which is what makes the boundary before it legal under the line-based rule.
  \end{CDossierItemize}
\end{CDossierEntry}

\end{document}
