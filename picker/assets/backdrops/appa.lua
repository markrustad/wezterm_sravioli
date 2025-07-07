---@module "picker.assets.backdrops.appa"
---@author sravioli
---@license GNU-GPLv3

---@class PickList
local M = {}

local backdrop = require "utils.backdrop"

M.get = function()
  return { id = "appa", label = "Appa" }
end

M.activate = function(Config, opts)
  local filename = "picker/assets/backdrops/images/appa.jpg"
  local image_path = backdrop:get_image_path(filename)
  if image_path then
    backdrop:set_specific_image(opts.window, image_path)
  end
end

return M
