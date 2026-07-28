% Shared issue #144 assertion: the statement name must invoke the calibrated
% name token and resolve to the selected class size, not fixed LaTeX \Huge.
\ExplSyntaxOn
\bool_new:N \g__cdossier_test_statement_name_size_bool
\cs_new_eq:NN \__cdossier_test_statement_original_name_size: \CDossierSizeName
\msg_new:nnn { cdossier-test } { statement-name-size }
  { Statement~name-size~assertion~failed:~#1. }
\cs_set_protected:Npn \CDossierSizeName
  {
    \bool_gset_true:N \g__cdossier_test_statement_name_size_bool
    \__cdossier_test_statement_original_name_size:
    \dim_compare:nNnF
      { \cs:w f@size \cs_end: pt } = { \CDossierTestExpectedNameSize }
      {
        \msg_fatal:nnx { cdossier-test } { statement-name-size }
          {
            size~was~\cs:w f@size \cs_end: pt;~expected~
            \CDossierTestExpectedNameSize
          }
      }
    \dim_compare:nNnF
      { \baselineskip } = { \CDossierTestExpectedNameLeading }
      {
        \msg_fatal:nnx { cdossier-test } { statement-name-size }
          {
            leading~was~\skip_use:N \baselineskip;~expected~
            \CDossierTestExpectedNameLeading
          }
      }
  }
\cs_new_protected:Npn \__cdossier_test_statement_assert_name_size:
  {
    \bool_if:NF \g__cdossier_test_statement_name_size_bool
      {
        \msg_fatal:nnn { cdossier-test } { statement-name-size }
          { \token_to_str:N \CDossierSizeName ~was~not~invoked }
      }
  }
\ExplSyntaxOff

\CDossierSetup{name={Ada Lovelace}, email={ada@example.test}}
\begin{document}
\MakeCDossierStatementHeader
\ExplSyntaxOn
\__cdossier_test_statement_assert_name_size:
\ExplSyntaxOff
\end{document}
