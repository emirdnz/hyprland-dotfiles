# Notlar — neden böyle, nerede tuzak var

Bu dosya, ayarların **gerekçesini** tutar. Yeni makinede aynı hataları yapmamak için.

## ⚠️ Hibrit ekran kartı tuzağı (bu laptopta yaşandı, 20 Eylül 2026)

HP laptop: **AMD Renoir** (iGPU, laptop paneline bağlı) + **NVIDIA GTX 1650** (panele bağlı değil).

**Yaşanan üç ayrı sorun ve çözümleri:**

| Sorun | Sebep | Çözüm |
|---|---|---|
| Açılışta 15 sn siyah ekran, logo yok | Plymouth varsayılan olarak `simpledrm`'e çizmiyor; AMD sürücüsü 7. saniyede geliyor | Çekirdek satırına `plymouth.use-simpledrm` |
| Logo gelip kayboluyor | Ekran kartı devir teslimi (simpledrm → amdgpu) | `MODULES=(amdgpu)` ile erken KMS |
| Giriş ekranı siyah, sistem açılıyor ama görüntü yok | Greeter, AMD kartı meşgulken (Plymouth tutuyor) NVIDIA'ya düşüyor; NVIDIA panele bağlı değil | greetd → `After=plymouth-quit.service` |

**ASLA YAPMA:**
- `AQ_DRM_DEVICES` / `WLR_DRM_DEVICES` ile ekran kartını sabitleme. Kart meşgulken Hyprland
  `CBackend::create() failed!` verip çöküyor, oturum hiç açılmıyor. Yedek karta düşebilmesi lazım.
- `MODULES=(amdgpu)` değişikliğini **tüm çekirdeklere** birden uygulama. LTS çekirdeğinin
  initramfs'ini dokunulmamış bırak — açılış menüsünde hazır kurtarma girdisi olur.

## 🔧 Sistem sorunlarında kurtarma sırası

1. Açılış menüsünde **LTS çekirdeği** (`linux-cachyos-lts`) — el değmemiş initramfs
2. Olmazsa **Snapshots** → son çalışan snapshot
3. Snapshot oturumu `overlay` olarak açılır, **değişiklikler kalıcı değildir**.
   Asıl sistemi düzeltmek için önce bağla:
   ```bash
   sudo mkdir -p /mnt/kurtarma
   sudo mount -o subvol=/@ /dev/nvme0n1p2 /mnt/kurtarma
   # düzeltmeleri /mnt/kurtarma/etc/... içine yap
   ```
4. `.dotfiles-oncesi` / `.bak` uzantılı yedekler her betiğin bıraktığı geri dönüş noktası

## 📋 Bilinçli tercihler

- **Ekran ölçeği** önce %100'dü, %125 de denendi; son karar %120 (aşağıda, Görünüm ayarları).
- **Klavye `tr,us`**, `Alt + Shift` ile geçiş. Türkçe varsayılan.
- **Bar hep görünür, yer ayırır.** Otomatik gizleme denendi: Noctalia "görününce daralt,
  gizlenince genişlet" desteklemiyor — ya hep boşluk var ya hiç yok. Hep görünür daha iyi.
- **Özel masaüstü (scratchpad) kısayolları kaldırıldı** (`Super+S`, `Super+Shift+S`).
  Yanlışlıkla basılınca pencereler tüm masaüstlerinde görünüp kafa karıştırıyordu.
  Gizleme için 5 masaüstü var, `Super + Shift + <rakam>` yeterli.
- **`Super + rakam` = masaüstü** (monitör değil). Tek ekranda monitör kısayolu boşa gidiyordu,
  onlar `Super + Ctrl + Alt + rakam`'a taşındı.
- **Renk şeması `m3-monochrome` DEĞİL.** Gri palette seçili öğe beyaz zemin + açık gri yazı
  üretiyor, Dolphin'de okunmuyor. `m3-tonal-spot` kullan.
- **Tarayıcı Chrome**, `xdg-settings` + `BROWSER` değişkeni birlikte ayarlanmalı;
  sadece biri yetmiyor.

## 🎨 Görünüm ayarları (21 Eylül 2026)

- **Ekran ölçeği %120** (`monitors.lua` → `scale = "1.2"`), **Noctalia arayüz ölçeği 1.0**
  (`config.toml` → `ui_scale`). İkisi çarpışır; ikisini birden büyütme.
- **Renk paleti sabit:** `[theme] source = "builtin"`, `builtin = "Noctalia"`.
  Duvar kağıdı değişince renkler değişmesin diye. Duvar kağıdından renk isteyen
  `source = "wallpaper"` yapar.
- **Duvar kağıdı geçiş efektleri açık:** fade, wipe, zoom, disc, stripes, honeycomb —
  her değişimde rastgele biri, 1.2 sn.
- **Bar:** %75 opak tek şerit. Kapsül ("adacık") düzeni de denendi
  (`[[bar.default.capsule_group]]`), güzel duruyor ama Emir tek şeridi tercih etti.
- **Pencere saydamlığı `Super + O` ile ayarlanır** (`config/hypr/scripts/seffaflik.sh`).
  Çalışması için `windowrules.lua` içindeki `opacity = "1.0 override"` satırları
  yorumda kalmalı — açılırsa tarayıcı ve terminal saydamlığı dinlemez.
- **Takvimde Türkiye resmî tatilleri** var: `[calendar.account.tatiller]`, ICS bağlantısı.
  Anahtar `server_url` (eski `url` değil). Veriler birkaç dakika gecikmeyle gelir.

## 🖥️ Bu makineye özel, yeni makinede DEĞİŞTİR

- `config/noctalia/config.toml` → `[wallpaper] directory` yolu (`kur.sh` kendi ev dizinine çevirir)
- `config/hypr/config/monitors.lua` → ekran ölçeği ve çözünürlük
- `config/uwsm/env` → imleç teması, tarayıcı
- Disk bağlama (`/mnt/Arsiv`) bu repoda yok — fstab makineye özel.
  Format: `UUID=<uuid>  /mnt/<ad>  ext4  defaults,nofail,x-systemd.device-timeout=5s,x-gvfs-show  0 2`
  **`nofail` şart** — disk yoksa sistem yine açılsın.
