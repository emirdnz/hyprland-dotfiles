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
    action   = "hyprctl dispatch 'Gizle'",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(28c840)", fg_color = "rgb(003d0a)", size = 14, icon = "□",
    action   = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = 1 })'",
})

-- Simdilik yalniz Dolphin'de cubuk olsun.
hl.window_rule({ match = { class = "negative:^(org\\.kde\\.dolphin)$" }, ["hyprbars:no_bar"] = true })

-- Kucultulen pencereler "special:gizli"de durur. O masaustu ekranda hic acilmasin: acilinca
-- arkasi bulaniklasiyor (dim_special + blur.special) ve Win+Tab'in bulanikligiyla ust uste biniyordu.
local GIZLI = "special:gizli"

local function gizliyiKapat()
    local m = hl.get_active_monitor()
    local acik = m and m.active_special_workspace
    if acik and acik.name == GIZLI then
        hl.dispatch(hl.dsp.workspace.toggle_special("gizli"))
    end
end

local function geriGetir(w)
    local m = hl.get_active_monitor()
    local burasi = m and m.active_workspace
    if not burasi then return end
    hl.dispatch(hl.dsp.window.move({ workspace = burasi.id, window = "address:" .. w.address, follow = false }))
end

-- Sari dugme ve SUPER + H ayni Gizle()'yi kullanir; en son gizlenen pencere akilda tutulur.
-- Adlar global ki dugme "hyprctl dispatch 'Gizle'" ile cagirabilsin, denerken repl'den de calissin.
function Gizle()
    local w = hl.get_active_window()
    if not w then return end
    SonGizlenen = w.address
    hl.dispatch(hl.dsp.window.move({ workspace = GIZLI, window = "address:" .. w.address, follow = false }))
end

-- SUPER + H ac-kapa, en son gizlenen pencere icin: gizliyse geri gelir, aciksa yine gizlenir.
-- Daha once hic gizlenen yoksa (ya da o pencere kapandiysa) ustteki pencereyi gizler.
function GizleGoster()
    local son = SonGizlenen and hl.get_window("address:" .. SonGizlenen)
    if not son then
        Gizle()
        return
    end
    if son.workspace and son.workspace.name == GIZLI then
        geriGetir(son)
        gizliyiKapat()
        hl.dispatch(hl.dsp.focus({ window = "address:" .. son.address }))
    else
        hl.dispatch(hl.dsp.window.move({ workspace = GIZLI, window = "address:" .. son.address, follow = false }))
    end
end
hl.bind("SUPER + H", GizleGoster)

-- Win+Tab ya da baska bir yoldan gizli pencere secilirse gizli masaustunu acma; pencereyi buraya getir.
hl.on("window.active", function(w)
    if w and w.workspace and w.workspace.name == GIZLI then
        geriGetir(w)
        gizliyiKapat()
        hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
    end
end)
