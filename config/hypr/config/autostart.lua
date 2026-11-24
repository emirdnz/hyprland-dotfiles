-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("xhost +SI:localuser:root")
    -- Hyprland guncellendiyse pencere cubugu eklentisini yeni surume derler; degismediyse hemen cikar.
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/eklenti-derle.sh")
end)
