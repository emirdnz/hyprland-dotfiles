-- Look and feel configuration

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 8,
        border_size = 1,
        extend_border_grab_area = 10,
        resize_on_border = true,
        col = {
            active_border = "rgba(ffffff55)",
            inactive_border = "rgba(ffffff18)",
        },
    },
    group = {
        col = {
            border_active = CACHYLBLUE,
            border_inactive = CACHYGRAY,
            border_locked_active = CACHYDBLUE,
            border_locked_inactive = CACHYGRAY,
        },
        groupbar = {
            col = {
                active = CACHYLGREEN,
                inactive = CACHYGRAY,
                locked_active = CACHYDBLUE,
                locked_inactive = CACHYGRAY,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 12,
        active_opacity = 0.92,
        inactive_opacity = 0.82,
        fullscreen_opacity = 1,
        blur = {
            size = 8,
            passes = 3,
            noise = 0.02,
            contrast = 0.9,
            brightness = 0.8,
            vibrancy = 0.2,
            popups = true,
            special = true,
        },
    },
})
