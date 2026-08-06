# Makefile — CareerDossierTeX
#
# Build and test commands live here so local workflows and CI can invoke the
# same entry points. When a command is wired into CI, keep both places aligned.
#
# Requirements: LuaLaTeX and latexmk for everything except `lint`, which is
# pure text processing and needs only bash and awk; l3build for `regression`;
# pdftotext (Poppler) for `layout`, `extract-test`, `bibliography-test`,
# `links`, and `tagging`; pdftoppm (Poppler) for `review-page-two`; nothing
# beyond LuaLaTeX for `metadata`, which reads the PDF catalog itself;
# BibLaTeX and Biber for `bibliography-test`, `links`, and
# `academic-bibliography`. `links` skips its two bibliography fixtures with a
# notice when Biber is absent, and says so in its summary.
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

.PHONY: help examples resume letter academic-cv academic-bibliography academic-letter statements check test lint regression smoke layout review-page-two review-matrix extract-test bibliography-test links metadata tagging clean

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

# `lint` runs first: it compiles nothing, finishes in well under a second, and
# what it catches is a source-level omission that every LaTeX-running suite
# below would report as green.
check: lint regression extract-test smoke layout bibliography-test links metadata tagging examples ## Run the full supported local suite
	@printf '\nAll suites passed.\n'

test: check ## Alias for check

lint: ## Static option lint (choice-valued options name their accepted values)
	tests/lint/run.sh

regression: ## Module regression suite (l3build check on LuaTeX)
	l3build check

smoke: ## Supported builds and required failures
	tests/smoke/run.sh

layout: ## Layout-stress fixtures
	tests/layout/run.sh

review-page-two: ## Render five-family and all statement page-two reviews
	tests/layout/render-page-two.sh

review-matrix: ## Render the normal/narrow x 10/11/12pt reference matrix (#147)
	tests/layout/render-size-margin-matrix.sh

extract-test: ## Text-extraction round-trip against committed baselines
	tests/extraction/run.sh

bibliography-test: ## Biber sorting and identifier-precedence fixture
	tests/bibliography/run.sh

links: ## Copy-paste integrity of URLs and e-mail addresses
	tests/links/run.sh

metadata: ## Default-path PDF metadata (/Lang) fixtures
	tests/metadata/run.sh

tagging: ## Opt-in tagged-PDF structure fixtures
	tests/tagging/run.sh

clean: ## Remove generated documents, logs, and the l3build sandbox
	-@l3build clean >/dev/null 2>&1
	@rm -rf $(BUILD_DIR)
	@rm -rf tests/tagging/reports
	@rm -f tests/*/*.aux tests/*/*.log tests/*/*.out tests/*/*.pdf \
	       tests/*/*.xdv tests/*/*.fls tests/*/*.fdb_latexmk \
	       tests/*/*.bbl tests/*/*.bcf tests/*/*.blg tests/*/*.run.xml \
	       tests/*/*.diff tests/*/*.stdout tests/*/*.tokens
	@printf 'Cleaned generated files. Tracked source and .tlg baselines are untouched.\n'
