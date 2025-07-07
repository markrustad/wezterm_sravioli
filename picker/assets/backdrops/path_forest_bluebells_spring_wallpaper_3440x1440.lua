---@module "picker.assets.backdrops.path_forest_bluebells_spring_wallpaper_3440x1440"
---@author sravioli
---@license GNU-GPLv3

---@class PickList
local M = {}

local backdrop = require "utils.backdrop"

M.get = function()
  return {
    id = "path_forest_bluebells_spring_wallpaper_3440x1440",
    label = "Path Forest Bluebells Spring Wallpaper 3440x1440",
  }
end

M.activate = function(Config, opts)
  local backdrop = require "utils.backdrop"
  -- Find the index of this image in the backdrop.images array
  local target_filename = "path_forest_bluebells_spring-wallpaper-3440x1440.jpg"
  for idx, image_path in ipairs(backdrop.images) do
    if image_path:match "([^/]+)$" == target_filename then
      backdrop:set_img(opts.window, idx)
      break
    end
  end
end

return M
