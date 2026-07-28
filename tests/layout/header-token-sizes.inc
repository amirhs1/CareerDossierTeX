% Shared assertions for issue #139's identity-block layout fixtures.
%
% Each wrapper selects one supported body size and decides whether `headline`
% is present. The test records which calibrated size commands the rendered
% header actually calls; checking the token values alone would not catch a
% component that continued to use LaTeX's \Huge/\large/\small defaults.
\ExplSyntaxOn
\bool_new:N \g__cdossier_test_name_size_bool
\bool_new:N \g__cdossier_test_headline_size_bool
\bool_new:N \g__cdossier_test_small_size_bool
\cs_new_eq:NN \__cdossier_test_original_name_size: \CDossierSizeName
\cs_new_eq:NN \__cdossier_test_original_headline_size: \CDossierSizeHeadline
\cs_new_eq:NN \__cdossier_test_original_small_size: \CDossierSizeSmall
\cs_set_protected:Npn \CDossierSizeName
  {
    \bool_gset_true:N \g__cdossier_test_name_size_bool
    \__cdossier_test_original_name_size:
  }
\cs_set_protected:Npn \CDossierSizeHeadline
  {
    \bool_gset_true:N \g__cdossier_test_headline_size_bool
    \__cdossier_test_original_headline_size:
  }
\cs_set_protected:Npn \CDossierSizeSmall
  {
    \bool_gset_true:N \g__cdossier_test_small_size_bool
    \__cdossier_test_original_small_size:
  }
\msg_new:nnn { cdossier-test } { header-layout }
  { Identity~block~layout~assertion~failed:~#1. }
\cs_new_protected:Npn \__cdossier_test_assert_header:
  {
    \bool_if:NF \g__cdossier_test_name_size_bool
      { \msg_fatal:nnn { cdossier-test } { header-layout }
          { name~did~not~use~\token_to_str:N \CDossierSizeName } }
    \bool_if:NF \g__cdossier_test_small_size_bool
      { \msg_fatal:nnn { cdossier-test } { header-layout }
          { contacts~did~not~use~\token_to_str:N \CDossierSizeSmall } }
    \ifnum \CDossierTestExpectedHeadline = 1\relax
      \bool_if:NF \g__cdossier_test_headline_size_bool
        { \msg_fatal:nnn { cdossier-test } { header-layout }
            { headline~did~not~use~\token_to_str:N \CDossierSizeHeadline } }
    \else
      \bool_if:NT \g__cdossier_test_headline_size_bool
        { \msg_fatal:nnn { cdossier-test } { header-layout }
            { absent~headline~used~a~headline~size } }
    \fi
    \dim_compare:nNnF
      { \CDossierHeaderBelowSkip } = { \CDossierSectionAboveSkip }
      { \msg_fatal:nnn { cdossier-test } { header-layout }
          { header-below~and~section-above~spacing~differ } }
  }
\ExplSyntaxOff

\CDossierSetup{
  name = {Ada Lovelace},
  email = {ada.lovelace@example.com},
  phone = {+1 416 555 0142},
  location = {Toronto, Ontario},
}
\ifdefined\CDossierTestHeadline
  \CDossierSetup{headline = {\CDossierTestHeadline}}
\fi

\begin{document}
\MakeCDossierHeader
\ExplSyntaxOn
\__cdossier_test_assert_header:
\ExplSyntaxOff
\CDossierSection{Experience}
The identity block remains followed by ordinary résumé content.
\end{document}
