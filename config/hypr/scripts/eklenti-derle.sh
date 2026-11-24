#!/usr/bin/env bash
# Pencere cubugu eklentisini (hyprbars) kurulu Hyprland'e gore derler.  Kullanim: eklenti-derle.sh [--zorla]
# Eklenti her Hyprland surumune ayrica derlenmek zorunda; eski derleme yeni Hyprland'de yuklenmez.
# autostart.lua her acilista cagirir: surum degismediyse hemen cikar, degistiyse derleyip ayari yeniden yukler.
set -uo pipefail

KLASOR="$HOME/.cache/hypr-eklentiler"
KAYNAK="$KLASOR/hyprland-plugins"
DAMGA="$KLASOR/derlenen-surum"
KAYIT="$KLASOR/derleme.log"
HEDEF="$HOME/.local/share/hypr-eklentiler/hyprbars.so"

mkdir -p "$KLASOR" "$(dirname "$HEDEF")"
exec 9>"$KLASOR/kilit"
flock -n 9 || exit 0

# Eklenti yalniz Hyprland'e degil, kutuphanelerine de baglidir; biri degisse yeniden derlenir.
SURUM=$(pacman -Q hyprland aquamarine hyprutils hyprgraphics hyprcursor hyprlang 2>/dev/null)
if [[ "${1:-}" != "--zorla" && -f "$HEDEF" && "$(cat "$DAMGA" 2>/dev/null)" == "$SURUM" ]]; then
  exit 0
fi
# Bugun bu surumde denenip olmadiysa her acilista yeniden ugrasma; yarin yine dener.
BUGUN="$(date +%F) $SURUM"
if [[ "${1:-}" != "--zorla" && "$(cat "$KLASOR/olmayan-surum" 2>/dev/null)" == "$BUGUN" ]]; then
  exit 0
fi

exec >>"$KAYIT" 2>&1
echo "== $(date '+%F %T') =="
echo "$SURUM"
notify-send -a "Pencere çubuğu" "Pencere çubuğu hazırlanıyor" "Hyprland güncellenmiş, eklenti yeni sürüme derleniyor (1-2 dk)."

# Acilista Wi-Fi henuz baglanmamis olabilir.
nm-online -q -t 120 || true
if [[ -d "$KAYNAK/.git" ]]; then
  git -C "$KAYNAK" fetch -q origin || echo "fetch olmadi, eldeki kaynakla deneniyor"
else
  git clone -q https://github.com/hyprwm/hyprland-plugins.git "$KAYNAK" || {
    notify-send -u critical -a "Pencere çubuğu" "Pencere çubuğu derlenemedi" "İnternet yok. Bir sonraki açılışta yine denenecek."
    exit 1
  }
fi

# Once Hyprland'in bu surumu icin sabitlenmis kaynak; yoksa en yeni kaynak ve hyprbars'in onceki birkac surumu.
HASH=$(grep -oP 'GIT_COMMIT_HASH\s+"\K[0-9a-f]+' /usr/include/hyprland/src/version.h)
PIN=$(git -C "$KAYNAK" show origin/main:hyprpm.toml | grep -oP "\[\"$HASH\", \"\K[0-9a-f]+")
ADAYLAR=($PIN $(git -C "$KAYNAK" log --format=%h -n 6 origin/main -- hyprbars))

for ADAY in "${ADAYLAR[@]}"; do
  echo "-- deneniyor: $ADAY"
  git -C "$KAYNAK" checkout -q --detach "$ADAY" || continue
  rm -f "$KAYNAK/hyprbars/hyprbars.so"
  if make -s -C "$KAYNAK/hyprbars" all CXX=g++; then
    # Calisan oturum eski dosyayi bellekte tutuyor olabilir; ustune yazmak yerine yenisini yanina koyup degistir.
    cp "$KAYNAK/hyprbars/hyprbars.so" "$HEDEF.yeni" && mv -f "$HEDEF.yeni" "$HEDEF"
    echo "$SURUM" > "$DAMGA"
    echo "-- tamam: $ADAY"
    # Acilistaki yukleme basarisiz olduysa Hyprland ayni yolu reload'da yeniden denemiyor; elle yukle, sonra
    # reload ki pencere-cubugu.lua eklentiyi yuklu gorup ayarlari uygulasin.
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
      hyprctl plugin load "$HEDEF" >/dev/null
      hyprctl reload >/dev/null
    fi
    notify-send -a "Pencere çubuğu" "Pencere çubuğu hazır" "Yeni Hyprland sürümüne derlendi."
    exit 0
  fi
done

echo "$BUGUN" > "$KLASOR/olmayan-surum"
notify-send -u critical -a "Pencere çubuğu" "Pencere çubuğu derlenemedi" \
  "Eklenti bu Hyprland sürümüne henüz uymuyor. Çubuk görünmez, gerisi çalışır; yarın yine denenecek. Kayıt: $KAYIT"
exit 1
