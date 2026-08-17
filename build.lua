-- build.lua — l3build configuration for CareerDossierTeX (Phase 1).
--
-- This harness runs the module-level regression suite: each `.lvt` source in
-- tests/regression/ is compiled and its filtered log compared against the saved
-- `.tlg` baseline. The baseline is the assertion, so regenerate one only for an
-- intended, reviewed output change (see docs/TESTING.md, "Baselines are
-- load-bearing").
--
--   l3build check              run the whole regression suite
--   l3build check <name>       run one test (name without the .lvt extension)
--   l3build save <name>        (re)save the .tlg baseline for a test
--
-- The layout classes keep their smoke, layout, and extraction runners under
-- tests/; those are shell-driven and are not invoked by l3build.
--
-- It also configures the CTAN release archive (#264):
--
--   l3build ctan               build build/distrib/ctan/ and careerdossier-ctan.zip
--   make ctan                  the same, through the repository's entry point
--
-- `l3build ctan' runs `check' first and skips the zip stage when it fails, so
-- an archive only exists for a tree that passed the regression suite. It does
-- not run the shell-driven suites; `make check' is still the gate.
--
-- Nothing here uploads. `AGENTS.md' rule 11 reserves release publication to the
-- maintainer, and `uploadconfig' below deliberately omits the one mandatory
-- field that would let `l3build upload' complete unattended.

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

-- ---------------------------------------------------------------------------
-- CTAN packaging (#264)
-- ---------------------------------------------------------------------------

-- The release the archive publishes, read out of the Work rather than restated
-- here.
--
-- `uploadconfig.version' is a version string, and ten `\ProvidesExpl*' lines
-- already carry one. Writing an eleventh copy by hand would reintroduce exactly
-- the drift tests/lint/run-version-declarations.sh (#258) exists to catch, one
-- file outside the set that lint reads: `manifest.txt' defines the Work, and
-- build.lua is not part of it, so a stale literal here would ship a wrong
-- version in an archive every suite passed. Deriving it removes the defect
-- instead of detecting it.
--
-- careerdossier-base.sty is the file every other one loads, and the #258 lint
-- holds all ten declarations equal, so any of them would do. Parse failure is
-- an error, not a silent "": l3build loads this file for `check' too, so a
-- broken derivation fails `make regression' rather than waiting for a release.
local function work_release()
  local path = sourcefiledir .. "/careerdossier-base.sty"
  local source = assert(io.open(path, "r"),
    "build.lua: cannot read " .. path .. " to derive the release version")
  local date, version
  for line in source:lines() do
    -- Comment lines are skipped for the reason the #258 lint skips them: prose
    -- quoting a declaration must not be able to satisfy the check.
    if not line:match("^%s*%%") then
      local d, v = line:match(
        "\\ProvidesExplPackage%s*{[^{}]*}%s*{%s*([^{}]-)%s*}%s*{%s*([^{}]-)%s*}")
      if d then
        date, version = d, v
        break
      end
    end
  end
  source:close()
  -- The date is parsed but not published: CTAN's upload form has no date field.
  -- It is asserted anyway, because matching the whole { name } { date }
  -- { version } triple is what makes the third brace group the version rather
  -- than whatever else a malformed line put there.
  assert(version and version ~= "" and date and date ~= "",
    "build.lua: no parseable \\ProvidesExplPackage date and version in " .. path)
  return version
end

local release_version = work_release()

-- One top-level directory named for the package, which is what CTAN requires of
-- the archive. `module' already carries the name; stated again because this is
-- the value the requirement is about, and `careerdossier' was confirmed free on
-- CTAN (see docs/RELEASE-CHECKLIST.md, "Name and filename availability").
ctanpkg    = "careerdossier"
ctanreadme = "README.md"

-- The manual and its source. CTAN requires "PDF documentation together with its
-- source", and doc/careerdossier.tex is the source; the PDF is a build artifact
-- and is not tracked, so the archive is the only place both appear together.
--
-- `typesetfiles' carries both. l3build typesets each entry, derives `pdffiles'
-- from the same list, and copies the source and the PDF into the archive, so
-- naming careerdossier.tex in `docfiles' as well would only copy it twice.
-- `docfiles' is therefore empty on purpose rather than by default.
docfiledir   = "doc"
typesetfiles = { "careerdossier.tex" }
docfiles     = { }

-- The manual is LuaLaTeX-only like everything else here: it loads fontspec and
-- sets TeX Gyre fonts by name, so l3build's pdflatex default cannot build it.
-- Three runs settle the table of contents and hyperref's anchors, which is
-- l3build's default and the same count `make manual' reaches through latexmk.
typesetexe  = "lualatex"
typesetopts = "-interaction=nonstopmode -halt-on-error"
typesetruns = 3

-- Plain-text files that sit at the top level of the archive. Named explicitly:
-- the default is `{"*.md", "*.txt"}', which at this repository's root would also
-- sweep in CONTRIBUTING.md, AGENTS.md, CLAUDE.md, and AI-POLICY.md — files that
-- address contributors to this repository, not users of the package.
--
-- README.md carries the licence statement and version identifier CTAN requires
-- of it; LICENSE is the LPPL text; manifest.txt is what defines the Work, and
-- every source file's licence notice points at it, so the archive is incomplete
-- without it.
textfiles = { "README.md", "LICENSE", "CHANGELOG.md", "manifest.txt" }

-- Keep the archive's directory layout the same as the repository's, so
-- doc/careerdossier.tex and doc/careerdossier.pdf sit together in doc/ and the
-- ten Work files stay at the top level beside the README. With l3build's
-- default the manual's source would be flattened in among the .sty and .cls
-- files, which reads as though it were one of them.
flatten = false

-- No .tds.zip. TDS packaging is optional, and this package installs as ten
-- files into tex/latex/careerdossier/ with no scripts, fonts, or generated
-- assets to place — CTAN's own installers derive that tree from the archive
-- without help. Set rather than left to l3build's default so that the decision
-- is recorded where the value is (docs/RELEASE-CHECKLIST.md, "TDS packaging").
packtdszip = false

-- CTAN upload metadata. `l3build upload' is not run here and must not be:
-- AGENTS.md rule 11 reserves release publication to the maintainer, and a CTAN
-- upload cannot be withdrawn the way a GitHub release can.
--
-- `email' is absent deliberately. CTAN requires a reachable address for the
-- uploader, this repository publishes only a GitHub noreply address, and the
-- field is mandatory — so an upload cannot complete by accident from a checkout
-- alone. The maintainer supplies it at upload time with
-- `l3build upload --email <address>', without editing this file.
uploadconfig = {
  pkg      = ctanpkg,
  version  = release_version,
  author   = "Amir Sadeghi",
  uploader = "Amir Sadeghi",
  license  = "lppl1.3c",
  summary  = "A reusable LuaLaTeX toolkit for consistent career documents",
  -- LuaLaTeX-only packages are filed under macros/luatex/latex rather than
  -- macros/latex/contrib: careerdossier-typography.sty errors on any other
  -- engine, so the package cannot be used from a pdfLaTeX or XeLaTeX document.
  -- Confirmed 2026-08-17 against ctan.org/pkg/lua-ul, which is filed there for
  -- the same reason. CTAN staff may still reassign the path on upload.
  ctanPath = "/macros/luatex/latex/careerdossier",
  -- Slugs confirmed 2026-08-17 against ctan.org/topic/cv and /topic/letter.
  topic      = { "cv", "letter", "class" },
  home       = "https://github.com/amirhs1/CareerDossierTeX",
  repository = "https://github.com/amirhs1/CareerDossierTeX",
  bugtracker = "https://github.com/amirhs1/CareerDossierTeX/issues",
  support    = "https://github.com/amirhs1/CareerDossierTeX/issues",
  -- A first upload, not an update. Flip this at the first revision.
  update = false,
  description = [[
CareerDossierTeX produces a resume, cover letter, academic CV, and seven types
of academic statement from one shared profile file, so that names, contact
details, links, and visual styling stay consistent across a set of application
documents.

The toolkit is six packages and four document classes sharing one calibrated
system of type, rhythm, list, and geometry tokens. Output is single-column and
plain-text-extractable by design, the semantic structure is available to
assistive technology through an opt-in tagged-PDF path, and a BibLaTeX/Biber
integration for publication lists is optional.

LuaLaTeX is the only supported engine; other engines stop with an explicit
error.
]],
}
