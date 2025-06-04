# e_commerce_project

## Genel Tanım
Bu proje, Flutter ile geliştirilmiş, temel e-ticaret işlevlerine sahip, modern ve yenilikçi özellikler barındıran bir mobil uygulamadır. Kullanıcılar ürünleri görüntüleyebilir, favorilere ekleyebilir, satıcılar ürün ekleyebilir, fiyat değişikliklerinden anlık olarak haberdar olabilir ve yapay zeka ile ürün önerisi alabilir.

## Temel Özellikler
- **Kullanıcı Girişi:** Google ile kimlik doğrulama ve kullanıcı rol yönetimi (satıcı/müşteri).
- **Ürün Yönetimi:** Ürün ekleme, listeleme, favorilere ekleme/çıkarma.
- **Fiyat Güncelleme:** USD/TRY kuru değişimine göre ürün fiyatlarının otomatik güncellenmesi.
- **Favori Ürünler:** Favori ürünlerde fiyat değişikliği olduğunda bildirim.
- **Yapay Zeka Destekli Ürün Önerisi:** Gemini API ile anahtar kelimeye göre veya rastgele ürün önerisi. satıcılar için ürün açıklama, başlık önerisi
- **Sensör Tabanlı Öneri:** Cihazı sallayarak rastgele ürün önerisi alma.
- **Favori Paylaşımı:** Aynı ağdaki cihazlar arasında favori ürünlerin paylaşımı.
- **Çevrimdışı Desteği:** Ürünler ve favoriler lokal veritabanında saklanır, çevrimdışı erişim sağlanır.

## Mimari ve Özellikler (Başlık Bazında)

1. Storage / Basic Data
Kapsam: Uygulama, hem app-specific (cihazda local DB) hem de shared (Firebase Firestore) veri saklama yöntemlerini kullanır.
Basic Data: Kullanıcı oturumu, rolü ve bazı ayarlar için shared_preferences (Flutter’da SharedPreferences paketi) kullanılır. Bu sayede kullanıcıya ait token, rol, isim gibi bilgiler cihazda güvenli şekilde saklanır.
Dosya Sistemi: Uygulama, ürün görselleri gibi büyük verileri doğrudan dosya sisteminde saklamaz, ancak ürün görsel URL’leri ve metadataları local DB ve bulutta tutulur.

2. Local Database (Room / CoreData / Document)
Kullanılan Kütüphane: sqflite (Flutter için SQLite binding’i)
Tablo Yapısı ve İlişkiler:
products: Ürünlerin temel bilgilerini (id, title, price, firestore_id) tutar.
product_details: Her ürünün açıklaması, görseli ve kategorisi gibi detayları içerir. product_id ile products tablosuna birebir bağlıdır (foreign key).
favorites: Kullanıcının favori ürünlerini tutar. Her kayıt bir ürüne referans verir (product_id foreign key).
İlişkiler:
products ile product_details arasında birebir ilişki,
products ile favorites arasında bire-çok ilişki (bir ürün birden fazla kullanıcıda favori olabilir).
Migration: Versiyon yükseltmelerinde tabloya yeni sütun ekleme gibi işlemler desteklenir.
CRUD: Tüm ekleme, silme, güncelleme ve okuma işlemleri transaction bazlı ve ilişkili şekilde yapılır.

3. RESTFul API (CRUD)
Kullanılan Kütüphaneler: http (Flutter için HTTP istekleri)
Kapsam:
Ürünler, Firestore REST API üzerinden çekilir ve güncellenir.
Ürün ekleme, güncelleme ve silme işlemleri hem lokal hem de bulut üzerinde yapılabilir.
firestore ile oluşturulan endpoint yapısına http ile get post delete update istekelri atılır.
Favori paylaşımı için cihazlar arası HTTP tabanlı mini REST API sunucusu (shelf paketi ile) başlatılır.
Senaryolar:
Online ise buluttan veri çekilir, offline ise local DB’den.
Favoriler, ağ üzerinden başka bir cihaza JSON olarak gönderilebilir/alınabilir.

5. UI (Compose / SwiftUI)
Kullanılan Kütüphaneler: Flutter’ın kendi widget sistemi (Material, Cupertino)
Kapsam: Modern, responsive ve kullanıcı dostu ekranlar. Ana sayfa, ürün ekleme, favoriler, profil, giriş ekranı gibi bölümler.
Özellikler: Material Design, özelleştirilmiş temalar, dinamik state yönetimi.

6. Background Process / Task
Kullanılan Kütüphaneler: Dart’ın Timer, arka plan servisleri
Kapsam: USD/TRY kuru belirli aralıklarla arka planda çekilir (CurrencyBackgroundService). Fiyat değişiklikleri arka planda işlenir ve backend kaydına istek atılırak güncellenir ve gerekirse bildirim tetiklenerek kullanıcı fiyat değişimi hakkında bilgilendirilir.

7. Broadcast Receiver / NSNotificationCenter
Kullanılan Yöntem: Flutter’da ValueNotifier, uygulama içi event/callback mekanizmaları
Kapsam: kullanıcınıın favorilere aldığı ürünler için Fiyat değişikliği olduğunda uygulama içinde dinleyiciler tetiklenir. Kullanıcıya hem native bildirim hem de uygulama içi SnackBar ile bilgi verilir.

8. Sensor (Motion / Location / Environment)
Kullanılan Kütüphaneler: sensors_plus
Kapsam: Cihazın hareket sensörü (accelerometer) ile sallama hareketi algılanır ve rastgele ürün önerisi sunulur. Sensör dinleyicisi ilgili sayfada (home.dart) çalışarak her an acceleration değerini alır ve 20nin üzerine çıktığında ürün önerme fonksiyonu tetiklenir.

9. Connectivity (BLE / Wifi / Cellular Network / USB / NFC)
Kullanılan Kütüphaneler: http, shelf
Kapsam: Favori ürünler, aynı WiFi ağı üzerindeki cihazlar arasında paylaşılabilir (mini HTTP sunucu ve istemci ile), kullanıcı favoriler sayfasındaki paylaşma iconuna tıklayıp ağdaki diğer cihazları görntüler ve paylaşım başlatabilir, diğer cihaz paylaşımı kabul ederse kullanıcnın favorilerini kendi favorilerinde görebilir. Ayrıca uygulama, internet bağlantısı durumunu kontrol ederek çevrimdışı/çevrimiçi veri yönetimi yapar.

10. Authorization (OAuth / OpenID / JWT)
Kullanılan Kütüphaneler: firebase_auth, google_sign_in
Kapsam: Google ile OAuth tabanlı kimlik doğrulama yapılır. Firebase Auth ile kullanıcı oturumu ve rol yönetimi sağlanır, Satıcı ve Müşteri rol kontrolleri yapılır müşteri ürün ekleme işlevlerine ve sayfasına erişemez . JWT token’ı ile güvenli oturum yönetimi uygulanır.

11. Cloud Service (AI)
Kullanılan Kütüphaneler: http, Google Gemini API
Kapsam: Google Gemini API ile yapay zeka destekli ürün önerisi ve otomatik ürün ekleme alanı sunulur. Kullanıcıdan alınan anahtar kelimeye göre AI ile ürün adı, açıklama, görsel ve fiyat önerisi alınır.

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

---
