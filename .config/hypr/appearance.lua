-- Appearance

hl.curve("easeOutCubic", {
    type = "bezier",
    points = {
        { 0.25, 0.46 },
        { 0.45, 0.94 },
    },
})
hl.animation({
leaf = "workspaces",
enabled = true,
speed = 2,
bezier = "easeOutCubic",
style = "fade",
})
hl.animation({
    leaf = "windowsIn","layersIn","fade",
    enabled = true,
    speed = 4,
    bezier = "easeOutCubic",
    style = "popin","fadeIn"
})

hl.animation({
    leaf = "windowsOut","layersOut","fade",
    enabled = true,
    speed = 4,
    bezier = "easeOutCubic",
    style ="popin","fadeOut",
})
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 4,
        border_size = 3,
        resize_on_border = true,
    },

    decoration = {
        rounding = 25,
        rounding_power = 3,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {vrr = 2, force_default_wallpaper = 0, disable_hyprland_logo = true, disable_splash_rendering = true, enable_swallow = true,},})
