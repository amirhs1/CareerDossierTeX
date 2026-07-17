# Makefile — CareerDossierTeX
#
# Every target here runs the command CI runs in .github/workflows/build.yml, so
# a local check and a CI check cannot silently diverge. When you change a
# command in one place, change it in the other.
#
# Requirements: XeLaTeX and latexmk for everything; l3build for `regression`;
# pdftotext (Poppler) for `layout` and `extract-test`.
#
# Run `make help` for the target list.

LATEXMK       := latexmk -xelatex -interaction=nonstopmode -halt-on-error
LATEXMK_CLEAN := latexmk -C
RESUME        := examples/industry/resume-english.tex
LETTER        := examples/industry/letter-industry.tex

# `make` with no target builds both supported examples, which is what README.md
# documents under "Build".
.DEFAULT_GOAL := examples

.PHONY: help examples resume letter check test regression smoke layout extract-test clean

help: ## List the available targets
	@printf 'CareerDossierTeX make targets:\n\n'
	@grep -E '^[a-z][a-zA-Z_-]*:.*## ' $(MAKEFILE_LIST) \
	  | sed -E 's/^([a-zA-Z_-]+):.*## (.*)/\1|\2/' \
	  | awk -F'|' '{printf "  %-14s %s\n", $$1, $$2}'
	@printf '\n'

examples: resume letter ## Build both supported examples (default)

resume: ## Build the résumé example
	$(LATEXMK) $(RESUME)

letter: ## Build the cover-letter example
	$(LATEXMK) $(LETTER)

check: regression extract-test smoke layout examples ## Run every suite CI runs
	@printf '\nAll suites passed.\n'

test: check ## Alias for check

regression: ## Module regression suite (l3build check on XeTeX)
	l3build check

smoke: ## Supported builds and required failures
	tests/smoke/run.sh

layout: ## Layout-stress fixtures
	tests/layout/run.sh

extract-test: ## Text-extraction round-trip against committed baselines
	tests/extraction/run.sh

clean: ## Remove generated documents, logs, and the l3build sandbox
	-@$(LATEXMK_CLEAN) $(RESUME) $(LETTER) >/dev/null 2>&1
	-@l3build clean >/dev/null 2>&1
	@rm -rf build
	@rm -f tests/*/*.aux tests/*/*.log tests/*/*.out tests/*/*.pdf \
	       tests/*/*.xdv tests/*/*.fls tests/*/*.fdb_latexmk \
	       tests/*/*.diff tests/*/*.stdout
	@printf 'Cleaned generated files. Tracked source and .tlg baselines are untouched.\n'
