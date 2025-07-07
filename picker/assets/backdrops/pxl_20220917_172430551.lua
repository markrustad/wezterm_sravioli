---@module "picker.assets.backdrops.pxl_20220917_172430551"
---@author sravioli
---@license GNU-GPLv3

---@class PickList
local M = {}

local backdrop = require "utils.backdrop"

M.get = function()
  return { id = "pxl_20220917_172430551", label = "Pxl 20220917 172430551" }
end

M.activate = function(Config, opts)
  local backdrop = require "utils.backdrop"
  -- Find the index of this image in the backdrop.images array
  local target_filename = "PXL_20220917_172430551.MP_crop.png"
  for idx, image_path in ipairs(backdrop.images) do
    if image_path:match "([^/]+)$" == target_filename then
      backdrop:set_img(opts.window, idx)
      break
    end
  end
end

return M
