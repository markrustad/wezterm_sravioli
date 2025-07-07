local Config = require("utils.class.config"):new()

-- Initialize backdrop system
require("utils.backdrop"):set_images()

require "events.update-status"
require "events.format-tab-title"
require "events.new-tab-button-click"
require "events.augment-command-palette"

return Config:add("config"):add "mappings"
