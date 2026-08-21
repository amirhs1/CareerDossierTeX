-- ctan-config.lua — the CTAN packaging configuration in build.lua (#264)
--
-- Run through tests/lint/run-ctan-config.sh, which is what `make lint' calls.
-- This file is the checker; the shell script is the driver, and only because
-- every other lint here is invoked that way.
--
-- WHAT THIS ASSERTS
--
-- That `l3build ctan' would package the right files under the right name at the
-- right version. Six checks, listed in audit() below.
--
-- WHY A LINT AND NOT THE ARCHIVE ITSELF
--
-- `l3build ctan' is not a check that can fail on this. Its file lists are
-- globs, and a glob that matches nothing is not an error -- it contributes no
-- files and the run reports success. Drop `README.md' from `textfiles', or
-- misspell `careerdossier.tex' in `typesetfiles', and l3build builds an archive
-- with no README or no manual, exits 0, and says so in no output anyone reads.
-- The two CTAN requirements most likely to be violated that way are the two
-- CTAN checks for on receipt: a top-level README carrying a licence and a
-- version, and PDF documentation together with its source.
--
-- Running the real thing would not help either, and not only because it
-- typesets the whole manual and runs the regression suite first. What it
-- produces is an archive; nothing compares that archive to what the archive was
-- supposed to contain. This does, from the two files that already know --
-- `manifest.txt', which defines the Work, and a Work file's own
-- `\ProvidesExpl*' declaration.
--
-- WHY IT LOADS build.lua RATHER THAN READING IT
--
-- Because the version is not in the text. build.lua derives it from
-- careerdossier-base.sty precisely so that no eleventh copy exists to go stale
-- (see the comment there), which means a grep can see the derivation but not
-- its result. Loading the file is how the value l3build would publish becomes
-- available to compare, and it is also, incidentally, a syntax check.
--
-- Loading is safe: build.lua assigns configuration and reads one file. It does
-- not run LaTeX, spawn anything, or write. The l3build variable defaults are
-- deliberately *not* loaded first, which is what makes check 5 possible -- a
-- setting build.lua never made is nil here, and distinguishable from the same
-- value arrived at by default.
--
-- HOW IT AVOIDS PASSING BY FINDING NOTHING
--
-- audit() takes the configuration as an argument and returns the set of checks
-- that failed, so the self-check at the bottom can re-run it over a deliberately
-- broken copy. One mutation per check, each expecting its own key back: a
-- checker that stopped detecting a wrong version, a missing file, a defaulted
-- `packtdszip', a renamed package, or a Work file left out of the archive fails
-- there rather than reporting a clean tree.
--
-- Requirements: texlua, which ships with the TeX Live that `l3build' itself
-- needs. It compiles nothing and runs in the sub-second `lint' slot.

local ok_exit = 0

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function file_exists(path)
  local handle = io.open(path, "r")
  if not handle then return false end
  handle:close()
  return true
end

local function read_lines(path)
  local handle = io.open(path, "r")
  if not handle then return nil end
  local lines = {}
  for line in handle:lines() do lines[#lines + 1] = line end
  handle:close()
  return lines
end

-- A glob as l3build understands it, as a Lua pattern. Only `*' and `?' are
-- used in this repository's file lists; every other character is escaped so
-- that the `-' and `.' in `careerdossier-base.sty' cannot act as pattern
-- operators.
local function glob_to_pattern(glob)
  local pattern = glob:gsub("[%^%$%(%)%%%.%[%]%+%-]", "%%%0")
  pattern = pattern:gsub("%*", ".*"):gsub("%?", ".")
  return "^" .. pattern .. "$"
end

local function matches_any(name, globs)
  for _, glob in ipairs(globs or {}) do
    if name:match(glob_to_pattern(glob)) then return true end
  end
  return false
end

local function is_glob(name)
  return name:match("[%*%?]") ~= nil
end

-- The .sty and .cls filenames manifest.txt lists under "The Work". The section
-- runs from the heading to the underline of whichever heading follows it, its
-- own underline being stepped over rather than read as a terminator -- the same
-- shape tests/lint/run-version-declarations.sh parses, for the same file.
local function manifest_work(path)
  local lines = read_lines(path)
  if not lines then return nil end
  local work, inwork, underline = {}, false, false
  for _, line in ipairs(lines) do
    if not inwork then
      if line:match("^The Work%s*$") then inwork, underline = true, true end
    elseif line:match("^%-%-%-") then
      if underline then underline = false else break end
    else
      local first = line:match("^(%S+)")
      if first and (first:match("%.sty$") or first:match("%.cls$")) then
        work[#work + 1] = first
      end
    end
  end
  return work
end

-- The { date } { version } a Work file declares to LaTeX. Comment lines are
-- skipped so that prose quoting a declaration cannot satisfy the check.
local function declared_release(path)
  local lines = read_lines(path)
  if not lines then return nil end
  for _, line in ipairs(lines) do
    if not line:match("^%s*%%") then
      local date, version = line:match(
        "\\ProvidesExpl%a+%s*{[^{}]*}%s*{%s*([^{}]-)%s*}%s*{%s*([^{}]-)%s*}")
      if date then return version, date end
    end
  end
  return nil
end

-- ---------------------------------------------------------------------------
-- the audit
-- ---------------------------------------------------------------------------

-- Returns an ordered list of { key, detail } for every check that failed, and a
-- parallel list of the lines to print. `cfg' is a plain table so that the
-- self-check can hand in a broken copy.
local function audit(cfg)
  local failures, report = {}, {}

  local function verdict(key, ok, detail)
    report[#report + 1] = { key = key, ok = ok, detail = detail }
    if not ok then failures[#failures + 1] = key end
  end

  -- 1. One top-level directory, named for the package. CTAN requires the name;
  --    `module' is the name l3build already knows this bundle by, and the two
  --    disagreeing would put the archive's directory under a name nothing else
  --    in the tree uses.
  do
    local name = cfg.ctanpkg
    if type(name) ~= "string" or name == "" then
      verdict("ctanpkg", false, "ctanpkg is not set; the archive's top-level directory would be unnamed")
    elseif name ~= cfg.module then
      verdict("ctanpkg", false,
        "ctanpkg is '" .. name .. "' but module is '" .. tostring(cfg.module) .. "'; they name the same package and must agree")
    elseif not name:match("^[a-z][a-z0-9%-]*$") then
      verdict("ctanpkg", false,
        "ctanpkg '" .. name .. "' is not a plain lower-case CTAN package name")
    else
      verdict("ctanpkg", true, name)
    end
  end

  -- 2. The version the archive publishes is the Work's.
  --
  --    Read from careerdossier-statement.cls, deliberately not from the file
  --    build.lua derives from: comparing the derivation against its own source
  --    would assert nothing. The #258 lint holds all ten declarations equal, so
  --    any Work file is the Work's version, and this one crossing the other
  --    makes a broken or bypassed derivation visible here.
  do
    local published = cfg.uploadconfig and cfg.uploadconfig.version
    local declared = declared_release(cfg.root .. "/careerdossier-statement.cls")
    if not declared then
      verdict("version", false,
        "no \\ProvidesExplClass declaration could be read from careerdossier-statement.cls, so there is nothing to compare the published version against")
    elseif type(published) ~= "string" or published == "" then
      verdict("version", false,
        "uploadconfig.version is not set; the Work declares " .. declared)
    elseif published ~= declared then
      verdict("version", false,
        "uploadconfig.version is " .. published .. " but the Work declares " ..
        declared .. "; the archive would ship a version no source file claims")
    else
      verdict("version", true, published .. " (matches the Work)")
    end
  end

  -- 3. Every literal filename in a file list exists.
  --
  --    A glob that matches nothing is silently empty, so a missing or misspelt
  --    entry costs the archive a file and costs the run no error. Globs are
  --    skipped here and covered by check 6, which knows what they have to
  --    match.
  do
    local missing = {}
    local lists = {
      { dir = cfg.textfiledir, names = cfg.textfiles,    label = "textfiles" },
      { dir = cfg.docfiledir,  names = cfg.typesetfiles, label = "typesetfiles" },
      { dir = cfg.docfiledir,  names = cfg.docfiles,     label = "docfiles" },
    }
    local checked = 0
    for _, list in ipairs(lists) do
      for _, name in ipairs(list.names or {}) do
        if not is_glob(name) then
          checked = checked + 1
          local path = cfg.root .. "/" .. list.dir .. "/" .. name
          if not file_exists(path) then
            missing[#missing + 1] = list.label .. " names " .. list.dir .. "/" .. name
          end
        end
      end
    end
    if checked == 0 then
      verdict("files", false,
        "no literal filename was checked; the file lists are empty or all globs, and this check would pass whatever they said")
    elseif #missing > 0 then
      verdict("files", false, table.concat(missing, "; "))
    else
      verdict("files", true, checked .. " named files, all present")
    end
  end

  -- 4. What CTAN looks for on receipt is actually in a list.
  --
  --    A top-level README carrying a licence and a version, the licence text,
  --    and PDF documentation together with its source. The PDF is not named
  --    anywhere: l3build derives it from `typesetfiles', so the source being in
  --    that list is what puts both in the archive, and naming it in `docfiles'
  --    instead would ship the source without the PDF.
  do
    local problems = {}
    local readme = cfg.ctanreadme
    if type(readme) ~= "string" or not readme:lower():match("^readme") then
      problems[#problems + 1] =
        "ctanreadme is '" .. tostring(readme) .. "', which CTAN would not accept as the top-level README"
    elseif not matches_any(readme, cfg.textfiles) then
      problems[#problems + 1] =
        "ctanreadme is " .. readme .. " but no textfiles entry carries it into the archive"
    end
    if not matches_any("LICENSE", cfg.textfiles) then
      problems[#problems + 1] = "no textfiles entry carries the LICENSE text"
    end
    if not matches_any("manifest.txt", cfg.textfiles) then
      problems[#problems + 1] =
        "no textfiles entry carries manifest.txt, which defines the Work every source file's licence notice points at"
    end
    local manual = false
    for _, name in ipairs(cfg.typesetfiles or {}) do
      if name:match("%.tex$") then manual = true end
    end
    if not manual then
      problems[#problems + 1] =
        "no .tex source in typesetfiles, so the archive would carry no PDF documentation and no source for it"
    end
    if #problems > 0 then
      verdict("contents", false, table.concat(problems, "; "))
    else
      verdict("contents", true, "README, licence, manifest, and manual source all carried")
    end
  end

  -- 5. `packtdszip' was decided, not defaulted.
  --
  --    l3build's own default is false, so the value alone cannot distinguish a
  --    decision from a shrug. This file is loaded without l3build's variable
  --    defaults for exactly this reason: unset is nil here, and nil is the
  --    failure. The reason for whichever boolean it is belongs in
  --    docs/RELEASE-CHECKLIST.md.
  do
    if type(cfg.packtdszip) ~= "boolean" then
      verdict("packtdszip", false,
        "packtdszip is " .. tostring(cfg.packtdszip) ..
        "; set it explicitly, and record the reason in docs/RELEASE-CHECKLIST.md")
    else
      verdict("packtdszip", true, tostring(cfg.packtdszip) .. " (set explicitly)")
    end
  end

  -- 6. Every file of the Work reaches the archive.
  --
  --    `sourcefiles' is two globs. A new module lands in manifest.txt, in
  --    docs/ARCHITECTURE.md, and in the version lint, and if it were ever named
  --    outside the careerdossier-* pattern it would land in no archive at all,
  --    silently. This is the check that would notice.
  do
    local work = manifest_work(cfg.root .. "/manifest.txt")
    if not work or #work == 0 then
      verdict("work", false,
        "no Work files could be read from manifest.txt, so nothing was compared against sourcefiles")
    else
      local unpackaged = {}
      for _, name in ipairs(work) do
        if not matches_any(name, cfg.sourcefiles) then
          unpackaged[#unpackaged + 1] = name
        elseif not file_exists(cfg.root .. "/" .. cfg.sourcefiledir .. "/" .. name) then
          unpackaged[#unpackaged + 1] = name .. " (listed and matched, but absent)"
        end
      end
      if #unpackaged > 0 then
        verdict("work", false,
          "manifest.txt lists these under \"The Work\" but sourcefiles would not put them in the archive: " ..
          table.concat(unpackaged, ", "))
      else
        verdict("work", true, #work .. " Work files, all matched by sourcefiles")
      end
    end
  end

  return failures, report
end

-- ---------------------------------------------------------------------------
-- the real tree
-- ---------------------------------------------------------------------------

local root = arg[1] or "."

local chunk, loaderr = loadfile(root .. "/build.lua")
if not chunk then
  print("  build.lua DID NOT LOAD")
  print("    -> " .. tostring(loaderr))
  print()
  print("CTAN CONFIGURATION LINT FAILED")
  os.exit(1)
end

local loaded, runerr = pcall(chunk)
if not loaded then
  print("  build.lua RAISED AN ERROR WHILE LOADING")
  print("    -> " .. tostring(runerr))
  print()
  print("CTAN CONFIGURATION LINT FAILED")
  os.exit(1)
end

-- The configuration as build.lua left it. `textfiledir' is l3build's one
-- relevant default that build.lua does not set; every other value is nil unless
-- build.lua set it, which is what check 5 depends on.
local function snapshot()
  return {
    root          = root,
    module        = module,
    ctanpkg       = ctanpkg,
    ctanreadme    = ctanreadme,
    packtdszip    = packtdszip,
    sourcefiledir = sourcefiledir or ".",
    textfiledir   = textfiledir or ".",
    docfiledir    = docfiledir or ".",
    sourcefiles   = sourcefiles,
    textfiles     = textfiles,
    typesetfiles  = typesetfiles,
    docfiles      = docfiles,
    uploadconfig  = uploadconfig,
  }
end

local fail = 0

print("== CTAN packaging configuration (build.lua) ==")
local failures, report = audit(snapshot())
for _, entry in ipairs(report) do
  print(string.format("  %-12s %-8s %s",
    entry.key, entry.ok and "OK" or "FAILED", entry.detail))
end
if #failures > 0 then fail = 1 end

-- ---------------------------------------------------------------------------
-- self-check
-- ---------------------------------------------------------------------------
--
-- One deliberately broken copy per check. A checker that has stopped detecting
-- its own failure -- or started rejecting the real configuration -- fails here
-- rather than reporting a clean tree.

print()
print("== self-check (the lint's own failure modes) ==")

-- Shallow copies of the tables a mutation touches, so one case cannot leak into
-- the next. A nil source copies to an empty table rather than raising: when the
-- real configuration is already broken the self-check still has to report a
-- verdict, and a traceback here would look like the lint's own defect rather
-- than the tree's.
local function copy(source)
  local result = {}
  for key, value in pairs(source or {}) do result[key] = value end
  return result
end

local function break_it(mutate)
  local cfg = snapshot()
  cfg.textfiles    = copy(cfg.textfiles)
  cfg.sourcefiles  = copy(cfg.sourcefiles)
  cfg.typesetfiles = copy(cfg.typesetfiles)
  cfg.uploadconfig = copy(cfg.uploadconfig)
  mutate(cfg)
  return cfg
end

local function self_check(label, expected, mutate)
  local broken = break_it(mutate)
  local got = audit(broken)
  local found = false
  for _, key in ipairs(got) do
    if key == expected then found = true end
  end
  if found then
    print("  " .. label .. " rejected as intended (" .. expected .. ")")
  elseif #got == 0 then
    print("  " .. label .. " WAS ACCEPTED; the '" .. expected .. "' check did not fire")
    fail = 1
  else
    print("  " .. label .. " FAILED FOR THE WRONG REASON: expected '" .. expected ..
      "', got '" .. table.concat(got, ", ") .. "'")
    fail = 1
  end
end

self_check("stale version",      "version",    function(c) c.uploadconfig.version = "0.0.1-stale" end)
self_check("missing textfile",   "files",      function(c) c.textfiles[#c.textfiles + 1] = "NO-SUCH-FILE.md" end)
self_check("README dropped",     "contents",   function(c) c.textfiles = { "CHANGELOG.md", "manifest.txt" } end)
self_check("manual dropped",     "contents",   function(c) c.typesetfiles = { } end)
self_check("packtdszip unset",   "packtdszip", function(c) c.packtdszip = nil end)
self_check("package renamed",    "ctanpkg",    function(c) c.ctanpkg = "career-dossier" end)
self_check("Work file unmatched", "work",      function(c) c.sourcefiles = { "careerdossier-*.sty" } end)

print()
if fail == 0 then
  print("CTAN CONFIGURATION LINT PASSED")
else
  print("CTAN CONFIGURATION LINT FAILED")
end
os.exit(fail == 0 and ok_exit or 1)
