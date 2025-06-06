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

Münevver Şule Yolalan Tarafından Storage branchinde geliştirildi.

3. Local Database (Room / CoreData / Document)
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

Ziyaettin Ayerden Tarafından LocalDatabase branchinde gerçekleştirildi.

4. RESTFul API (CRUD)
Kullanılan Kütüphaneler: http (Flutter için HTTP istekleri)
Kapsam:
Ürünler, Firestore REST API üzerinden çekilir ve güncellenir.
Ürün ekleme, güncelleme ve silme işlemleri hem lokal hem de bulut üzerinde yapılabilir.
firestore ile oluşturulan endpoint yapısına http ile get post delete update istekelri atılır.
Favori paylaşımı için cihazlar arası HTTP tabanlı mini REST API sunucusu (shelf paketi ile) başlatılır.


Halil Bahadır Arın tarafından restful ve develop branchlerinde gerçekleştirildi.


6. UI (Compose / SwiftUI)
Kullanılan Kütüphaneler: Flutter’ın kendi widget sistemi (Material, Cupertino)
Kapsam: Modern, responsive ve kullanıcı dostu ekranlar. Ana sayfa, ürün ekleme, favoriler, profil, giriş ekranı gibi bölümler.
Özellikler: Material Design, özelleştirilmiş temalar, dinamik state yönetimi.

Halil Bahadır Arın tarafından UI ve develop branchlerinde gerçekleştrildi.

8. Background Process / Task
Kullanılan Kütüphaneler: Dart’ın Timer, arka plan servisleri
Kapsam: USD/TRY kuru belirli aralıklarla arka planda çekilir (CurrencyBackgroundService). Fiyat değişiklikleri arka planda işlenir ve backend kaydına istek atılırak güncellenir ve gerekirse bildirim tetiklenerek kullanıcı fiyat değişimi hakkında bilgilendirilir.

Şamil Alpay tarafından BackgroundProcess branchinde gerçekleştirildi.

10. Broadcast Receiver / NSNotificationCenter
Kullanılan Yöntem: Flutter’da ValueNotifier, uygulama içi event/callback mekanizmaları
Kapsam: kullanıcınıın favorilere aldığı ürünler için Fiyat değişikliği olduğunda uygulama içinde dinleyiciler tetiklenir. Kullanıcıya hem native bildirim hem de uygulama içi SnackBar ile bilgi verilir.

Münevver Şule Yolalan tarafından broadcast receiver branchşnde gerçekleştirildi.

12. Sensor (Motion / Location / Environment)
Kullanılan Kütüphaneler: sensors_plus
Kapsam: Cihazın hareket sensörü (accelerometer) ile sallama hareketi algılanır ve rastgele ürün önerisi sunulur. Sensör dinleyicisi ilgili sayfada (home.dart) çalışarak her an acceleration değerini alır ve 20nin üzerine çıktığında ürün önerme fonksiyonu tetiklenir.

Mustafa Emirhan Kartal tarafından sensor branchinde gerçekleştirildi.

14. Connectivity (BLE / Wifi / Cellular Network / USB / NFC)
Kullanılan Kütüphaneler: http, shelf
Kapsam: Favori ürünler, aynı WiFi ağı üzerindeki cihazlar arasında paylaşılabilir (mini HTTP sunucu ve istemci ile), kullanıcı favoriler sayfasındaki paylaşma iconuna tıklayıp ağdaki diğer cihazları görntüler ve paylaşım başlatabilir, diğer cihaz paylaşımı kabul ederse kullanıcnın favorilerini kendi favorilerinde görebilir. Ayrıca uygulama, internet bağlantısı durumunu kontrol ederek çevrimdışı/çevrimiçi veri yönetimi yapar.

Ziyaettin Ayerden Tarafından Connectivity branchinde gerçekleştirildi

16. Authorization (OAuth / OpenID / JWT)
Kullanılan Kütüphaneler: firebase_auth, google_sign_in
Kapsam: Google ile OAuth tabanlı kimlik doğrulama yapılır. Firebase Auth ile kullanıcı oturumu ve rol yönetimi sağlanır, Satıcı ve Müşteri rol kontrolleri yapılır müşteri ürün ekleme işlevlerine ve sayfasına erişemez . JWT token’ı ile güvenli oturum yönetimi uygulanır.

Şamil Alpay tarafından Authorozation branchinde gerçekleştirildi,

18. Cloud Service (AI)
Kullanılan Kütüphaneler: http, Google Gemini API
Kapsam: Google Gemini API ile yapay zeka destekli ürün önerisi ve otomatik ürün ekleme alanı sunulur. Kullanıcıdan alınan anahtar kelimeye göre AI ile ürün adı, açıklama, görsel ve fiyat önerisi alınır.

Mustafa Emirhan Kartal Tarafından AI branchinde gerçekleştirildi.

## Notlar


Tüm ekip üyeleri en az iki özellik geliştirdi ve sadece kendi branch’lerinde değil, diğer üyelerin branch’leriyle entegre şekilde çalışmalar gerçekleştirdiler. Geliştirilen tüm branch’ler önce develop branch’inde birleştirilip çalışır hale getirildi ve nihai olarak main branch’ine aktarımı sağlandı.

Proje Flutter ile geliştirildi. Ancak ekip üyeleri arasında paket, versiyon ve işletim sistemi uyumsuzlukları nedeniyle çok sayıda hata ile karşılaşıldı. Bu durum, haftalık düzenli PR’lar halinde geliştirme yapmamızı zorlaştırdı. Haftaların büyük bir kısmı, hataları gidermek ve birleştirilen branch’lerin diğer ekip üyelerinde sorunsuz çalışmasını sağlamakla geçti.

Ayrıca, özellikler birbirleriyle oldukça ilişkili olduğu için tamamen bağımsız branch’lerde bireysel geliştirmeler yürütmek çoğu zaman mümkün olmadı. Genellikle bir branch tamamlandıktan sonra, o branch’teki geliştirmeler temel alınarak diğer branch’lerin oluşturulması gerekti. bu da hem zaman yönetimi açısından hem de ekip üyeleri arasındaki versiyon bazlı uyuşmazlıklardan dolayı bizi zorlayan bir durum oluşturdu.

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
