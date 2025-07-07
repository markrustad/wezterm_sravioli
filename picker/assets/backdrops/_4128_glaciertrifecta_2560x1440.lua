---@module "picker.assets.backdrops._4128_glaciertrifecta_2560x1440"
---@author sravioli
---@license GNU-GPLv3

---@class PickList
local M = {}

local backdrop = require "utils.backdrop"

M.get = function()
  return {
    id = "_4128_glaciertrifecta_2560x1440",
    label = "04128 Glaciertrifecta 2560x1440",
  }
end

M.activate = function(Config, opts)
  local backdrop = require "utils.backdrop"
  -- Find the index of this image in the backdrop.images array
  local target_filename = "04128_glaciertrifecta_2560x1440.jpg"
  for idx, image_path in ipairs(backdrop.images) do
    if image_path:match "([^/]+)$" == target_filename then
      backdrop:set_img(opts.window, idx)
      break
    end
  end
end

return M
