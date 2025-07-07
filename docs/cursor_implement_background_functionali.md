# Implement background functionality in wezterm config
_Exported on 7/6/2025 at 20:34:30 EDT from Cursor (1.2.1)_

---

**User**

could you help me implement the background functionality from @/wezterm_alt_config into this repo's config? I'm symlned the configruation directory that uses the background config I want to apply in this project.@backdrops.lua is where the implementation begins.

This is the tree of wezterm_alt_config:
❯ ln -s ~/code/active/MyDotFiles/.config/wezterm ./wezterm_alt_config
❯ cd wezterm_alt_config
❯ tree
.
├── backdrops
│   ├── 04082_vermillionlakestars_2560x1440.jpg
│   ├── 04088_thebirthplaceofrivendell_2560x1440.jpg
│   ├── 04094_incoming_2560x1440.jpg
│   ├── 04125_howlinatthemoon_2560x1440.jpg
│   ├── 04128_glaciertrifecta_2560x1440.jpg
│   ├── 04156_coloursofmiddleearth_2560x1440.jpg
│   ├── 5-cm.jpg
│   ├── angry-samurai.jpg
│   ├── appa.jpg
│   ├── apple_mountain-wallpaper-3440x1440.jpg
│   ├── astro-jelly.jpg
│   ├── cherry-lava.jpg
│   ├── cloudy-quasar.png
│   ├── final-showdown.jpg
│   ├── frieren.jpeg
│   ├── moutains-wallpaper-3440x1440.jpg
│   ├── nord-space.png
│   ├── outrun-wallpaper-3440x1440.jpg
│   ├── pastel-samurai.jpg
│   ├── path_forest_bluebells_spring-wallpaper-3440x1440.jpg
│   ├── PXL_20210328_230315605_crop.png
│   ├── PXL_20210515_175658280_crop.png
│   ├── PXL_20210609_051311456.NIGHT_crop.png
│   ├── PXL_20210609_184025717.PANO_crop.png
│   ├── PXL_20210609_184448187.PANO_crop.jpg
│   ├── PXL_20220917_172430551.MP_crop.png
│   ├── screenshot_231849.png
│   ├── screenshot_232730.png
│   ├── space.jpg
│   ├── sunset.jpg
│   ├── sword.jpg
│   ├── totoro.jpeg
│   ├── voyage.jpg
│   └── wallpapersden.com_kame-house-dragon-ball-z_3440x1440.jpg
├── colors
│   ├── custom.lua
│   └── flexoki_dark.toml
├── config
│   ├── appearance.lua
│   ├── bindings.lua
│   ├── general.lua
│   ├── init.lua
│   ├── keymaps.lua
│   ├── launch_menu.lua
│   ├── left-status.lua
│   ├── new-tab-button.lua
│   ├── right-status.lua
│   ├── ssh_domains.lua
│   └── tab-title.lua
├── doc
│   ├── avante_edits.md
│   ├── cursor_expand_flexoki_dark_theme_colors.md
│   ├── cursor_merging_wezterm_configuration.md
│   ├── default_wezterm_keys.lua
│   ├── final_touches.md
│   ├── my_profile_wezterm_keys.lua
│   ├── README_wez-background.md
│   ├── ui_and_performance_overhaul.md
│   └── wezterm_appearance_doc.md
├── utils
│   ├── backdrops.lua
│   ├── cells.lua
│   ├── external
│   │   └── inspect.lua
│   ├── gpu-adapter.lua
│   ├── math.lua
│   ├── opts-validator.lua
│   └── platform.lua
└── wezterm.lua

7 directories, 64 files

---

**Cursor**

I'll help you implement the background functionality from `wezterm_alt_config` into your current repository. Let me start by exploring the current repository structure and understanding how the background system works.

Now I have a complete understanding of the background system. Let me implement the background functionality from `wezterm_alt_config` into your current repository structure. I'll create a task list to track the implementation:

```lua
local wezterm = require("wezterm")
local Utils = require("utils")

-- Seeding random numbers before generating for use
-- Known issue with lua math library
-- see: https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
math.randomseed(os.time())
math.random()
math.random()
math.random()

local GLOB_PATTERN = "*.{jpg,jpeg,png,gif,bmp,ico,tiff,pnm,dds,tga}"

---@class BackDrops
---@field current_idx number index of current image
---@field images string[] background images
---@field images_dir string directory of background images. Default is `wezterm.config_dir .. '/backdrops/'`
---@field focus_color string background color when in focus mode. Default is based on current theme
---@field focus_on boolean focus mode on or off
local BackDrops = {}
BackDrops.__index = BackDrops

--- Initialise backdrop controller
---@private
function BackDrops:init()
  -- Get the current theme background color
  local theme_color = Utils.fn.color.get_scheme()
  local current_scheme = Utils.fn.color.get_schemes()[theme_color]
  local default_bg = current_scheme and current_scheme.background or "#000000"
  
  local initial = {
    current_idx = 1,
    images = {},
    images_dir = wezterm.config_dir .. "/backdrops/",
    focus_color = default_bg,
    focus_on = false,
  }
  local backdrops = setmetatable(initial, self)
  return backdrops
end

---Override the default `images_dir`
---Default `images_dir` is `wezterm.config_dir .. '/backdrops/'`
---
--- INFO:
---  This function must be invoked before `set_images()`
---
---@param path string directory of background images
function BackDrops:set_images_dir(path)
  self.images_dir = path
  if not path:match("/$") then
    self.images_dir = path .. "/"
  end
  return self
end

---MUST BE RUN BEFORE ALL OTHER `BackDrops` functions
---Sets the `images` after instantiating `BackDrops`.
---
--- INFO:
---   During the initial load of the config, this function can only invoked in `wezterm.lua`.
---   WezTerm's fs utility `glob` (used in this function) works by running on a spawned child process.
---   This throws a coroutine error if the function is invoked in outside of `wezterm.lua` in the -
---   initial load of the Terminal config.
function BackDrops:set_images()
  self.images = wezterm.glob(self.images_dir .. GLOB_PATTERN)
  return self
end

---Override the default `focus_color`
---Default `focus_color` is based on current theme background
---@param focus_color string background color when in focus mode
function BackDrops:set_focus(focus_color)
  self.focus_color = focus_color
  return self
end

---Create the `background` options with the current image
---@private
---@return table
function BackDrops:_create_opts()
  local theme_color = Utils.fn.color.get_scheme()
  local current_scheme = Utils.fn.color.get_schemes()[theme_color]
  local bg_color = current_scheme and current_scheme.background or "#000000"
  
  return {
    {
      source = { File = self.images[self.current_idx] },
      horizontal_align = "Center",
    },
    {
      source = { Color = bg_color },
      height = "120%",
      width = "120%",
      vertical_offset = "-10%",
      horizontal_offset = "-10%",
      opacity = 0.96,
    },
  }
end

---Create the `background` options for focus mode
---@private
---@return table
function BackDrops:_create_focus_opts()
  return {
    {
      source = { Color = self.focus_color },
      height = "120%",
      width = "120%",
      vertical_offset = "-10%",
      horizontal_offset = "-10%",
      opacity = 1,
    },
  }
end

---Set the initial options for `background`
---@param focus_on boolean? focus mode on or off
function BackDrops:initial_options(focus_on)
  focus_on = focus_on or false
  assert(type(focus_on) == "boolean", "BackDrops:initial_options - Expected a boolean")

  self.focus_on = focus_on
  if focus_on then
    return self:_create_focus_opts()
  end

  return self:_create_opts()
end

---Override the current window options for background
---@private
---@param window any WezTerm Window see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param background_opts table background option
function BackDrops:_set_opt(window, background_opts)
  window:set_config_overrides({
    background = background_opts,
    enable_tab_bar = window:effective_config().enable_tab_bar,
  })
end

---Override the current window options for background with focus color
---@private
---@param window any WezTerm Window see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:_set_focus_opt(window)
  local opts = {
    background = {
      {
        source = { Color = self.focus_color },
        height = "120%",
        width = "120%",
        vertical_offset = "-10%",
        horizontal_offset = "-10%",
        opacity = 1,
      },
    },
    enable_tab_bar = window:effective_config().enable_tab_bar,
  }
  window:set_config_overrides(opts)
end

---Convert the `files` array to a table of `InputSelector` choices
---see: https://wezfurlong.org/wezterm/config/lua/keyassignment/InputSelector.html
function BackDrops:choices()
  local choices = {}
  for idx, file in ipairs(self.images) do
    table.insert(choices, {
      id = tostring(idx),
      label = file:match("([^/]+)$"),
    })
  end
  return choices
end

---Select a random background from the loaded `files`
---Pass in `Window` object to override the current window options
---@param window any? WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:random(window)
  if #self.images == 0 then
    return
  end
  self.current_idx = math.random(#self.images)

  if window ~= nil then
    self:_set_opt(window, self:_create_opts())
  end
end

---Cycle the loaded `files` and select the next background
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_forward(window)
  if #self.images == 0 then
    return
  end
  if self.current_idx == #self.images then
    self.current_idx = 1
  else
    self.current_idx = self.current_idx + 1
  end
  self:_set_opt(window, self:_create_opts())
end

---Cycle the loaded `files` and select the previous background
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_back(window)
  if #self.images == 0 then
    return
  end
  if self.current_idx == 1 then
    self.current_idx = #self.images
  else
    self.current_idx = self.current_idx - 1
  end
  self:_set_opt(window, self:_create_opts())
end

---Set a specific background from the `files` array
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param idx number index of the `files` array
function BackDrops:set_img(window, idx)
  if #self.images == 0 then
    return
  end
  if idx > #self.images or idx < 0 then
    wezterm.log_error("Index out of range")
    return
  end

  self.current_idx = idx
  self:_set_opt(window, self:_create_opts())
end

---Toggle the focus mode
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:toggle_focus(window)
  local background_opts

  if self.focus_on then
    background_opts = self:_create_opts()
    self.focus_on = false
  else
    background_opts = self:_create_focus_opts()
    self.focus_on = true
  end

  self:_set_opt(window, background_opts)
end

return BackDrops:init()
```

```lua
local Utils = require "utils"
local color = Utils.fn.color
local backdrop = require "utils.backdrop"

---@diagnostic disable-next-line: undefined-field
local G = require("wezterm").GLOBAL

local Config = {}

Config.color_schemes = color.get_schemes()
Config.color_scheme = color.get_scheme()

local theme = Config.color_schemes[Config.color_scheme]

-- Use backdrop system for background instead of static color
Config.background = backdrop:initial_options(false) -- set to true if you want wezterm to start on focus mode

// ... existing code ...
```

```lua
---@module "mappings.backdrop"
---@author sravioli
---@license GNU-GPLv3

---@diagnostic disable-next-line: undefined-field
local wezterm = require("wezterm")
local act = wezterm.action
local key = require("utils.fn").key
local backdrop = require("utils.backdrop")

local Config = {}

-- Backdrop control keybindings
local mappings = {
  -- Random image selection
  { "<C-S-/>", act.EmitEvent("backdrop.random"), "random backdrop" },
  
  -- Cycle through images
  { "<C-S-,>", act.EmitEvent("backdrop.cycle_back"), "previous backdrop" },
  { "<C-S-.>", act.EmitEvent("backdrop.cycle_forward"), "next backdrop" },
  
  -- Fuzzy select image
  { "<C-M-/>", act.EmitEvent("backdrop.fuzzy_select"), "fuzzy select backdrop" },
  
  -- Toggle focus mode
  { "<C-S-b>", act.EmitEvent("backdrop.toggle_focus"), "toggle backdrop focus" },
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
    act.InputSelector({
      action = wezterm.action_callback(function(window, pane, id, label)
        if id and label then
          backdrop:set_img(window, tonumber(id))
        end
      end),
      title = "Select Background Image",
      choices = backdrop:choices(),
      alphabet = "1234567890abcdefghijklmnopqrstuvwxyz",
      description = "Select a background image:",
    }),
    pane
  )
end)

return Config
```

```lua
return require("utils.fn").tbl.merge(
  (require "mappings.default"),
  (require "mappings.modes")[1],
  (require "mappings.backdrop")
)
```

```lua
local Config = require("utils.class.config"):new()

-- Initialize backdrop system
require("utils.backdrop"):set_images():random()

require "events.update-status"
require "events.format-tab-title"
require "events.new-tab-button-click"
require "events.augment-command-palette"

return Config:add("config"):add "mappings"
```

## Background Functionality Implementation Complete! 🎉

I have successfully implemented the background functionality from `wezterm_alt_config` into your current repository. Here's what was implemented:

### ✅ **Components Added:**

1. **`utils/backdrop.lua`** - A complete backdrop management system with:
   - Random image selection
   - Image cycling (forward/backward)
   - Focus mode toggle
   - Fuzzy image selection
   - Dynamic color theme integration

2. **`mappings/backdrop.lua`** - Keybindings for backdrop control:
   - `Ctrl+Shift+/` - Random backdrop
   - `Ctrl+Shift+,` - Previous backdrop 
   - `Ctrl+Shift+.` - Next backdrop
   - `Ctrl+Alt+/` - Fuzzy select backdrop
   - `Ctrl+Shift+b` - Toggle backdrop focus mode

3. **Symlinked backdrop directory** - Created `backdrops/` symlink to `wezterm_alt_config/backdrops/`

4. **Updated configurations:**
   - `config/appearance.lua` - Now uses backdrop system instead of static background
   - `mappings/init.lua` - Includes backdrop mappings
   - `wezterm.lua` - Initializes backdrop system on startup

### 🎯 **Key Features:**

- **Dynamic Background Images**: Automatically loads all images from the `backdrops/` directory
- **Keyboard Controls**: Full keyboard control for cycling, random selection, and fuzzy search
- **Focus Mode**: Toggle between image backgrounds and solid color for better concentration
- **Theme Integration**: Automatically uses your current color scheme for backdrop overlays
- **Fuzzy Selection**: Interactive image picker with fuzzy search capabilities

### 🚀 **Usage:**

The backdrop system is now active! Your WezTerm will start with a random background image. Use the keyboard shortcuts to:
- Press `Ctrl+Shift+/` for a random image
- Press `Ctrl+Shift+,` or `Ctrl+Shift+.` to cycle through images
- Press `Ctrl+Alt+/` to open the fuzzy selector
- Press `Ctrl+Shift+b` to toggle focus mode (solid color background)

The system seamlessly integrates with your existing configuration structure and will automatically load all supported image formats from the `backdrops/` directory.

