-- build.lua — l3build configuration for CareerDossierTeX (Phase 1).
--
-- This harness runs the module-level regression suite: each `.lvt` source in
-- tests/regression/ is compiled and its filtered log compared against the saved
-- `.tlg` baseline. The baseline is the assertion, so regenerate one only for an
-- intended, reviewed output change (see CONTRIBUTING.md, "Saving a baseline").
--
--   l3build check              run the whole regression suite
--   l3build check <name>       run one test (name without the .lvt extension)
--   l3build save <name>        (re)save the .tlg baseline for a test
--
-- The layout classes keep their smoke, layout, and extraction runners under
-- tests/; those are shell-driven and are not invoked by l3build.

module = "careerdossier"

-- Handwritten sources live at the repository root; there is no .dtx/.ins unpack
-- step. Copy the packages and classes into the test sandbox so `\usepackage`
-- and `\documentclass` resolve them.
sourcefiledir = "."
sourcefiles   = { "careerdossier-*.sty", "careerdossier-*.cls" }
installfiles  = { "careerdossier-*.sty", "careerdossier-*.cls" }

-- Regression sources and baselines live under tests/regression/; no top-level
-- testfiles/ directory is introduced.
testfiledir = "tests/regression"

-- CareerDossierTeX is LuaLaTeX-only from v0.4.0, so the suite is checked on
-- LuaTeX with the LaTeX format and nothing else.
checkengines = { "luatex" }
stdengine    = "luatex"
checkformat  = "latex"

-- These tests assert token lists and diagnostics, not multi-pass references, so
-- a single compilation per test is enough.
checkruns = 1
