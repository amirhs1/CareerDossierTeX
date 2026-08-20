# Makefile — CareerDossierTeX
#
# Build and test commands live here so local workflows and CI can invoke the
# same entry points. When a command is wired into CI, keep both places aligned.
#
# Requirements: LuaLaTeX and latexmk for everything except `lint`, which is
# pure text processing and needs only bash, awk, and make across all eleven of
# its scripts — with one exception, the harness lint, which needs shellcheck
# and fails rather than skipping without it. The `lint` recipe below is the
# list of those eleven, and the ones whose inputs are least obvious from their
# names read text too — run-fixture-filter.sh drives the other runners in
# their compile-nothing `--list` mode, run-agents-references.sh reads three
# Markdown files, run-manual-names.sh reads doc/careerdossier.tex and
# README.md, run-token-values.sh reads careerdossier-tokens.sty against the
# value tables in docs/ARCHITECTURE.md and the manual,
# run-text-guards.sh drives tests/lib/text.sh over synthetic text,
# and check-parallel.sh --self-test exercises check-parallel's accounting
# controls against synthetic workers.
#
# Beyond `lint`: l3build for `regression`;
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
# Running the full suite (issues #378, #390, #399). `check` is the pre-push gate
# and runs its twelve targets four at a time. The serial path survives under its
# own name:
#
#   make check                  the gate: twelve targets, four at a time
#   make check JOBS=2           the same targets, two at a time
#   make check-serial           one target after another, deterministic
#
# The gate was serial until #399 on the argument that it is the CI-aligned entry
# point. What CI is aligned to is the target set and the commands, not the
# scheduling: .github/workflows/build.yml runs seventeen jobs on seventeen runners
# with no `needs:` anywhere, so local serial `check` was the one execution model
# nothing else here used. Both paths dispatch $(CHECK_TARGETS) through the same
# `make <target>` invocations, so that alignment is unchanged.
#
# JOBS defaults to 4 because 4 is the fastest value measured green: serial 439 s,
# JOBS=2 285 s, JOBS=4 211 s, all green, against JOBS=8 at 168-201 s and 4 red in
# 8 clean-tree runs. Every one of those failures was a text-extraction assertion
# against a document that is provably correct — a guard that reported present
# text as missing under load (#398).
#
# #398 is fixed (PR #403, `9bfc6d4`, the commit immediately after the one that
# first wrote this paragraph): the extracted-text guards now answer three
# states, and JOBS=8 then ran 5 green of 5 at 162-186 s. The sentence this
# paragraph used to carry — that 8 is "unusable until that is fixed" — has been
# false ever since, and the 24% is no longer blocked by a defect.
#
# The default is still 4, for a different and weaker reason: nothing has
# measured 8 over enough runs to set a default from. Five green runs are not
# that campaign; 4-red-in-8 above is exactly what a handful of green runs looks
# like before the flaky half arrives. The campaign also wants a machine with
# more cores than the maintainer's, so it is unrun rather than merely
# unscheduled, and raising the default is not a decision this repository can
# currently take on its own evidence.
#
# So 8 is unjustified, not barred. `make check JOBS=8` is a supported thing to
# run on hardware that has the cores; the default stays 4 until someone with
# that hardware runs the campaign and reports it.
#
# Both entry points dispatch $(CHECK_TARGETS) and cannot drift apart, because
# that variable is the only place the list exists; `check-targets` prints it for
# the driver, and `make lint` asserts that the two would dispatch the same set.
# The driver is tests/check-parallel.sh, which explains what it adds beyond
# running the same twelve targets — an accounting assertion and a font-cache
# proof, both of which exist because a run that reports green without doing the
# work is this repository's characteristic failure. It is not `make -j`: GNU make
# 3.81, which is what macOS ships, has no `--output-sync`, so under `-j` the
# twelve suites interleave and "which suite failed" stops being answerable.
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
# The two layers multiply, so `check` pins the inner one. Every target it
# dispatches is given an explicit JOBS, defaulting to 1, because a command-line
# JOBS lands in MAKEFLAGS and every sub-make would otherwise inherit it — four
# targets each fanning out four fixtures being sixteen LuaLaTeX processes nobody
# asked for. That pinning is why making the gate parallel did not multiply the
# process budget as a side effect. Raise it deliberately:
#
#   make check JOBS=4 INNER_JOBS=2             process budget 4 x 2 = 8
#
# Run `make help` for the target list.

BUILD_DIR        := build
EXAMPLES_BUILD_DIR := $(BUILD_DIR)/examples
MANUAL_BUILD_DIR := $(BUILD_DIR)/manual
LATEXMK       := latexmk -lualatex -interaction=nonstopmode -halt-on-error \
                 -output-directory=$(EXAMPLES_BUILD_DIR)
MANUAL_LATEXMK := latexmk -lualatex -interaction=nonstopmode -halt-on-error \
                 -output-directory=$(MANUAL_BUILD_DIR)
MANUAL        := doc/careerdossier.tex
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

.PHONY: help examples resume letter academic-cv academic-bibliography academic-letter statements manual ctan check check-serial check-parallel check-targets test lint ctan-lint regression smoke layout review-page-two review-matrix review-entrymeta-muted review-link-decoration review-linebreak review-linebreak-parallel review-pagefill review-spacing extract-test bibliography-test links metadata annotations tagging clean

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

$(MANUAL_BUILD_DIR):
	@mkdir -p $(MANUAL_BUILD_DIR)

# The PDF manual CTAN requires, built from its own committed source. The PDF is
# a build artifact like every other one here and is not tracked; `l3build ctan'
# is what puts it in the release archive (#264).
manual: | $(MANUAL_BUILD_DIR) ## Build the PDF manual into $(MANUAL_BUILD_DIR)/
	$(MANUAL_LATEXMK) $(MANUAL)

# The CTAN release archive (#264). Configuration lives in build.lua; this is
# only the entry point, so that the command is discoverable from `make help'
# like every other one and nobody has to remember the l3build spelling.
#
# It is not part of `check'. `l3build ctan' runs the regression suite itself and
# then typesets the 40-page manual three times, so putting it in the gate would
# pay for both again on every run to assert something that only matters at
# release time. docs/RELEASE-CHECKLIST.md is where it is called for; what the
# gate carries instead is tests/lint/run-ctan-config.sh, which checks the
# configuration without building anything.
#
# Two artifacts land outside $(BUILD_DIR) because l3build puts them there:
# careerdossier-ctan.zip at the repository root, and the typeset manual at
# doc/careerdossier.pdf beside its source. Both are already ignored by
# .gitignore, and `l3build clean' -- which `clean' below runs first -- removes
# both.
ctan: ## Build the CTAN release archive; runs l3build check first
	l3build ctan

# The suite list, in the order both entry points run it. It lives in one
# variable because two of them dispatch it — `check` concurrently and
# `check-serial` one at a time — and a hand-maintained second copy is how the
# `annotations` suite once dropped out of a run that was then reported clean.
#
# `lint` runs first, and dispatch order still matters now that the gate is
# parallel: it compiles nothing, finishes in well under a second, and what it
# catches is a source-level omission that every LaTeX-running suite below would
# report as green. Sorting this list longest-first models a further ~50 s at
# JOBS=4 and was rejected under #399 — it would sort the transcript too, since
# the replay follows dispatch order, and push `lint` from first to last.
CHECK_TARGETS := lint ctan-lint regression extract-test smoke layout \
                 bibliography-test links metadata annotations tagging examples

check: ## Run the full supported local suite — the gate; JOBS=N sets the workers
	tests/check-parallel.sh $(if $(JOBS),--jobs $(JOBS)) \
	  $(if $(INNER_JOBS),--inner-jobs $(INNER_JOBS))

# The serial path, kept because a deterministic run is worth having when a
# parallel one reports something surprising: it removes scheduling as a variable
# in one command. It is also the prerequisite list `make lint` reads the target
# set from, so it is load-bearing beyond being an alternative.
check-serial: $(CHECK_TARGETS) ## check's targets one after another, deterministic
	@printf '\nAll suites passed.\n'

# Not in `help`: an implementation detail of the driver, not a target a
# contributor invokes. It exists so the driver reads the list make expands
# rather than a copy of it.
check-targets:
	@printf '%s\n' $(CHECK_TARGETS)

check-parallel: check ## Alias of check, which is parallel by default since #399

test: check ## Alias for check

lint: ## Static lint: option values, version declarations, fixture selection, AGENTS.md pointers, Markdown anchors, manual names, manual examples, documented token values, text guards, shellcheck over the harness, and the check-parallel controls
	tests/lint/run.sh
	tests/lint/run-version-declarations.sh
	tests/lint/run-fixture-filter.sh
	tests/lint/run-agents-references.sh
	tests/lint/run-markdown-anchors.sh
	tests/lint/run-manual-names.sh
	tests/lint/run-manual-examples.sh
	tests/lint/run-token-values.sh
	tests/lint/run-text-guards.sh
	tests/lint/run-shellcheck.sh
	tests/check-parallel.sh --self-test

regression: ## Module regression suite (l3build check); TEST=<name> runs one test
	l3build check $(TEST)

# Deliberately not part of `lint'. Every other script in that slot reads text
# and needs no TeX, which is why the CI `lint' job runs on a bare runner rather
# than pulling the TeX Live container. This one loads build.lua under `texlua'
# to read the version l3build would publish -- a value build.lua derives and no
# grep can see -- so it belongs with the targets that have an interpreter. Its
# CI cover is a step of the `regression' job, which already loads build.lua.
ctan-lint: ## Check build.lua's CTAN packaging configuration (needs texlua)
	tests/lint/run-ctan-config.sh

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

# Two runners, deliberately. report.sh measures \vbox fixtures and so names
# every boundary by construction; report-pages.sh walks a real shipped page and
# so reaches the identity stack and the letterhead, which no \vbox can hold, but
# can only name a boundary by the text on either side. Where both reach the same
# gap they must agree, which is the cross-check between them.
review-spacing: ## Report the structural and visible gap at every boundary (#417)
	tests/spacing/report.sh
	tests/spacing/report-pages.sh

extract-test: ## Extraction round-trip vs baselines; FIXTURE=<pattern> scopes it
	tests/extraction/run.sh "$(FIXTURE)"

bibliography-test: ## Biber sorting and identifier-precedence fixture
	tests/bibliography/run.sh

links: ## Copy-paste integrity of URLs and e-mail addresses
	tests/links/run.sh

metadata: ## Default-path PDF metadata (/Lang), and /Title and /Author across both paths
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
