#!/usr/bin/env bash
# Kullanici ayarlarini yeni makineye kurar.  Kullanim:  bash kur.sh
# Sistem ayarlari icin ayrica:  sudo bash sistem/sistem-kur.sh
set -euo pipefail

KOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARIH=$(date +%Y%m%d-%H%M%S)
YEDEK="$HOME/.config-yedek-$TARIH"

echo "=========================================="
echo "  Hyprland + Noctalia ayarlari kuruluyor"
echo "=========================================="
echo

echo "==> 1/4  Mevcut ayarlarin yedegi: $YEDEK"
mkdir -p "$YEDEK"
for k in hypr noctalia kitty alacritty gtk-3.0 gtk-4.0 uwsm; do
  [ -e "$HOME/.config/$k" ] && cp -r "$HOME/.config/$k" "$YEDEK/" && echo "    yedeklendi: $k"
done

echo "==> 2/4  Ayarlar kopyalaniyor"
mkdir -p "$HOME/.config"
for k in hypr noctalia kitty alacritty gtk-3.0 gtk-4.0 uwsm; do
  if [ -d "$KOK/config/$k" ]; then
    rm -rf "$HOME/.config/$k"
    cp -r "$KOK/config/$k" "$HOME/.config/"
    echo "    kuruldu: $k"
  fi
done

echo "==> 3/4  Duvar kagitlari"
mkdir -p "$HOME/Pictures/Wallpapers"
cp -n "$KOK"/duvar-kagitlari/*.jpg "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
echo "    $(ls "$HOME/Pictures/Wallpapers" | wc -l) resim"
# Noctalia duvar kagidi klasorunu bu kullanicinin ev dizinine cevir
NOC="$HOME/.config/noctalia/config.toml"
[ -f "$NOC" ] && sed -i "s#^directory = \".*/Pictures/Wallpapers\"#directory = \"$HOME/Pictures/Wallpapers\"#" "$NOC"

echo "==> 4/4  Makineye ozel ayarlari kontrol et"
echo
echo "    !! Asagidakiler MAKINEYE OZEL - elle kontrol et:"
echo "       config/hypr/config/monitors.lua   -> ekran olcegi (scale)"
echo "       config/uwsm/env                   -> tarayici, imlec temasi"
echo
echo "BITTI."
echo "Hyprland icindeysen:  hyprctl reload  ·  noctalia msg config-reload"
echo "Degilsen oturumu yeniden ac."
echo
echo "Geri almak icin:  rm -rf ~/.config/{hypr,noctalia,kitty,alacritty,gtk-3.0,gtk-4.0,uwsm}"
echo "                  cp -r $YEDEK/* ~/.config/"
