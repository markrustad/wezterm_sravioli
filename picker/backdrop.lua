---@module "picker.backdrop"
---@author sravioli
---@license GNU-GPLv3

local Utils = require "utils"
local Picker = Utils.class.picker

return Picker.new {
  title = "🖼️  Backdrop",
  fuzzy = true,
  fuzzy_description = "Fuzzy matching: ",
  description = "Select a backdrop image:",

  build = function(choices, window_opts, opts)
    local backdrop = require "utils.backdrop"
    local image_choices = {}

    -- Generate choices from backdrop images
    for idx, image_path in ipairs(backdrop.images) do
      local filename = image_path:match "([^/]+)$" -- Get just the filename
      table.insert(image_choices, {
        id = tostring(idx),
        label = filename,
        image_path = image_path,
      })
    end

    -- Sort choices by label
    table.sort(image_choices, function(a, b)
      return a.label < b.label
    end)

    return image_choices
  end,

  -- Custom activation for backdrop selection
  on_select = function(window, pane, choice)
    if choice and choice.id then
      local backdrop = require "utils.backdrop"
      backdrop:set_img(window, tonumber(choice.id))
    end
  end,
}
