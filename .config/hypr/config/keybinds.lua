-- Keybinds and environment variables

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("TERMINAL", "kitty")
hl.env("GTK_CSD", "0")
hl.env("XCURSOR_THEME", "MacOS-Tahoe-Cursor")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "MacOS-Tahoe-Cursor")
hl.env("HYPRCURSOR_SIZE", "24")

local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "nemo"
local menu = "noctalia msg panel-toggle launcher"
local browser = "google-chrome-stable"

-- Applications and window actions
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({mode = "fullscreen", action = "toggle",}))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser .. " --new-window"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind(mainMod .. " + X", hl.dsp.window.float({ action = "toggle" }))

-- Media controls
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"),{locked = true, repeating = false,})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),{locked = true, repeating = false,})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"),{locked = true, repeating = false,})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),{locked = true, repeating = false,})


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
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
-- Volume Controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 5%+"),{locked = true, repeating = true,})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),{locked = true, repeating = true,})
hl.bind("XF86AudioMute",hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),{locked = true,})
-- Lock Screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))
