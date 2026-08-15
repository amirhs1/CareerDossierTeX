-- probe.lua -- measure every vertical boundary in a vbox, structurally and optically.
--
-- Two different gaps exist at every boundary, and the spacing tokens own only
-- one of them:
--
--   structural  the explicit glue and kerns a token asks for, excluding TeX's
--               interline glue. This is what `tests/smoke/statement-section-gap.tex'
--               asserts equals the token, and what `docs/ARCHITECTURE.md'
--               tabulates as a ratio of the body baseline.
--
--   optical     the ink-to-ink white a reader actually sees: the structural gap
--               plus the interline glue, plus the unused slack in the two boxes
--               that bound it. A heading set in a larger size carries a deeper
--               font box, so part of its gap is spent before any ink appears --
--               which is why the two numbers differ, and differ asymmetrically
--               above versus below the same heading.
--
-- Reporting both for every boundary is the point: the relation between them is
-- then measured rather than assumed.

cdossier_probe = {}

local glue_subtypes = node.subtypes("glue")
local RUNNING = -1073741824

local function is_box(kind)
  return kind == "hlist" or kind == "vlist"
end

-- Ink extent of a list relative to the enclosing baseline. `shift' is how far
-- this list sits below that baseline. Returns height above and depth below, or
-- nil when the list holds no ink at all (an empty or glue-only box) -- a case
-- the caller must not treat as zero-height ink sitting on the baseline.
local function ink_extent(head, shift)
  local hi, lo
  for n in node.traverse(head) do
    local kind = node.type(n.id)
    local h, d
    if kind == "glyph" then
      h, d = n.height - shift, n.depth + shift
    elseif kind == "rule" then
      -- A running dimension inherits from the enclosing box and sets no ink
      -- bound of its own; the section rule states both explicitly.
      if n.height ~= RUNNING then h = n.height - shift end
      if n.depth ~= RUNNING then d = n.depth + shift end
    elseif is_box(kind) then
      h, d = ink_extent(n.list, shift + n.shift)
    end
    if h and (hi == nil or h > hi) then hi = h end
    if d and (lo == nil or d > lo) then lo = d end
  end
  return hi, lo
end

-- Ink extent of a node that may itself be a rule rather than a box. A rule is
-- solid ink, so its own dimensions are its ink.
local function node_ink(n)
  local kind = node.type(n.id)
  if kind == "rule" then
    local h = n.height ~= RUNNING and n.height or 0
    local d = n.depth ~= RUNNING and n.depth or 0
    return h, d
  end
  return ink_extent(n.list, 0)
end

local function node_height(n)
  return n.height ~= RUNNING and n.height or 0
end

local function node_depth(n)
  return n.depth ~= RUNNING and n.depth or 0
end

local function pt(sp)
  return math.floor(sp / 65536 * 1000 + 0.5) / 1000
end

-- Walk a vbox's vertical list and emit one record per boundary between
-- consecutive boxes or rules. `labels' names them in order; an unnamed boundary
-- is still reported, so a fixture that grew a box cannot silently shift the
-- labels onto the wrong gaps.
function cdossier_probe.report(boxnumber, context, labels)
  local list = tex.box[boxnumber].list
  local prev, structural, interline, index = nil, 0, 0, 0

  for n in node.traverse(list) do
    local kind = node.type(n.id)
    if is_box(kind) or kind == "rule" then
      if prev then
        index = index + 1
        local _, prev_ink_lo = node_ink(prev)
        local next_ink_hi = node_ink(n)

        local prev_depth, next_height = node_depth(prev), node_height(n)
        local baseline_to_baseline = prev_depth + structural + interline + next_height

        -- Slack is the part of a bounding box carrying no ink. A box with no
        -- ink at all is reported as NA rather than counted as full slack,
        -- which would overstate the white.
        local optical
        if prev_ink_lo and next_ink_hi then
          optical = structural + interline
                    + (prev_depth - prev_ink_lo) + (next_height - next_ink_hi)
        end

        texio.write_nl(string.format(
          "CDPROBE\t%s\t%d\t%s\t%.3f\t%.3f\t%.3f\t%s\t%.3f\t%s\t%.3f\t%s",
          context, index, labels[index] or "(unlabelled)",
          pt(structural), pt(interline), pt(baseline_to_baseline),
          optical and string.format("%.3f", pt(optical)) or "NA",
          pt(prev_depth), prev_ink_lo and string.format("%.3f", pt(prev_ink_lo)) or "NA",
          pt(next_height), next_ink_hi and string.format("%.3f", pt(next_ink_hi)) or "NA"))
      end
      prev, structural, interline = n, 0, 0
    elseif kind == "glue" then
      local sub = glue_subtypes[n.subtype]
      if sub == "baselineskip" or sub == "lineskip" then
        interline = interline + n.width
      else
        structural = structural + n.width
      end
    elseif kind == "kern" then
      structural = structural + n.kern
    end
  end
end

-- First glyphs of a box, so a page-level row can be identified by what it says.
-- Page compositions nest boxes several levels deep and carry no labels of their
-- own, so without this the header stack's boundaries are unattributable.
local function text_of(n, budget)
  if node.type(n.id) == "rule" then return "<rule>" end
  local out = {}
  local function walk(head)
    for m in node.traverse(head) do
      if #out >= budget then return end
      local kind = node.type(m.id)
      if kind == "glyph" then
        out[#out + 1] = (m.char < 128) and string.char(m.char) or "?"
      elseif kind == "glue" and #out > 0 then
        out[#out + 1] = " "
      elseif is_box(kind) then
        walk(m.list)
      end
    end
  end
  walk(n.list)
  return (table.concat(out):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Walk a shipped page and report every boundary at every nesting level. The
-- header stack, letterhead, and recipient block are page compositions rather
-- than free-standing blocks, so they are unreachable from a \vbox fixture and
-- only this path measures them.
function cdossier_probe.report_page(boxnumber, context)
  local function walk(list, path)
    local prev, structural, interline, index = nil, 0, 0, 0
    for n in node.traverse(list) do
      local kind = node.type(n.id)
      if is_box(kind) or kind == "rule" then
        if prev then
          index = index + 1
          local _, prev_ink_lo = node_ink(prev)
          local next_ink_hi = node_ink(n)
          local prev_depth, next_height = node_depth(prev), node_height(n)
          local optical
          if prev_ink_lo and next_ink_hi then
            optical = structural + interline
                      + (prev_depth - prev_ink_lo) + (next_height - next_ink_hi)
          end
          -- Only boundaries between two boxes that actually carry ink are
          -- reported; the page is full of structural scaffolding whose gaps
          -- name nothing a reader sees.
          if optical and text_of(prev, 24) ~= "" and text_of(n, 24) ~= "" then
            texio.write_nl(string.format(
              "CDPAGE\t%s\t%s\t%d\t%.3f\t%.3f\t%.3f\t%s\t=>\t%s",
              context, path, index,
              pt(structural), pt(interline), pt(prev_depth + structural + interline + next_height),
              string.format("%.3f", pt(optical)),
              text_of(prev, 24) .. " || " .. text_of(n, 24)))
          end
        end
        prev, structural, interline = n, 0, 0
      elseif kind == "glue" then
        local sub = glue_subtypes[n.subtype]
        if sub == "baselineskip" or sub == "lineskip" then
          interline = interline + n.width
        else
          structural = structural + n.width
        end
      elseif kind == "kern" then
        structural = structural + n.kern
      end
    end
    local child = 0
    for n in node.traverse(list) do
      if is_box(node.type(n.id)) and n.list then
        child = child + 1
        walk(n.list, path .. "/" .. child)
      end
    end
  end
  walk(tex.box[boxnumber].list, "")
end

-- The first few characters set in a box, used to name a boundary that no
-- fixture labelled. Page-level compositions -- the identity stack, the
-- letterhead, the recipient block -- are assembled by \MakeCDossierHeader and
-- \MakeCDossierLetterhead rather than written by the document, so a \vbox
-- fixture cannot reach them and there is nothing to label them with in
-- advance. The text they set is the only stable handle they have.
local function text_of(head, budget)
  local out = {}
  for n in node.traverse(head) do
    local kind = node.type(n.id)
    if kind == "glyph" then
      out[#out + 1] = unicode.utf8.char(n.char)
    elseif kind == "glue" and #out > 0 then
      out[#out + 1] = " "
    elseif is_box(kind) then
      out[#out + 1] = text_of(n.list, budget)
    end
    if #table.concat(out) >= budget then break end
  end
  return (table.concat(out):gsub("%s+", " "))
end

-- Walk a shipped page and report every boundary in every vertical list it
-- contains, naming each by the text on either side. `report' cannot be used
-- here: it takes one vlist, and a page is a tree of them.
function cdossier_probe.report_page(boxnumber, context)
  local function descend(head, path)
    local prev, structural, interline, index = nil, 0, 0, 0
    for n in node.traverse(head) do
      local kind = node.type(n.id)
      if is_box(kind) or kind == "rule" then
        if prev then
          index = index + 1
          local _, prev_ink_lo = node_ink(prev)
          local next_ink_hi = node_ink(n)
          local prev_depth, next_height = node_depth(prev), node_height(n)
          if prev_ink_lo and next_ink_hi then
            local optical = structural + interline
                            + (prev_depth - prev_ink_lo) + (next_height - next_ink_hi)
            local a = is_box(node.type(prev.id)) and text_of(prev.list, 24) or "[rule]"
            local b = is_box(kind) and text_of(n.list, 24) or "[rule]"
            -- Boundaries between two pieces of real text are the only ones a
            -- reader can see as a gap; empty struts and spacing boxes are not.
            if a ~= "" and b ~= "" then
              texio.write_nl(string.format(
                "CDPAGE\t%s\t%s\t%d\t%s\t%s\t%.3f\t%.3f\t%.3f",
                context, path, index, a, b,
                pt(structural), pt(interline), pt(optical)))
            end
          end
        end
        prev, structural, interline = n, 0, 0
        if is_box(kind) then descend(n.list, path .. "." .. index) end
      elseif kind == "glue" then
        local sub = glue_subtypes[n.subtype]
        if sub == "baselineskip" or sub == "lineskip" then
          interline = interline + n.width
        else
          structural = structural + n.width
        end
      elseif kind == "kern" then
        structural = structural + n.kern
      end
    end
  end
  descend(tex.box[boxnumber].list, "p")
end

-- Report a token's value and its ratio against the body baseline, so the
-- structural column can be checked against the design without a second lookup.
function cdossier_probe.token(name, sp, baseline)
  texio.write_nl(string.format("CDTOKEN\t%s\t%.4f\t%.4f",
    name, pt(sp), baseline > 0 and (sp / baseline) or 0))
end
