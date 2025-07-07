#!/usr/bin/env lua

-- Script to generate backdrop asset files from images directory
local function sanitize_name(filename)
  -- Remove extension and sanitize for Lua module name
  local name = filename:match "([^.]+)"
  name = name:gsub("[^%w_]", "_")
  name = name:gsub("^%d", "_"):gsub("__+", "_"):gsub("_$", "")
  return name:lower()
end

local function create_asset_file(image_filename)
  local module_name = sanitize_name(image_filename)
  local display_name = image_filename
    :match("([^.]+)")
    :gsub("[_%-]", " ")
    :gsub("(%w)(%w*)", function(first, rest)
      return first:upper() .. rest:lower()
    end)

  local content = string.format(
    [[---@module "picker.assets.backdrops.%s"
---@author sravioli
---@license GNU-GPLv3

---@class PickList
local M = {}

local backdrop = require "utils.backdrop"

M.get = function()
  return { id = "%s", label = "%s" }
end

M.activate = function(Config, opts)
  local backdrop = require "utils.backdrop"
  -- Find the index of this image in the backdrop.images array
  local target_filename = "%s"
  for idx, image_path in ipairs(backdrop.images) do
    if image_path:match("([^/]+)$") == target_filename then
      backdrop:set_img(opts.window, idx)
      break
    end
  end
end

return M
]],
    module_name,
    module_name,
    display_name,
    image_filename
  )

  return content, module_name
end

-- Main execution
local images_dir = "picker/assets/backdrops/images"
local assets_dir = "picker/assets/backdrops"

-- Get list of image files
local handle = io.popen(
  string.format(
    "ls %s/*.{jpg,jpeg,png,gif,bmp,ico,tiff,pnm,dds,tga} 2>/dev/null",
    images_dir
  )
)
if not handle then
  print "Error: Could not list image files"
  os.exit(1)
end

local files = {}
for filename in handle:lines() do
  local basename = filename:match "([^/]+)$"
  if basename then
    table.insert(files, basename)
  end
end
handle:close()

-- Generate asset files
local generated = {}
for _, filename in ipairs(files) do
  local content, module_name = create_asset_file(filename)
  local output_file = string.format("%s/%s.lua", assets_dir, module_name)

  local file = io.open(output_file, "w")
  if file then
    file:write(content)
    file:close()
    table.insert(generated, output_file)
    print("Generated:", output_file)
  else
    print("Error: Could not write to", output_file)
  end
end

print(string.format("Generated %d backdrop asset files", #generated))
