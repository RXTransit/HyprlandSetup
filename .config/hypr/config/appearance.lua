-- Appearance

hl.curve("easeOutCubic", {
    type = "bezier",
    points = {
        { 0.25, 0.46 },
        { 0.45, 0.94 },
    },
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4,
    bezier = "easeOutCubic",
    style = "gnomed",
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 4,
    bezier = "easeOutCubic",
    style = "gnomed",
})
hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 4,
        resize_on_border = true,
    },

    decoration = {
        rounding = 0,
        rounding_power = 0,

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

    misc = {
        vrr = 2,
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})
