% testphasefixture-clean.cls — tests/lint/run-testphase-keys.sh control 4: a
% class that calls the stable tagpdf API and names no testphase key, so the
% lint must pass it (#478). Lint input only; never compiled.
\ProvidesExplClass{testphasefixture-clean}{2026-11-05}{0.0.0}{lint fixture}
\tag_if_active:T { \tag_struct_begin:n { tag = P } }
