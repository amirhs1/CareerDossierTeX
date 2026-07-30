# Makefile — CareerDossierTeX
#
# Build and test commands live here so local workflows and CI can invoke the
# same entry points. When a command is wired into CI, keep both places aligned.
#
# Requirements: LuaLaTeX and latexmk for everything; l3build for `regression`;
# pdftotext (Poppler) for `layout`, `extract-test`, `bibliography-test`, and
# `tagging`; pdftoppm (Poppler) for `review-page-two`;
# BibLaTeX and Biber for `bibliography-test` and `academic-bibliography`.
#
# `tagging` additionally uses veraPDF (PDF/UA-2 validation), mutool (MuPDF
# extraction), Biber (the BibLaTeX feasibility fixture), and PDFKit via
# osascript on macOS. Each of those gates skips with a notice when the tool is
# absent, and the runner reports which gates did not run — so `make tagging`
# succeeding locally does not by itself mean every gate was exercised.
#
# `resume`, `letter`, `academic-cv`, `academic-bibliography`, `academic-letter`,
# and `statements` write their PDFs, logs, and other latexmk output under the
# gitignored $(BUILD_DIR)/examples/ rather than beside the tracked example
# sources, so the source tree never picks up untracked build artifacts.
#
# Run `make help` for the target list.

BUILD_DIR        := build
EXAMPLES_BUILD_DIR := $(BUILD_DIR)/examples
LATEXMK       := latexmk -lualatex -interaction=nonstopmode -halt-on-error \
                 -output-directory=$(EXAMPLES_BUILD_DIR)
RESUME        := examples/industry/resume-english.tex
LETTER        := examples/industry/letter-industry.tex
ACADEMIC_CV   := examples/academic/cv-academic.tex
ACADEMIC_BIBLIOGRAPHY := examples/academic/cv-bibliography.tex
ACADEMIC_LETTER := examples/academic/letter-academic.tex
STATEMENTS := examples/statements/research-statement.tex \
              examples/statements/teaching-statement.tex \
              examples/statements/teaching-philosophy-statement.tex \
              examples/statements/diversity-statement.tex \
              examples/statements/artist-statement.tex \
              examples/statements/statement-of-purpose.tex

# `make` with no target builds every supported example, which is what README.md
# documents under "Build".
.DEFAULT_GOAL := examples

.PHONY: help examples resume letter academic-cv academic-bibliography academic-letter statements check test regression smoke layout review-page-two review-matrix extract-test bibliography-test tagging clean

help: ## List the available targets
	@printf 'CareerDossierTeX make targets:\n\n'
	@grep -E '^[a-z][a-zA-Z_-]*:.*## ' $(MAKEFILE_LIST) \
	  | sed -E 's/^([a-zA-Z_-]+):.*## (.*)/\1|\2/' \
	  | awk -F'|' '{printf "  %-14s %s\n", $$1, $$2}'
	@printf '\n'

examples: resume letter academic-cv academic-bibliography academic-letter statements ## Build every supported example (default)

$(EXAMPLES_BUILD_DIR):
	@mkdir -p $(EXAMPLES_BUILD_DIR)

resume: | $(EXAMPLES_BUILD_DIR) ## Build the résumé example
	$(LATEXMK) $(RESUME)

letter: | $(EXAMPLES_BUILD_DIR) ## Build the cover-letter example
	$(LATEXMK) $(LETTER)

academic-cv: | $(EXAMPLES_BUILD_DIR) ## Build the academic CV example
	$(LATEXMK) $(ACADEMIC_CV)

academic-bibliography: | $(EXAMPLES_BUILD_DIR) ## Build the optional BibLaTeX/Biber CV example
	$(LATEXMK) $(ACADEMIC_BIBLIOGRAPHY)

academic-letter: | $(EXAMPLES_BUILD_DIR) ## Build the academic letter example
	$(LATEXMK) $(ACADEMIC_LETTER)

statements: | $(EXAMPLES_BUILD_DIR) ## Build all six statement examples
	$(LATEXMK) $(STATEMENTS)

check: regression extract-test smoke layout bibliography-test tagging examples ## Run the full supported local suite
	@printf '\nAll suites passed.\n'

test: check ## Alias for check

regression: ## Module regression suite (l3build check on LuaTeX)
	l3build check

smoke: ## Supported builds and required failures
	tests/smoke/run.sh

layout: ## Layout-stress fixtures
	tests/layout/run.sh

review-page-two: ## Render five-family and all statement page-two reviews
	tests/layout/render-page-two.sh

review-matrix: ## Render the 10/11/12pt x normal/narrow reference matrix (#147)
	tests/layout/render-size-margin-matrix.sh

extract-test: ## Text-extraction round-trip against committed baselines
	tests/extraction/run.sh

bibliography-test: ## Biber sorting and identifier-precedence fixture
	tests/bibliography/run.sh

tagging: ## Opt-in tagged-PDF structure fixtures
	tests/tagging/run.sh

clean: ## Remove generated documents, logs, and the l3build sandbox
	-@l3build clean >/dev/null 2>&1
	@rm -rf $(BUILD_DIR)
	@rm -rf tests/tagging/reports
	@rm -f tests/*/*.aux tests/*/*.log tests/*/*.out tests/*/*.pdf \
	       tests/*/*.xdv tests/*/*.fls tests/*/*.fdb_latexmk \
	       tests/*/*.bbl tests/*/*.bcf tests/*/*.blg tests/*/*.run.xml \
	       tests/*/*.diff tests/*/*.stdout
	@printf 'Cleaned generated files. Tracked source and .tlg baselines are untouched.\n'
