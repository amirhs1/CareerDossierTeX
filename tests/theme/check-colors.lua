-- check-colors.lua — contrast and approximate CVD checks for link themes.
--
-- The matrices are the full-severity transforms from Machado, Oliveira, and
-- Fernandes, "A Physiologically-based Model for Simulation of Color Vision
-- Deficiency" (IEEE TVCG 15.6, 2009; doi:10.1109/TVCG.2009.113). This is a
-- review aid, not a medical model or a broad accessibility-conformance claim.
-- Every result is checked against white at the normal-text 4.5:1 floor.

local theme_file = assert(arg[1], "usage: texlua check-colors.lua THEME_FILE")
local handle = assert(io.open(theme_file, "r"))
local source = handle:read("*a")
handle:close()

local expected = { navy = "1B365D", teal = "005A5A", magenta = "8A1C5A" }
local colors = { monochrome = { 0, 0, 0 }, print = { 0, 0, 0 } }

for name, hex in pairs(expected) do
  local actual = source:match("cdossier%-accent%-" .. name .. "%s*}%s*{%s*HTML%s*}%s*{%s*(%x%x%x%x%x%x)%s*}")
  assert(actual, "could not read " .. name .. " from " .. theme_file)
  assert(actual:upper() == hex, name .. " changed without updating the reviewed palette")
  colors[name] = {
    tonumber(actual:sub(1, 2), 16),
    tonumber(actual:sub(3, 4), 16),
    tonumber(actual:sub(5, 6), 16),
  }
end

local matrices = {
  protanopia = {
    { 0.152286, 1.052583, -0.204868 },
    { 0.114503, 0.786281,  0.099216 },
    {-0.003882,-0.048116,  1.051998 },
  },
  deuteranopia = {
    { 0.367322, 0.860646, -0.227968 },
    { 0.280085, 0.672501,  0.047413 },
    {-0.011820, 0.042940,  0.968881 },
  },
  tritanopia = {
    { 1.255528,-0.076749, -0.178779 },
    {-0.078411, 0.930809,  0.147602 },
    { 0.004733, 0.691367,  0.303900 },
  },
}

local function linear(channel)
  channel = channel / 255
  if channel <= 0.04045 then return channel / 12.92 end
  return ((channel + 0.055) / 1.055) ^ 2.4
end

local function encoded(channel)
  channel = math.max(0, math.min(1, channel))
  if channel <= 0.0031308 then return 12.92 * channel end
  return 1.055 * channel ^ (1 / 2.4) - 0.055
end

local function luminance(rgb)
  return 0.2126 * linear(rgb[1]) + 0.7152 * linear(rgb[2]) + 0.0722 * linear(rgb[3])
end

local function contrast(rgb)
  return 1.05 / (luminance(rgb) + 0.05)
end

local function simulate(rgb, matrix)
  local input = { linear(rgb[1]), linear(rgb[2]), linear(rgb[3]) }
  local output = {}
  for row = 1, 3 do
    local value = 0
    for column = 1, 3 do value = value + matrix[row][column] * input[column] end
    output[row] = 255 * encoded(value)
  end
  return output
end

local order = { "monochrome", "print", "navy", "teal", "magenta" }
local failed = false
for _, name in ipairs(order) do
  local base = contrast(colors[name])
  io.write(string.format("%-10s base %.2f:1", name, base))
  if base < 4.5 then failed = true end
  for _, deficiency in ipairs({ "protanopia", "deuteranopia", "tritanopia" }) do
    local ratio = contrast(simulate(colors[name], matrices[deficiency]))
    io.write(string.format("  %s %.2f:1", deficiency, ratio))
    if ratio < 4.5 then failed = true end
  end
  io.write(string.format("  grayscale %.2f:1\n", base))
end

if failed then
  io.stderr:write("COLOR CHECK FAILED: a link color fell below 4.5:1 on white\n")
  os.exit(1)
end
print("ALL THEME COLOR CHECKS PASSED")
