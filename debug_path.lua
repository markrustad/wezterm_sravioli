local wt = require "wezterm"
local config_dir = wt.config_dir

wt.log_info("config_dir: " .. tostring(config_dir))
wt.log_info("cwd: " .. tostring(wt.procinfo.pid and wt.procinfo.cwd or "unknown"))

local test_path =
  "/home/mark/code/active/wezterm_sravioli/picker/assets/fonts/cascadia-nf.lua"
local result = test_path:sub(#config_dir + 2):gsub("%.lua$", ""):gsub("/", ".")

wt.log_info("test_path: " .. test_path)
wt.log_info("after processing: " .. result)

return {}
