# IoT Cihaz Durum Takip Uygulaması

Bu proje, cihazların durumunu takip eden ve verilerini gerçek zamanlı olarak Firebase kullanarak güncelleyen bir IoT (Nesnelerin İnterneti) uygulamasıdır. Proje, Arduino ile Firebase Realtime Database entegrasyonunu içerir ve kullanıcıların cihaz durumlarını uzaktan izlemelerine olanak tanır.

## Özellikler

- **Gerçek Zamanlı Cihaz Takibi**: Kullanıcılar, cihazların durumunu gerçek zamanlı olarak izleyebilir ve kontrol edebilir.
- **Firebase Entegrasyonu**: Cihazların durumu, Firebase Realtime Database ve Firestore ile anlık olarak güncellenir.
- **Modüler Tasarım**: Proje, birden fazla cihazla çalışacak şekilde ölçeklenebilir yapıdadır.
- **Dinamik UI**: Cihaz durumlarına göre UI elemanları dinamik olarak güncellenir.

## Donanım Gereksinimleri

- Arduino (ESP8266 veya ESP32 önerilir)
- Cihaz sensörleri (Projeye bağlı olarak)
- Güç kaynağı

## Yazılım Gereksinimleri

- Arduino IDE
- Firebase Arduino Kütüphanesi
- WiFi Manager Kütüphanesi

## Uygulama Kurulumu

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin.
2. Yeni bir Firebase projesi oluşturun.
3. **Add App** butonuna tıklayın ve iOS'u seçin. **Apple Bundle ID** kısmına `com.ePlug` yazın.
4. **Realtime Database** oluşturun ve okuma/yazma izinlerini aşağıdaki gibi güncelleyin:

    ```json
    {
      "rules": {
        ".read": true,
        ".write": true
      }
    }
    ```

5. **Firestore Database** oluşturun ve okuma/yazma izinlerini şu şekilde güncelleyin:

    ```plaintext
    rules_version = '2';

    service cloud.firestore {
      match /databases/{database}/documents {
        match /{document=**} {
          allow read, write: if true;
        }
      }
    }
    ```

6. **Authentication** bölümüne gidin, **Email/Password** ve **Google** yöntemlerini aktif edin.
7. Proje ayarlarından **GoogleService-Info.plist** dosyasını indirin.
8. Xcode'da projenize bu dosyayı ekleyin.
9. **GoogleService-Info.plist** dosyasındaki `REVERSED_CLIENT_ID` değerini kopyalayın.
10. **Info.plist** dosyasındaki **URL types** bölümüne, **URL scheme** altına `Item 0` olarak yapıştırın.
