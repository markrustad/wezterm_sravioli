---Ported from: https://stephango.com/flexoki
---@module "picker.assets.colorschemes.flexoki-dark"
---@author sravioli
---@license MIT

---@class PickList
local M = {}

local color = require("utils").fn.color

M.scheme = {
  background = "#100F0F",
  foreground = "#CECDC3",
  cursor_bg = "#CECDC3",
  cursor_fg = "#100F0F",
  cursor_border = "#CECDC3",
  selection_fg = "#CECDC3",
  selection_bg = "#282726",
  scrollbar_thumb = "#282726",
  split = "#403E3C",
  ansi = {
    "#100F0F",
    "#AF3029",
    "#66800B",
    "#AD8301",
    "#205EA6",
    "#5E409D",
    "#24837B",
    "#CECDC3",
  },
  brights = {
    "#575653",
    "#D14D41",
    "#879A39",
    "#D0A215",
    "#4385BE",
    "#8B7EC8",
    "#3AA99F",
    "#FFFCF0",
  },
  indexed = { [16] = "#DA702C", [17] = "#CE5D97" },
  compose_cursor = "#3AA99F",
  visual_bell = "#343331",
  copy_mode_active_highlight_bg = { Color = "#282726" },
  copy_mode_active_highlight_fg = { Color = "#CECDC3" },
  copy_mode_inactive_highlight_bg = { Color = "#3AA99F" },
  copy_mode_inactive_highlight_fg = { Color = "#100F0F" },
  quick_select_label_bg = { Color = "#DA702C" },
  quick_select_label_fg = { Color = "#100F0F" },
  quick_select_match_bg = { Color = "#205EA6" },
  quick_select_match_fg = { Color = "#FFFCF0" },
  tab_bar = {
    background = "#100F0F",
    inactive_tab_edge = "#403E3C",
    active_tab = { bg_color = "#282726", fg_color = "#CECDC3", italic = false },
    inactive_tab = { bg_color = "#1C1B1A", fg_color = "#878580", italic = false },
    inactive_tab_hover = { bg_color = "#282726", fg_color = "#CECDC3", italic = false },
    new_tab = { bg_color = "#1C1B1A", fg_color = "#CECDC3", italic = false },
    new_tab_hover = { bg_color = "#343331", fg_color = "#FFFCF0", italic = true },
  },
}

function M.get()
  return { id = "flexoki-dark", label = "Flexoki Dark" }
end

function M.activate(Config, callback_opts)
  local theme = M.scheme
  color.set_scheme(Config, theme, callback_opts.id)
end

return M
