#!/usr/bin/env bash
# Sistem seviyesi ayarlar (root gerekir).  Kullanim:  sudo bash sistem/sistem-kur.sh
# DIKKAT: her adim tek tek sorar. Makinen farkliysa "h" de, gec.
set -uo pipefail
[[ $EUID -eq 0 ]] || { echo "sudo ile calistir"; exit 1; }

sor() { read -rp "$1 [e/h] " c; [[ "$c" == "e" ]]; }

echo "=========================================="
echo "  Sistem ayarlari"
echo "  Once NOTLAR.md'yi oku - hangisi neden var orada yaziyor."
echo "=========================================="
echo

# --- 1. Acilis ekrani: uretici logosu + sessiz acilis ---
if sor "1) Acilista uretici logosu (Plymouth bgrt) + sessiz acilis kurulsun mu?"; then
  cp -n /etc/default/limine /etc/default/limine.dotfiles-oncesi 2>/dev/null || true
  python3 - <<'PY'
import re
p = "/etc/default/limine"
try:
    s = open(p).read()
except FileNotFoundError:
    print("    /etc/default/limine yok - bu makine Limine kullanmiyor, atlandi."); raise SystemExit
flags = ["plymouth.use-simpledrm", "loglevel=3", "rd.udev.log_level=3",
         "rd.systemd.show_status=false", "systemd.show_status=false",
         "vt.global_cursor_default=0"]
def fix(m):
    line = m.group(0)
    for f in flags:
        key = f.split("=")[0]
        if not re.search(r"(?<![\w.-])" + re.escape(key) + r"(=|\b)", line):
            line = line.replace("quiet", "quiet " + f, 1)
    return line
s = re.sub(r'KERNEL_CMDLINE\[default\]\+?=".*?"', fix, s)
open(p, "w").write(s)
print("   ", [l for l in s.splitlines() if "KERNEL_CMDLINE[default]" in l][0])
PY
  plymouth-set-default-theme -R bgrt || echo "    plymouth yok, atlandi"
  command -v limine-update >/dev/null && limine-update || true
fi

# --- 2. Hibrit ekran kartinda erken KMS ---
echo
echo "2) ERKEN EKRAN KARTI SURUCUSU (amdgpu)"
echo "   Sadece AMD iGPU + NVIDIA hibrit laptoplarda gerekli."
echo "   Logonun acilis boyunca sabit kalmasini saglar."
echo "   RISK: yanlis makinede siyah ekran. LTS cekirdegi dokunulmadan birakilir,"
echo "   acilmzsa menuden onu secersin."
if sor "   Uygulansin mi?"; then
  cp -n /etc/mkinitcpio.conf /etc/mkinitcpio.conf.dotfiles-oncesi 2>/dev/null || true
  sed -i 's/^MODULES=()/MODULES=(amdgpu)/' /etc/mkinitcpio.conf
  grep '^MODULES' /etc/mkinitcpio.conf
  ANA=$(ls /etc/mkinitcpio.d/*.preset 2>/dev/null | grep -v lts | head -1)
  [ -n "$ANA" ] && mkinitcpio -p "$(basename "$ANA" .preset)"
  command -v limine-update >/dev/null && limine-update || true
fi

# --- 3. Giris ekrani siyah kalmasin ---
if sor "3) Giris ekrani Plymouth'tan sonra baslasin mi? (siyah ekran onlemi)"; then
  mkdir -p /etc/systemd/system/greetd.service.d
  cat > /etc/systemd/system/greetd.service.d/gpu.conf <<'EOF'
[Unit]
# Plymouth ekran kartini birakmadan giris ekrani baslamasin
After=plymouth-quit.service plymouth-quit-wait.service
EOF
  systemctl daemon-reload
  echo "    kuruldu"
fi

# --- 4. Anahtarlik otomatik acilsin ---
if sor "4) Giriste anahtarlik otomatik acilsin mi? (Chrome parola sormasin)"; then
  F=/etc/pam.d/greetd
  if [ -f "$F" ] && ! grep -q pam_gnome_keyring "$F"; then
    cp -n "$F" "$F.dotfiles-oncesi"
    python3 - "$F" <<'PY'
import sys
p = sys.argv[1]
out, a, s = [], False, False
for l in open(p).read().splitlines():
    out.append(l)
    if not a and l.startswith("auth") and "system-local-login" in l:
        out.append("auth       optional     pam_gnome_keyring.so"); a = True
    if not s and l.startswith("session") and "pam_systemd.so" in l:
        out.append("session    optional     pam_gnome_keyring.so auto_start"); s = True
open(p, "w").write("\n".join(out) + "\n")
PY
    echo "    kuruldu"
  else
    echo "    zaten var ya da greetd yok, atlandi"
  fi
fi

# --- 5. Klavye ---
if sor "5) Sistem klavyesi Turkce (tr,us + Alt+Shift) olsun mu?"; then
  localectl set-x11-keymap "tr,us" pc105 "" grp:alt_shift_toggle && echo "    ayarlandi"
fi

# --- 6. Tek oturum secenegi ---
if sor "6) Giris ekraninda sadece 'Hyprland (uwsm-managed)' gorunsun mu?"; then
  F=/usr/share/wayland-sessions/hyprland.desktop
  if [ -f "$F" ]; then
    cp -n "$F" "$F.dotfiles-oncesi"
    grep -q '^NoDisplay=' "$F" && sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$F" || echo 'NoDisplay=true' >> "$F"
    echo "    ayarlandi"
  fi
fi

# --- 7. Bluetooth kulaklik (AirPods) kopmasin ---
# Laptopta (18 Eki) AirPods baglanip ses baslamadan kopuyordu; klasik modla duzeldi.
# Bedeli: yalniz dusuk enerjili (BLE) cihazlar (bazi fare/klavye) baglanmaz. Boyle cihazin varsa "h" de.
if sor "7) Bluetooth yalniz klasik modda calissin mi (AirPods icin)?"; then
  F=/etc/bluetooth/main.conf
  cp -n "$F" "$F.dotfiles-oncesi"
  if grep -qE '^\s*ControllerMode\s*=' "$F"; then
    sed -i -E 's/^\s*ControllerMode\s*=.*/ControllerMode = bredr/' "$F"
  else
    sed -i '0,/^\[General\]/s//[General]\nControllerMode = bredr/' "$F"
  fi
  systemctl restart bluetooth && echo "    ayarlandi"
fi

# --- 8. Ayda bir disk taramasi ---
if sor "8) Disk ayda bir bozulmaya karsi taransin mi (btrfs scrub)?"; then
  if findmnt -no FSTYPE / | grep -q btrfs; then
    systemctl enable --now btrfs-scrub@-.timer && echo "    ayarlandi"
  else
    echo "    disk btrfs degil, gecildi"
  fi
fi

echo
echo "BITTI. Yeniden baslat."
echo "Sorun cikarsa: acilis menusunden LTS cekirdegini ya da bir snapshot'i sec,"
echo "sonra .dotfiles-oncesi uzantili yedekleri geri yukle."
