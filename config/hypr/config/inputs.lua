-- Input configuration

hl.config({
    input = {
        kb_layout = "tr,us",
        kb_options = "grp:alt_shift_toggle",
        -- Oturum açılınca Num Lock açık gelsin; giriş ekranı zaten açık başlatıyor (Emir, 18 Eki)
        numlock_by_default = true,
        -- sensitivity = -0.25,
        accel_profile = "flat",
    },
    -- Uncomment the section below to enable software cursors; this can help with cursor display or behavior issues
    -- cursor = {
    --     no_hardware_cursors = 1,
    -- },
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left",       action = "float" })
