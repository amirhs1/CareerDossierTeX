# Makefile — CareerDossierTeX
#
# Build and test commands live here so local workflows and CI can invoke the
# same entry points. When a command is wired into CI, keep both places aligned.
#
# Requirements: LuaLaTeX and latexmk for everything except `lint`, which is
# pure text processing and needs only bash, awk, and make — all three of its
# scripts, since the second one drives the other runners in their
# compile-nothing `--list` mode and the third exercises check-parallel's
# accounting controls against synthetic workers; l3build for `regression`;
# pdftotext (Poppler) for `layout`, `extract-test`, `bibliography-test`,
# `links`, and `tagging`; pdftoppm (Poppler) for `review-page-two`; nothing
# beyond LuaLaTeX for `metadata` and `annotations`, which read the PDF's own
# catalog and link annotations;
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
# `review-entrymeta-muted` needs only LuaLaTeX: it renders the entry heading's
# two semantic options against each other for visual review and asserts nothing.
#
# `review-pagefill` needs only LuaLaTeX and awk. It measures how full each page
# is by parsing `\tracingpages` output from the log rather than the PDF, which
# is what keeps it free of the poppler dependency the rest of the layout work
# carries.
#
# Scoping a suite while developing (issues #359 and #367). `regression`,
# `smoke`, `layout`, `extract-test`, and `tagging` each accept an optional
# selector, and with no selector run exactly what they ran before — which is
# what `check` and CI invoke, so neither is affected:
#
#   make regression TEST=base-diagnostics     one l3build test, by exact name
#   make smoke      FIXTURE=bad-muted         every fixture matching the pattern
#   make layout     FIXTURE='resume-*'        pattern anchored at the start
#   make extract-test FIXTURE=statement
#   make tagging    FIXTURE=cv-subsection     one tagged-PDF fixture group
#
# `smoke`, `layout`, and `tagging` also take JOBS=N, which composes with
# FIXTURE; see "Fanning out inside a suite" below.
#
# The two spellings are not interchangeable, which is why they are not one name.
# `TEST` is passed through to `l3build check <name>`, which takes an exact test
# name. `FIXTURE` is a shell glob matched anywhere in a fixture's basename, so a
# plain word behaves as a substring search. A `FIXTURE` pattern matching nothing
# fails the run rather than reporting a clean one; `tests/<suite>/run.sh --list`
# prints the available names and compiles nothing.
#
# `tagging` selects by fixture *group* rather than by file: its 12 groups are
# backed by 37 .tex files, because a group's `-untagged` and `-ua2` companions
# are checked against the base fixture and mean nothing apart from it.
#
# `resume`, `letter`, `academic-cv`, `academic-bibliography`, `academic-letter`,
# and `statements` write their PDFs, logs, and other latexmk output under the
# gitignored $(BUILD_DIR)/examples/ rather than beside the tracked example
# sources, so the source tree never picks up untracked build artifacts.
#
# Running the full suite faster (issue #378). `check` stays serial: it is the
# pre-push gate and the CI-aligned entry point, and a gate whose result depends
# on scheduling is not a gate. `check-parallel` is the opt-in fast path for the
# one full run before a push:
#
#   make check                  serial, deterministic, what CI runs
#   make check-parallel         the same targets, four at a time
#   make check-parallel JOBS=8  the same targets, eight at a time
#
# Both dispatch $(CHECK_TARGETS) and cannot drift apart, because that variable
# is the only place the list exists; `check-targets` prints it for the driver,
# and `make lint` asserts that `check` still expands it. The driver is
# tests/check-parallel.sh, which explains what it adds beyond running the same
# eleven targets — an accounting assertion and a font-cache proof, both of which
# exist because a run that reports green without doing the work is this
# repository's characteristic failure. It is not `make -j`: GNU make 3.81, which
# is what macOS ships, has no `--output-sync`, so under `-j` the eleven suites
# interleave and "which suite failed" stops being answerable.
#
# Fanning out inside a suite (issue #390). `smoke`, `layout`, and `tagging`
# additionally take JOBS=N, which runs that many of their own fixtures at once:
#
#   make smoke JOBS=4           four fixtures in flight
#   make layout JOBS=8 FIXTURE='resume-*'
#
# With no JOBS each runs exactly what it ran before, in the same order, with
# byte-identical output — so `check` and CI are untouched. The shared dispatcher
# is tests/lib/fanout.sh; the assertion that earns it is that a fixture leaving
# no verdict fails the run by name rather than shrinking the denominator.
#
# The two layers multiply, so `check-parallel` pins the inner one. Every target
# it dispatches is given an explicit JOBS, defaulting to 1, because a
# command-line JOBS lands in MAKEFLAGS and every sub-make would otherwise
# inherit it — four targets each fanning out four fixtures being sixteen
# LuaLaTeX processes nobody asked for. Raise it deliberately:
#
#   make check-parallel JOBS=4 INNER_JOBS=2    process budget 4 x 2 = 8
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

.PHONY: help examples resume letter academic-cv academic-bibliography academic-letter statements check check-parallel check-targets test lint regression smoke layout review-page-two review-matrix review-entrymeta-muted review-link-decoration review-linebreak review-linebreak-parallel review-pagefill extract-test bibliography-test links metadata annotations tagging clean

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

# The suite list, in the order `check` runs it. It lives in one variable
# because two entry points now dispatch it — `check` serially and
# `check-parallel` concurrently — and a hand-maintained second copy is how the
# `annotations` suite once dropped out of a run that was then reported clean.
#
# `lint` runs first: it compiles nothing, finishes in well under a second, and
# what it catches is a source-level omission that every LaTeX-running suite
# below would report as green.
CHECK_TARGETS := lint regression extract-test smoke layout bibliography-test \
                 links metadata annotations tagging examples

check: $(CHECK_TARGETS) ## Run the full supported local suite
	@printf '\nAll suites passed.\n'

# Not in `help`: an implementation detail of check-parallel, not a target a
# contributor invokes. It exists so the driver reads the list make expands
# rather than a copy of it.
check-targets:
	@printf '%s\n' $(CHECK_TARGETS)

check-parallel: ## Opt-in: check's targets concurrently, JOBS=N (the gate is still serial check)
	tests/check-parallel.sh $(if $(JOBS),--jobs $(JOBS)) \
	  $(if $(INNER_JOBS),--inner-jobs $(INNER_JOBS))

test: check ## Alias for check

lint: ## Static lint: option values, the fixture-selection contract, and the check-parallel controls
	tests/lint/run.sh
	tests/lint/run-fixture-filter.sh
	tests/check-parallel.sh --self-test

regression: ## Module regression suite (l3build check); TEST=<name> runs one test
	l3build check $(TEST)

smoke: ## Supported builds and required failures; FIXTURE=<pattern> scopes it, JOBS=N fans out
	tests/smoke/run.sh $(if $(JOBS),--jobs $(JOBS)) "$(FIXTURE)"

layout: ## Layout-stress fixtures; FIXTURE=<pattern> scopes it, JOBS=N fans out
	tests/layout/run.sh $(if $(JOBS),--jobs $(JOBS)) "$(FIXTURE)"

review-page-two: ## Render five-family and all statement page-two reviews
	tests/layout/render-page-two.sh

review-matrix: ## Render the normal/narrow x 10/11/12pt reference matrix (#147)
	tests/layout/render-size-margin-matrix.sh

review-entrymeta-muted: ## Render the column/inline x italic/gray/both/plain matrix (#230, #324)
	tests/layout/render-entrymeta-muted-matrix.sh

review-link-decoration: ## Render the print/screen link-decoration pair (#278)
	tests/layout/render-link-decoration.sh

review-linebreak: ## Sweep a line-breaking parameter over both corpora (#316)
	tests/layout/sweep-linebreak.sh $(SWEEP_ARGS)

review-linebreak-parallel: ## review-linebreak with one sweep per value in parallel (#316)
	tests/layout/sweep-linebreak-parallel.sh $(SWEEP_ARGS)

review-pagefill: ## Report page fill and the atom forcing each break (#334)
	tests/layout/report-pagefill.sh

extract-test: ## Extraction round-trip vs baselines; FIXTURE=<pattern> scopes it
	tests/extraction/run.sh "$(FIXTURE)"

bibliography-test: ## Biber sorting and identifier-precedence fixture
	tests/bibliography/run.sh

links: ## Copy-paste integrity of URLs and e-mail addresses
	tests/links/run.sh

metadata: ## Default-path PDF metadata (/Lang) fixtures
	tests/metadata/run.sh

annotations: ## Link-annotation action types (/S/URI, never /S/GoToR)
	tests/annotations/run.sh

tagging: ## Opt-in tagged-PDF structure fixtures; FIXTURE=<pattern> scopes it, JOBS=N fans out
	tests/tagging/run.sh $(if $(JOBS),--jobs $(JOBS)) "$(FIXTURE)"

clean: ## Remove generated documents, logs, and the l3build sandbox
	-@l3build clean >/dev/null 2>&1
	@rm -rf $(BUILD_DIR)
	@rm -rf tests/tagging/reports
	@rm -f tests/*/*.aux tests/*/*.log tests/*/*.out tests/*/*.pdf \
	       tests/*/*.xdv tests/*/*.fls tests/*/*.fdb_latexmk \
	       tests/*/*.bbl tests/*/*.bcf tests/*/*.blg tests/*/*.run.xml \
	       tests/*/*.diff tests/*/*.stdout tests/*/*.tokens tests/*/*.guard \
	       tests/*/*.got
	@printf 'Cleaned generated files. Tracked source and .tlg baselines are untouched.\n'
