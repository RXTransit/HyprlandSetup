-- Keybinds and environment variables

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("TERMINAL", "kitty")
hl.env("GTK_CSD", "1")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "thunar"
local menu = "noctalia msg panel-toggle launcher"
local browser = "zen-browser"

-- Applications and window actions
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({mode = "fullscreen", action = "toggle",}))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser .. " --new-window"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind(mainMod .. " + X", hl.dsp.window.float({ action = "toggle" }))
hl.bind("Menu", hl.dsp.exec_cmd("noctalia msg power-cycle"),{locked = true,})
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
-- Media controls
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("noctalia msg media stop"),{locked = true, repeating = false,})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("noctalia msg media previous"),{locked = true, repeating = false,})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("noctalia msg media toggle"),{locked = true, repeating = false,})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("noctalia msg media next"),{locked = true, repeating = false,})


-- Switch workspaces
for workspace = 1, 10 do
    local key = workspace == 10 and 0 or workspace
    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = workspace })
    )
end

-- Move windows to workspaces
for workspace = 1, 10 do
    local key = workspace == 10 and 0 or workspace
    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = workspace })
    )
end

-- Move windows in the tiling layout
hl.bind(mainMod .. " + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + right", hl.dsp.window.move({ direction = "r" }))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen pick"))
-- Volume Controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up 5"),{locked = true, repeating = true,})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down 5"),{locked = true, repeating = true,})
hl.bind("XF86AudioMute",hl.dsp.exec_cmd("noctalia msg volume-mute"),{locked = true,})
-- Lock Screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))
--hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock -c ~/config/hypr/hyprlock.lua"))
