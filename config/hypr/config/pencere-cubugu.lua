-- Pencere cubugu (hyprbars eklentisi): sol ustte kapat / kucult / buyut dugmeleri.
-- Simdilik yalniz Dolphin'de; begenilirse asagidaki "no_bar" kurali kaldirilip her pencereye acilir.
-- Cubuktan tutup surukleyince pencere tasinir, cubuga cift tiklayinca buyur.

local EKLENTI = os.getenv("HOME") .. "/.local/share/hypr-eklentiler/hyprbars.so"
hl.plugin.load(EKLENTI)

hl.config({
    plugin = {
        hyprbars = {
            bar_height            = 26,
            bar_color             = "rgba(1e1e24ee)",
            ["col.text"]          = "rgba(ffffffcc)",
            bar_text_size         = 10,
            bar_text_font         = "Sans",
            bar_buttons_alignment = "left",
            bar_padding           = 10,
            bar_button_padding    = 8,
            on_double_click       = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = 1 })'",
        },
    },
})

-- Sola hizali: ilk eklenen en solda.
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(ff5f57)", fg_color = "rgb(4d0000)", size = 14, icon = "✕",
    action   = "hyprctl dispatch 'hl.dsp.window.close()'",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(febc2e)", fg_color = "rgb(5a3d00)", size = 14, icon = "–",
    action   = "hyprctl dispatch 'hl.dsp.window.move({ workspace = \"special:gizli\", follow = false })'",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(28c840)", fg_color = "rgb(003d0a)", size = 14, icon = "□",
    action   = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = 1 })'",
})

-- Simdilik yalniz Dolphin'de cubuk olsun.
hl.window_rule({ match = { class = "negative:^(org\\.kde\\.dolphin)$" }, ["hyprbars:no_bar"] = true })

-- Kucultulen pencereleri geri getir: SUPER + H, gizlenenlerin hepsi bu masaustune doner.
hl.bind("SUPER + H", function()
    local burasi = hl.get_active_workspace()
    if not burasi then return end
    for _, w in ipairs(hl.get_workspace_windows("special:gizli") or {}) do
        hl.dispatch(hl.dsp.window.move({ workspace = burasi.id, window = "address:" .. w.address, follow = false }))
    end
end)
