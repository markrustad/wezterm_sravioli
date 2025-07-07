---@module "mappings.backdrop"
---@author sravioli
---@license GNU-GPLv3

---@diagnostic disable-next-line: undefined-field
local wezterm = require "wezterm"
local act = wezterm.action
local key = require("utils.fn").key
local backdrop = require "utils.backdrop"

local Config = {}

-- Backdrop control keybindings
local mappings = {
  -- Random image selection
  { "<C-S-/>", act.EmitEvent "backdrop.random", "random backdrop" },

  -- Cycle through images
  { "<C-S-,>", act.EmitEvent "backdrop.cycle_back", "previous backdrop" },
  { "<C-S-.>", act.EmitEvent "backdrop.cycle_forward", "next backdrop" },

  -- Fuzzy select image
  { "<C-M-/>", act.EmitEvent "backdrop.fuzzy_select", "fuzzy select backdrop" },

  -- Toggle focus mode
  { "<C-S-b>", act.EmitEvent "backdrop.toggle_focus", "toggle backdrop focus" },
}

Config.keys = {}
for _, map_tbl in ipairs(mappings) do
  key.map(map_tbl[1], map_tbl[2], Config.keys)
end

-- Event handlers for backdrop actions
wezterm.on("backdrop.random", function(window, pane)
  backdrop:random(window)
end)

wezterm.on("backdrop.cycle_back", function(window, pane)
  backdrop:cycle_back(window)
end)

wezterm.on("backdrop.cycle_forward", function(window, pane)
  backdrop:cycle_forward(window)
end)

wezterm.on("backdrop.toggle_focus", function(window, pane)
  backdrop:toggle_focus(window)
end)

wezterm.on("backdrop.fuzzy_select", function(window, pane)
  window:perform_action(
    act.InputSelector {
      action = wezterm.action_callback(function(window, pane, id, label)
        if id and label then
          backdrop:set_img(window, tonumber(id))
        end
      end),
      title = "Select Background Image",
      choices = backdrop:choices(),
      alphabet = "1234567890abcdefghijklmnopqrstuvwxyz",
      description = "Select a background image:",
    },
    pane
  )
end)

return Config
