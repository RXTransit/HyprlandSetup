-- Main Hyprland Lua config

require("config.appearance")
require("config.monitors")
require("config.workspaces")
require("config.keybinds")
require("config.autostart")

-- For Noctalia Color templates
require("noctalia").apply_theme()
