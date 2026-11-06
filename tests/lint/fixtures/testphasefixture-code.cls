% testphasefixture-code.cls — tests/lint/run-testphase-keys.sh control 2: a
% class that sets a LaTeX Lab testphase key in code, so the lint must report it
% (#478). Lint input only; never compiled.
\ProvidesExplClass{testphasefixture-code}{2026-11-05}{0.0.0}{lint fixture}
\keys_set:nn { template / block / std } { end-vspace = 0pt }
