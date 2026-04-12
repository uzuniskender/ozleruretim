# Özler UYS — Bilgi Bankası (Tüm Oturumların Özeti)

**Son güncelleme:** 2026-04-12  
**Dosya:** `index.html` (~915 KB) — GitHub Pages'te yayında  
**URL (Yönetim):** `https://uzuniskender.github.io/ozleruretim/index.html`  
**URL (Operatör):** `https://uzuniskender.github.io/ozleruretim/operator.html`  
**URL (Yedek):** `https://uzuniskender.github.io/ozleruretim/backup.html`  
**URL (UYS v3):** `https://uzuniskender.github.io/ozler-uys-v3/` (React rewrite)  
**GitHub Repo:** `https://github.com/uzuniskender/ozleruretim` (Public)  
**GitHub Repo (v3):** `https://github.com/uzuniskender/ozler-uys-v3` (Public)  
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
- **UI tercihi: Filtrelerde açılır pencere (dropdown) + checkbox kullan** (tek seçimli `<select>` yerine çoklu seçimli checkbox grubu tercih edilir)

---

## 2. ONLINE MİMARİ

| Katman | Teknoloji |
|--------|-----------|
| Frontend | GitHub Pages statik hosting |
| Backend | Supabase PostgreSQL (Frankfurt NANO) |
| Veri | `ayarlar` tablosu key-value (uys_data=JSON) + 23 normalize tablo (Faz 2 hibrit) |
| Realtime | Supabase Realtime subscription (10 tablo, INSERT/UPDATE/DELETE) |
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
| Kesim girişi | Üretim Girişi sayfasından yapılır (eski "Kesildi" butonu kaldırıldı) |
| `syncKesimPlanlar` | Kesim planı durumlarını WO üretim loglarından otomatik senkronize eder |
| Sevkiyat | Depo → Sevkiyat sekmesi. Mamul stoktan sevk → `S.sevkler` + stok çıkış |
| `wPct` | `min(100, prod/hedef*100)` |
| Kesim giriş | Bar kapasitesi kadar girilebilir |
| Stok tüketim | `stokUretimIsle` → YM stok |
| Reçete değişikliği | → BOM senkron + WO hedef güncelle |
| `uid()` | localStorage kalıcı monotonic sayaç |
| Çalışma saatleri | 07:00–17:00, C.tesi/Pazar kapalı |
| Şifre | `_uysHash()` cyrb53 hash |
| Sistem Test | Snapshot alır → test → geri yükle butonu |
| Stok Onarım | `stokOnar()` — loglardan eksik stok hareketleri oluşturur |
| Kesim artığı | syncKesimPlanlar: satır tamam → artık malzeme kartı + stok girişi |
| autoZincir | Sipariş → İE → Kesim Planı → MRP → Tedarik otomatik |

---

## 6. VERSİYON GEÇMİŞİ

### v22-online-auth-s8 (2026-04-12)
- operator.html normalize: tablolardan okuma (loadData), tablolara yazma (saveData), JSON blob fallback korunuyor
- operator.html realtime: tablolardan reload (_rtReloadFromTables) — JSON blob'a bağımlılık kaldırıldı
- _WRITE_TABLES: operatörün yazdığı 5 tablo (logs, stokHareketler, fireLogs, operatorNotes, activeWork)
- Operatör bölüm filtre fix: opAd eşleşmesi (operations.bolum yerine)
- Operatör mesaj doğrudan tablo yazma (sendMgrMsg → uys_operator_notes upsert)
- index.html periyodik mesaj poll (15sn) — realtime'a ek güvenlik ağı

---

## 13. UYS v3 — REACT REWRITE

**Repo:** `https://github.com/uzuniskender/ozler-uys-v3`
**URL:** `https://uzuniskender.github.io/ozler-uys-v3/`
**Stack:** React 19 + Vite + TypeScript + Tailwind CSS v4 + Zustand + Supabase
**Deploy:** GitHub Pages + GitHub Actions (auto-deploy on push)
**Geliştirme:** GitHub Desktop ile local → commit → push

### Mimari
| Katman | Teknoloji |
|--------|-----------|
| Frontend | React 19 + Vite + TypeScript (strict) |
| UI | Tailwind CSS v4 + Lucide Icons |
| State | Zustand (19 tablo mapper, loadAll) |
| Backend | Supabase (aynı 23 tablo, normalize) |
| Auth | Supabase Auth (email/password) |
| Realtime | Supabase Realtime (7 tablo subscription) |
| Toast | Sonner |
| Excel | SheetJS (xlsx) — dynamic import |
| Routing | React Router v7 (HashRouter) |
| Deploy | GitHub Actions → GitHub Pages |

### Dizin Yapısı
```
ozler-uys-v3/
├── src/
│   ├── App.tsx              ← Router + Auth + Realtime
│   ├── main.tsx             ← Entry point
│   ├── index.css            ← Tailwind + koyu tema
│   ├── components/layout/   ← Sidebar, Topbar, Layout
│   ├── hooks/               ← useAuth, useRealtime
│   ├── lib/                 ← supabase.ts, utils.ts
│   ├── store/               ← Zustand store + 19 mapper
│   ├── types/               ← TypeScript tip tanımları
│   └── pages/               ← 17 sayfa
├── .github/workflows/deploy.yml
├── .env.local               ← Supabase credentials
└── vite.config.ts           ← base: '/ozler-uys-v3/'
```

### Sayfalar (18 toplam)
| Sayfa | Route | Durum |
|-------|-------|-------|
| Login | /login | ✅ Tam |
| Dashboard | / | ✅ Tam (kartlar, mesajlar, aktif çalışmalar, terminler) |
| Siparişler | /orders | ✅ CRUD + filtre + detay + Excel |
| İş Emirleri | /work-orders | ✅ Gruplu görünüm + ilerleme |
| Üretim Girişi | /production | ✅ Form (miktar + fire + operatör + stok) |
| Kesim Planları | /cutting | ✅ Liste + durum |
| Depolar | /warehouse | ✅ Anlık stok + hareketler |
| Sevkiyat | /shipment | ✅ Liste |
| Ürün Ağaçları | /bom | ✅ Liste + ağaç detay |
| Reçeteler | /recipes | ✅ Liste + kırılım detay |
| Malzeme Listesi | /materials | ✅ 536 kayıt + tip filtre |
| Operasyonlar | /operations | ✅ CRUD |
| İstasyonlar | /stations | ✅ Liste + operasyon eşleme |
| Operatörler | /operators | ✅ CRUD + bölüm + aktif/pasif |
| Tedarikçiler | /suppliers | ✅ Liste |
| Duruş Kodları | /downtime-codes | ✅ Kategorili + CRUD |
| Raporlar | /reports | ✅ 4 sekme (Özet, Günlük, Fire, Operasyon) |
| Veri Yönetimi | /data | ✅ Tablo özeti + JSON yedek |

### Store Mapper (snake_case ↔ camelCase)
19 tablo için bidirectional mapping: orders, workOrders, logs, materials, operations, stations, operators, recipes, bomTrees, stokHareketler, cuttingPlans, tedarikler, tedarikciler, durusKodlari, customers, sevkler, operatorNotes, activeWork, fireLogs

### v3 Backlog
- [ ] Sipariş düzenleme
- [ ] autoZincir (sipariş → İE → kesim → MRP → tedarik)
- [ ] MRP hesaplama modal
- [ ] Kesim planı detay + optimizasyon
- [ ] Sevkiyat oluşturma formu
- [ ] Operatör paneli (/operator route)
- [ ] Raporlara grafik (Recharts)
- [ ] PDF çıktı (iş emri, sevk irsaliyesi)
- [ ] Toplu sipariş Excel import
- [ ] Çakışma yönetimi (concurrent edit)

### v22-online-auth-s7 (2026-04-11 oturum 7)
- Realtime Sync: Supabase Realtime subscription, 10 kritik tablo (logs, workOrders, orders, stokHareketler, operatorNotes, activeWork, fireLogs, tedarikler, sevkler, kesimPlanlari)
- index.html: INSERT/UPDATE/DELETE eventleri → S dizilerine anında yansır, aktif sayfa otomatik yenilenir (debounce 800ms)
- operator.html: Realtime event → JSON blob reload → render (debounce 1500ms)
- _rtPaused: saveS/saveData sırasında 2sn kendi eventlerini yoksayar (echo prevention)
- realtime_enable.sql: Supabase publication'a 10 tablo ekleme

### v22-online-auth-s6 (2026-04-11 oturum 6)
- Normalize Faz 1: 23 Supabase tablosu oluşturuldu (supabase_normalize.sql), migration aracı (normalize.html) ile veri taşındı
- Normalize Faz 2: loadS() tablolardan okur (fallback: JSON blob), saveS() hem JSON blob'a hem tablolara yazar
- _TM table map: 19 tablo için camelCase↔snake_case bidirectional mapping
- _loadFromTables(): Promise.all ile paralel tablo okuma, en az 5 tablo başarılıysa güven
- _saveToTables(): dirty detection (_qHash), sadece değişen tablolar sync, upsert+delete
- Güvenlik: JSON blob hala yazılıyor (fallback), tablolar arka planda senkronize

### v22-online-auth-s5 (2026-04-11 oturum 5)
- Operatör Mesajları Paneli: Dashboard'da okunmamış mesajlar tablosu, tek/toplu okundu işaretle, silme
- activeWork Canlı Takip: Dashboard'da hangi operatör hangi İE'de çalışıyor, süre hesabı
- Toplu Sipariş Girişi (Excel): Siparişler sayfasında "📤 Toplu Yükle", reçete otomatik eşleme, önizleme, mevcut atlama, İE otomatik oluşturma
- İstek #18: Fire → sipariş dışı İE teklifi (fire kaydı sonrası telafi İE açma modalı, FIRE- prefix, bagimsiz+siparisDisi flag)
- İstek #19: MRP stoktan ver — zaten mevcut (stok + açık tedarik brütten düşülüyor, net ihtiyaç hesaplanıyor)
- Sevkiyat nav fix: sidebar linki warehouse/sevkiyat sekmesine yönleniyor + badge güncelleme
- Dashboard badge: okunmamış mesaj sayısı 📩 göstergesi

### v22-online-auth-s4 (2026-04-11)
- Stok onarım fonksiyonu (stokOnar): eksik stok hareketlerini loglardan geriye dönük oluşturur
- syncKesimPlanlar artık oluşturduğunda otomatik saveS()
- Kesim artığı: levha (boy×en) + boy kesim artıkları otomatik malzeme kartı + stok girişi
- Sevkiyat: sipariş bazlı miktar kontrolü (kalan hesabı, aşım engeli, siparişsiz sevk)
- Operatör giriş: bölüm → operatör iki aşamalı dropdown (index.html + operator.html)
- Operatör paneli stok gösterimi: stk/ihtiyaç tam sayı formatı (BOM ratio yerine)
- Durum filtreleri: fd-drop CSS sınıfı, temiz dropdown tasarım
- Çoklu seçim checkbox: touched flag ile ilk yükleme sorunu çözüldü

### v22-online-auth-s3 (2026-04-10 oturum 3)
- İstek #21: Tam otomatik zincir (autoZincir): Sipariş → İE → Kesim Planı → MRP → Tedarik
- Üst bar durum göstergeleri: KESİM/MRP/TEDARİK kırmızı-yeşil badge (tıklanabilir)
- Fire optimizasyon sonsuz döngü fix (_maxLoop=50 limiti)
- Performans: _suppressSave (test sırasında tek save), lookup map, debounce, yield
- Sevkiyat: Sipariş bazlı miktar kontrolü, kalan hesabı, siparişsiz sevk uyarısı
- Sipariş + İE filtresi: Çoklu seçimli checkbox (dropdown select yerine)
- Fabrika sıfırlamaya fireLogs/operatorNotes/activeWork eklendi

### v22-online-auth-s2 (2026-04-10 oturum 2)
- Operatör paneli log uyumu: `operatorId` ↔ `operatorlar` dashboard/rapor senkronu
- Sistem test: snapshot + geri yükleme mekanizması
- `_sistemTestTemizle` bug fix: `S.kesimPlanlari=[]` kaldırıldı, testWoIds sıralama düzeltildi
- İstek #23 (8 madde):
  1. Kesim planı tamamlananlar varsayılan gizli + filtre toggle
  2. Sevkiyat modülü: `S.sevkler`, Depo → Sevkiyat sekmesi, sevk emri + stok çıkış
  3. Kesim girişi üretim girişine yönlendirildi, "Kesildi" butonları kaldırıldı
  4. `syncKesimPlanlar` WO prod sync (k.tamamlandi otomatik güncelleme)
  5. İE seçim toolbar `refreshSel` fix
  6. Tümünü aç/kapa butonları gruplama moduna göre göster/gizle
  7. Operatör çalışma saati detay: satır bazlı format
  8. Stok girişi: arama inputu (dropdown yerine)

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

### İstek #21 — Tam Otomatik Üretim Zinciri
- [x] Sipariş → İE → Kesim Planı → MRP → Tedarik otomatik zincir (autoZincir)
- [x] Kesim planı: fire optimize, öneriler otomatik uygulanmış
- [x] Tedarik listesinde sipariş eşleme (autoTedarikOlustur)
- [x] Üst bar durum göstergeleri: Kesim (🔴/🟢) | MRP (🔴/🟢) | Tedarik (🔴/🟢)
- [x] Kesim planı: yeni sipariş gelince mevcut planı güncelle/birleştir (zaten mevcut — mevcutPlan check)

### Diğer
- [x] Normalize veri geçişi (Faz 1: tablolar + migration, Faz 2: loadS/saveS hibrit)
- [x] Realtime senkronizasyon (Supabase Realtime subscription, 10 tablo)
- [x] Yönetici: operatör mesajları paneli
- [x] Yönetici: activeWork canlı takip
- [ ] Misafir girişi (read-only)
- [x] Toplu sipariş girişi (Excel)
- [ ] islemSure reçeteye girilmeli
- [x] İstek #18: Fire → sipariş dışı iş emri
- [x] İstek #19: MRP stoktan ver (zaten mevcut)
- [ ] Repo Private yapma
