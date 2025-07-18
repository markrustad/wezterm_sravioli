local Utils = require "utils"
local wezterm = require "wezterm"

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
    images_dir = wezterm.config_dir .. "/picker/assets/backdrops/images/",
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
  if not path:match "/$" then
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

---Update backdrop for theme change
---Updates the focus color and regenerates background options
---@param theme_bg string new theme background color
function BackDrops:update_for_theme(theme_bg)
  self.focus_color = theme_bg
  return self
end

---Create the `background` options with the current image
---@private
---@return table
function BackDrops:_create_opts()
  -- Get current theme background color dynamically
  local theme_color = Utils.fn.color.get_scheme()
  local current_scheme = Utils.fn.color.get_schemes()[theme_color]
  local bg_color = current_scheme and current_scheme.background
    or self.focus_color
    or "#000000"

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
  local current_config = window:effective_config()
  window:set_config_overrides {
    background = background_opts,
    enable_tab_bar = current_config.enable_tab_bar,
  }
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
      label = file:match "([^/]+)$",
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
    wezterm.log_error "Index out of range"
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
