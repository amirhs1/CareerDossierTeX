% Shared issue #144 assertion: every statement-header line must select its
% calibrated size command rather than an inherited LaTeX relative size.
\ExplSyntaxOn
\int_new:N \g__cdossier_test_statement_name_size_int
\int_new:N \g__cdossier_test_statement_title_size_int
\int_new:N \g__cdossier_test_statement_headline_size_int
\int_new:N \g__cdossier_test_statement_body_size_int
\int_new:N \g__cdossier_test_statement_small_size_int

\cs_new_eq:NN \__cdossier_test_statement_name_size: \CDossierSizeName
\cs_new_eq:NN \__cdossier_test_statement_title_size: \CDossierSizeTitle
\cs_new_eq:NN \__cdossier_test_statement_headline_size: \CDossierSizeHeadline
\cs_new_eq:NN \__cdossier_test_statement_body_size: \CDossierSizeBody
\cs_new_eq:NN \__cdossier_test_statement_small_size: \CDossierSizeSmall

\cs_set_protected:Npn \CDossierSizeName
  {
    \int_gincr:N \g__cdossier_test_statement_name_size_int
    \__cdossier_test_statement_name_size:
  }
\cs_set_protected:Npn \CDossierSizeTitle
  {
    \int_gincr:N \g__cdossier_test_statement_title_size_int
    \__cdossier_test_statement_title_size:
  }
\cs_set_protected:Npn \CDossierSizeHeadline
  {
    \int_gincr:N \g__cdossier_test_statement_headline_size_int
    \__cdossier_test_statement_headline_size:
  }
\cs_set_protected:Npn \CDossierSizeBody
  {
    \int_gincr:N \g__cdossier_test_statement_body_size_int
    \__cdossier_test_statement_body_size:
  }
\cs_set_protected:Npn \CDossierSizeSmall
  {
    \int_gincr:N \g__cdossier_test_statement_small_size_int
    \__cdossier_test_statement_small_size:
  }

\msg_new:nnn { cdossier-test } { statement-header-size }
  { Statement~header~size~assertion~failed:~#1. }
\cs_new_protected:Npn \__cdossier_test_statement_assert_size:Nn #1#2
  {
    \int_compare:nNnF {#1} = {#2}
      {
        \msg_fatal:nnx { cdossier-test } { statement-header-size }
          {
            \token_to_str:N #1 ~was~invoked~
            \int_use:N #1 ~times;~expected~#2
          }
      }
  }
\cs_new_protected:Npn \__cdossier_test_statement_assert_header_sizes:
  {
    \__cdossier_test_statement_assert_size:Nn
      \g__cdossier_test_statement_name_size_int { 1 }
    \__cdossier_test_statement_assert_size:Nn
      \g__cdossier_test_statement_title_size_int { 1 }
    \__cdossier_test_statement_assert_size:Nn
      \g__cdossier_test_statement_headline_size_int { 1 }
    \__cdossier_test_statement_assert_size:Nn
      \g__cdossier_test_statement_body_size_int { 1 }
    \__cdossier_test_statement_assert_size:Nn
      \g__cdossier_test_statement_small_size_int { 2 }
  }
\ExplSyntaxOff
