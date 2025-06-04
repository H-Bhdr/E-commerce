# e_commerce_project

## Genel Tanım
Bu proje, Flutter ile geliştirilmiş, temel e-ticaret işlevlerine sahip, modern ve yenilikçi özellikler barındıran bir mobil uygulamadır. Kullanıcılar ürünleri görüntüleyebilir, favorilere ekleyebilir, ürün ekleyebilir, fiyat değişikliklerinden anlık olarak haberdar olabilir ve yapay zeka ile ürün önerisi alabilir.

## Temel Özellikler
- **Kullanıcı Girişi:** Google ile kimlik doğrulama ve kullanıcı rol yönetimi (satıcı/müşteri).
- **Ürün Yönetimi:** Ürün ekleme, listeleme, favorilere ekleme/çıkarma.
- **Fiyat Güncelleme:** USD/TRY kuru değişimine göre ürün fiyatlarının otomatik güncellenmesi.
- **Favori Ürünler:** Favori ürünlerde fiyat değişikliği olduğunda bildirim.
- **Yapay Zeka Destekli Ürün Önerisi:** Gemini API ile anahtar kelimeye göre veya rastgele ürün önerisi.
- **Sensör Tabanlı Öneri:** Cihazı sallayarak rastgele ürün önerisi alma.
- **Favori Paylaşımı:** Aynı ağdaki cihazlar arasında favori ürünlerin paylaşımı.
- **Çevrimdışı Desteği:** Ürünler ve favoriler lokal veritabanında saklanır, çevrimdışı erişim sağlanır.

## Mimari ve Özellikler (Başlık Bazında)

### 1. Storage / Basic Data
- Ürünler, favoriler ve kullanıcı bilgileri hem lokal veritabanında hem de bulut (Firebase Firestore) üzerinde saklanır.
- Ürün modeli (`Product`) ile temel veri yapısı tanımlanmıştır.

### 2. Local Database (Room / CoreData / Document)
- Flutter’da genellikle kullanılan `sqflite` veya benzeri bir local database ile ürünler ve favoriler cihazda saklanır.
- `lib/data/local/local_db.dart` dosyasında local veritabanı işlemleri yönetilir.

### 3. RESTFul API (CRUD)
- Ürünler, Firestore REST API üzerinden çekilir ve güncellenir.
- Ürün ekleme, güncelleme ve silme işlemleri hem lokal hem de bulut üzerinde yapılabilir.
- Favori paylaşımı için cihazlar arası HTTP tabanlı mini REST API sunucusu başlatılır.

### 4. UI (Compose / SwiftUI)
- Tüm arayüz Flutter ile yazılmıştır.
- Modern, responsive ve kullanıcı dostu ekranlar: Ana sayfa, ürün ekleme, favoriler, profil, giriş ekranı vb.
- Material Design bileşenleri ve özelleştirilmiş temalar kullanılır.

### 5. Background Process / Task
- USD/TRY kuru belirli aralıklarla arka planda çekilir ve fiyatlar otomatik güncellenir (`CurrencyBackgroundService`).
- Fiyat değişiklikleri arka planda işlenir ve gerekirse bildirim tetiklenir.

### 6. Broadcast Receiver / NSNotificationCenter
- Fiyat değişikliği gibi önemli olaylar için uygulama içinde `ValueNotifier` ve bildirim servisleriyle (örn. `NotificationService.broadcastPriceChange`) dinleyiciler tetiklenir.
- Kullanıcıya hem native bildirim hem de uygulama içi SnackBar ile bilgi verilir.

### 7. Sensor (Motion / Location / Environment)
- Cihazın hareket sensörü (accelerometer) ile sallama hareketi algılanır ve rastgele ürün önerisi sunulur.
- `lib/Sensor/sensor.dart` dosyasında sensör entegrasyonu yapılmıştır.

### 8. Connectivity (BLE / Wifi / Cellular Network / USB / NFC)
- Favori ürünler, aynı WiFi ağı üzerindeki cihazlar arasında paylaşılabilir (mini HTTP sunucu ve istemci ile).
- Uygulama, internet bağlantısı durumunu kontrol ederek çevrimdışı/çevrimiçi veri yönetimi yapar.

### 9. Authorization (OAuth / OpenID / JWT)
- Google ile OAuth tabanlı kimlik doğrulama yapılır.
- Firebase Auth ile kullanıcı oturumu ve rol yönetimi sağlanır.
- JWT token’ı ile güvenli oturum yönetimi uygulanır.

### 10. Cloud Service (AI)
- Google Gemini API ile yapay zeka destekli ürün önerisi ve otomatik ürün ekleme alanı sunulur.
- Kullanıcıdan alınan anahtar kelimeye göre AI ile ürün adı, açıklama, görsel ve fiyat önerisi alınır.

## Ana Dosya ve Servisler
- `lib/main.dart`: Uygulama başlangıcı, tema, ana navigasyon.
- `lib/views/home.dart`: Ana sayfa, ürün listeleme, AI öneri, kur testi.
- `lib/views/add_product.dart`: Ürün ekleme, AI ile otomatik doldurma.
- `lib/views/favorites_view.dart`: Favori ürünler, paylaşım, ağ üzerinden favori transferi.
- `lib/services/background_service.dart`: Kur güncelleme ve fiyatların otomatik güncellenmesi.
- `lib/services/notification_service.dart`: Fiyat değişikliği bildirimleri.
- `lib/services/auth_service.dart`: Google ile giriş ve kullanıcı yönetimi.
- `lib/services/cloud_service.dart`: Gemini API ile AI entegrasyonu.
- `lib/models/porductModel.dart`: Ürün veri modeli.
- `lib/data/local/local_db.dart`: Lokal veritabanı işlemleri.

## Dosya Yapısı (Kısaca)
- `lib/` altında views (ekranlar), services (servisler), models (veri modelleri), data (veritabanı), components (ortak bileşenler) klasörleri bulunur.
- `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/` platform klasörleri mevcuttur.

## Kurulum ve Çalıştırma
1. Gerekli Flutter ve Dart ortamı kurulu olmalı.
2. `pub get` ile bağımlılıklar yüklenir.
3. Firebase ve .env dosyası ayarlanmalı.
4. Uygulama Flutter ile başlatılır:
   ```sh
   flutter run
   ```

## Notlar
- Proje, modern e-ticaret uygulamalarında bulunabilecek birçok yenilikçi özelliği (AI, sensör, ağ paylaşımı, otomatik fiyat güncelleme) bir arada sunar.
- Kod yapısı modüler ve geliştirilebilir şekilde tasarlanmıştır.

---
