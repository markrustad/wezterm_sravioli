-- Simple test file to debug font picker
local wt = require "wezterm"

-- Test if we can require the picker
local picker_ok, picker = pcall(require, "picker.font")
if not picker_ok then
  wt.log_error("Failed to require picker.font: " .. tostring(picker))
  return
end

wt.log_info "Font picker loaded successfully"
wt.log_info("Picker title: " .. tostring(picker.title))

-- Test if we can access __choices
if picker.__choices then
  local count = 0
  for k, v in pairs(picker.__choices) do
    count = count + 1
    wt.log_info("Choice " .. count .. ": " .. k .. " -> " .. tostring(v.value.label))
  end
  wt.log_info("Total choices: " .. count)
else
  wt.log_error "No __choices found in picker"
end

return {}
