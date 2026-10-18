#!/usr/bin/env bash
# Ekran kaydini baslatir / durdurur (wf-recorder).  Kullanim: kayit.sh  (Super + Shift + R)
KLASOR="$HOME/Videos"

if pgrep -x wf-recorder >/dev/null; then
  pkill -INT -x wf-recorder
  sleep 0.5
  notify-send -t 3000 "Ekran kaydı" "Kaydedildi: $(ls -t "$KLASOR"/kayit-*.mp4 2>/dev/null | head -1 | xargs -r basename)"
  exit 0
fi

command -v wf-recorder >/dev/null || { notify-send "Ekran kaydı" "wf-recorder kurulu değil: sudo pacman -S wf-recorder"; exit 1; }
mkdir -p "$KLASOR"
notify-send -t 1500 "Ekran kaydı" "Başladı — durdurmak için Super + Shift + R"
sleep 1.7   # bildirim videoya girmesin
wf-recorder -c libx264 -p preset=veryfast -p crf=20 \
  -f "$KLASOR/kayit-$(date +%Y%m%d-%H%M%S).mp4" >/dev/null 2>&1 &
