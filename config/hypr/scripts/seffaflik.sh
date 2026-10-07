#!/usr/bin/env bash
# Pencere saydamligini kademeli degistirir.  Kullanim: seffaflik.sh [+|-|sifirla]
DURUM="$HOME/.cache/hypr-seffaflik"
KADEMELER=(1.00 0.95 0.90 0.85 0.80 0.75 0.70 0.60)

i=$(cat "$DURUM" 2>/dev/null || echo 1)

case "${1:-+}" in
  +) i=$((i+1)); ((i >= ${#KADEMELER[@]})) && i=$((${#KADEMELER[@]}-1)) ;;
  -) i=$((i-1)); ((i < 0)) && i=0 ;;
  sifirla) i=1 ;;
esac
echo "$i" > "$DURUM"

AKTIF=${KADEMELER[$i]}
PASIF=$(awk -v a="$AKTIF" 'BEGIN{p=a-0.10; if(p<0.30)p=0.30; printf "%.2f", p}')

hyprctl eval "hl.config({ decoration = { active_opacity = $AKTIF, inactive_opacity = $PASIF } })" >/dev/null

YUZDE=$(awk -v a="$AKTIF" 'BEGIN{printf "%d", a*100}')
command -v notify-send >/dev/null && notify-send -t 1200 "Saydamlık" "%${YUZDE}" 2>/dev/null || true
