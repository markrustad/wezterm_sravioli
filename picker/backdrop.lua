---@module "picker.backdrop"
---@author sravioli
---@license GNU-GPLv3

local Picker = require("utils").class.picker

return Picker.new {
  title = "🖼️  Backdrop",
  -- subdir = "backdrops",
  subdir = "picker/assets/backdrops/images",
  fuzzy = true,
  fuzzy_description = "Fuzzy matching: ",
  description = "Select a backdrop image:",
  comp = function(a, b)
    return a.label < b.label
  end,
}
