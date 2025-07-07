---@module "picker.assets.backdrops.totoro"
---@author sravioli
---@license GNU-GPLv3

---@class PickList
local M = {}

local backdrop = require "utils.backdrop"

M.get = function()
  return { id = "totoro", label = "Totoro" }
end

M.activate = function(Config, opts)
  local filename = "picker/assets/backdrops/images/totoro.jpeg"
  local image_path = backdrop:get_image_path(filename)
  if image_path then
    backdrop:set_specific_image(opts.window, image_path)
  end
end

return M
