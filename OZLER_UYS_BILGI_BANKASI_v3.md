# Özler UYS — Bilgi Bankası (Tüm Oturumların Özeti)

**Son güncelleme:** 2026-04-10  
**Dosya:** `index.html` (~880 KB) — GitHub Pages'te yayında  
**URL (Yönetim):** `https://uzuniskender.github.io/ozleruretim/index.html`  
**URL (Operatör):** `https://uzuniskender.github.io/ozleruretim/operator.html`  
**URL (Yedek):** `https://uzuniskender.github.io/ozleruretim/backup.html`  
**GitHub Repo:** `https://github.com/uzuniskender/ozleruretim` (Public)  
**Supabase Projesi:** `ozler-uys` (kudpuqqxxkhuxhhxqbjw, Frankfurt, NANO)  
**Publishable Key:** `sb_publishable_duHYEBjaaf4wDQvZLf66hQ_tSmyDM4p`  
**Veri saklama:** Supabase `ayarlar` tablosu (key='uys_data') + localStorage cache  
**Yedekleme:** Otomatik günlük (uys_backup_YYYY-MM-DD), 30 gün saklanır  
**Auth:** Supabase Auth + RLS aktif  
**Şifreler:** Kodda hash'lenmiş (cyrb53). Plaintext yok.

---

## 1. YANIT KURALLARI (CLAUDE İÇİN)

- Sayısal doğrulama gerektiren sorularda rakamları **hesapla/simüle et**, sonra cevap ver
- Emin değilsen "kontrol edeyim" de, tahmin etme
- **UYS şifrelerini asla konuşmada yazma/gösterme/tekrarlama**
- **Supabase Auth şifrelerini asla konuşmada yazma** — operatör servis hesabı dahil
- BOM reçetelerinde hammadde seçimi: `pieces = floor(raw_length / cut_length)` ve waste % hesapla

---

## 2. ONLINE MİMARİ

| Katman | Teknoloji |
|--------|-----------|
| Frontend | GitHub Pages statik hosting |
| Backend | Supabase PostgreSQL (Frankfurt NANO) |
| Veri | `ayarlar` tablosu key-value (uys_data=JSON) |
| Auth | Supabase Auth + RLS (2 kullanıcı: admin gmail, operatör servis) |
| Yedekleme | Otomatik günlük, 30 gün saklama |

### Auth Akışı

| Sayfa | Auth |
|-------|------|
| index.html | Gmail + şifre login ekranı |
| operator.html | Otomatik servis hesabı + sicil no |
| backup.html | Prompt ile login |

### Dosya Yapısı (GitHub)
```
ozleruretim/
├── index.html          ← Ana UYS (Auth + Yedekleme)
├── operator.html       ← Operatör mobil paneli
├── backup.html         ← Yedek yönetimi
├── migrate.html        ← Veri aktarım aracı
└── README.md
```

---

## 3. OPERATÖR PANELİ

- Mobil uyumlu koyu tema, 3 sekme (Üretim/Emirler/Özet)
- Giriş: sicil no (varsayılan 1234), alfabetik liste
- Bölüm bazlı: operatör sadece kendi bölümünü görür
- Çoklu operatör + çoklu zaman aralığı
- Çoklu duruş kaydı (düzenlenebilir)
- Fire/hurda girişi
- İşe Başla/Bitir sistemi (çoklu iş, activeWork[])
- Stok kontrolü (0 → engel, kısmi → max notu)
- Saat validasyonu (gün atlaması, ilave op/duruş sınırları)
- Yöneticiye mesaj (operatorNotes[])
- Yönetici notları (w.yoneticiNot)
- Tip filtreleri: Bitmiş Ürün / Ara İşlem / Kesim
- Tamamlanan iş emirleri 3 gün sonra gizlenir

---

## 4. YEDEKLEME

- Otomatik: her saveS()'de günde 1 kez → `uys_backup_YYYY-MM-DD`
- 30 günden eski yedekler otomatik silinir
- backup.html: liste, indir, geri yükle, sil, dosyadan yükle
- Geri yükleme öncesi otomatik güvenlik yedeği

---

## 5. MİMARİ KURALLAR

| Kural | Açıklama |
|-------|----------|
| Kesim planı olmadan MRP çalışmaz | `_mrpBloke=true` |
| MRP akışı | Sipariş → Kesim Planı → MRP → Tedarik → Üretim |
| `wPct` | `min(100, prod/hedef*100)` |
| Kesim giriş | Bar kapasitesi kadar girilebilir |
| Stok tüketim | `stokUretimIsle` → YM stok |
| Reçete değişikliği | → BOM senkron + WO hedef güncelle |
| `uid()` | localStorage kalıcı monotonic sayaç |
| Çalışma saatleri | 07:00–17:00, C.tesi/Pazar kapalı |
| Şifre | `_uysHash()` cyrb53 hash |

---

## 6. VERSİYON GEÇMİŞİ

### v22-online-auth (2026-04-10)
- Supabase Auth + RLS aktif
- Otomatik yedekleme + backup.html
- Operatör paneli v3 (12+ özellik)

### v22-online (2026-04-09)
- GitHub Pages + Supabase deploy
- Veri aktarım aracı (migrate.html)

### v22 (2026-04-09)
- Güvenlik katmanı, şifre hash'leme

### v21 (2026-04-08/09)
- BOM/reçete, PDF doğrulama

### v20 (2026-04-07/08)
- Refactor, uid fix, test modu

---

## 7. BACKLOG

- [ ] Normalize veri geçişi (tek JSON → ayrı tablolar)
- [ ] Realtime senkronizasyon
- [ ] Yönetici: operatör mesajları paneli
- [ ] Yönetici: activeWork canlı takip
- [ ] Misafir girişi (read-only)
- [ ] Toplu sipariş girişi (Excel)
- [ ] islemSure reçeteye girilmeli
- [ ] İstek #18: Fire → sipariş dışı iş emri
- [ ] İstek #19: MRP stoktan ver
- [ ] Repo Private yapma
