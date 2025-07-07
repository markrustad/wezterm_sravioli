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

-- Get list of image files using LuaFileSystem for portability
local lfs = require "lfs"
local files = {}
local image_exts = {
  jpg = true,
  jpeg = true,
  png = true,
  gif = true,
  bmp = true,
  ico = true,
  tiff = true,
  pnm = true,
  dds = true,
  tga = true,
}

for file in lfs.dir(images_dir) do
  if file ~= "." and file ~= ".." then
    local ext = file:match "%.([^.]+)$"
    if ext and image_exts[ext:lower()] then
      table.insert(files, file)
    end
  end
end

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
