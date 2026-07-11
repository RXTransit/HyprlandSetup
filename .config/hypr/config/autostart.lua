-- Autostart

hl.on("hyprland.start", function()
    hl.exec_cmd("openrgb --profile RGB")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("uwsm app -- steam")
    hl.exec_cmd("flatpak run dev.vencord.Vesktop")
end)
