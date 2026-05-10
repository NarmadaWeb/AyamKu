# Panduan Konfigurasi Lengkap AyamSegar (Flutter)

Dokumen ini berisi panduan langkah demi langkah untuk mengkonfigurasi proyek Flutter `AyamSegar` dari awal hingga siap dijalankan.

---

## 1. Persiapan Awal
Pastikan lingkungan pengembangan Anda sudah siap:
- Flutter SDK (Minimal versi 3.24.0)
- Dart SDK
- Android Studio / Xcode
- Firebase CLI (sudah terinstall di komputer)
- Node.js & npm (untuk menginstall Firebase CLI)

---

## 2. Setup Firebase Core

Karena aplikasi ini menggunakan `firebase_core`, Anda harus menghubungkan aplikasi Flutter dengan Firebase Console.

### A. Install Firebase CLI & FlutterFire
Buka terminal dan jalankan perintah berikut:
```bash
# Install Firebase CLI (jika belum ada)
npm install -g firebase-tools

# Login ke akun Google yang memiliki Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### B. Konfigurasi Proyek
Masuk ke root direktori proyek `ayam_segar` di terminal, lalu jalankan:
```bash
flutterfire configure
```
1. Anda akan diminta untuk **memilih atau membuat Firebase project** (contoh: `ayam-segar-app`).
2. Pilih platform yang ingin Anda dukung (Android, iOS, Web).
3. FlutterFire secara otomatis akan memperbarui/membuat file `lib/firebase_options.dart` beserta konfigurasi platform-specific (seperti `google-services.json` di Android dan `GoogleService-Info.plist` di iOS).

---

## 3. Konfigurasi Firebase Authentication

### A. Mengaktifkan Sign-In Providers
1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Pilih project `AyamSegar` Anda.
3. Di menu sebelah kiri, masuk ke **Build** > **Authentication**.
4. Klik tab **Sign-in method**.
5. Tambahkan provider berikut dan ubah statusnya menjadi **Enable**:
   - **Email/Password**
   - **Google**

### B. Konfigurasi Khusus Google Sign-In
Untuk menggunakan Google Sign-In di Android/iOS, Firebase perlu "mengenali" aplikasi Anda:

**Android (SHA-1 Fingerprint):**
Google Sign-in di Android wajib memiliki sertifikat SHA-1.
1. Di terminal proyek Anda, jalankan:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Salin nilai `SHA1` (dari varian `debug`).
3. Kembali ke **Firebase Console** > **Project Settings** (Ikon gir).
4. Di bagian "Your apps", pilih aplikasi Android, lalu klik **Add fingerprint**.
5. Paste SHA-1 Anda dan klik **Save**.
6. **Penting:** Setelah menambahkan SHA-1, unduh ulang file `google-services.json` dan timpa file lama di `android/app/google-services.json`.

**iOS / macOS:**
1. Pastikan Anda telah mengunduh `GoogleService-Info.plist` melalui perintah `flutterfire configure`.
2. Jika Anda melakukan build via Xcode, pastikan file tersebut disertakan ke dalam direktori *Runner*.
3. Buka `ios/Runner/Info.plist`, pastikan URL Scheme (REVERSED_CLIENT_ID dari `GoogleService-Info.plist`) telah dikonfigurasi. FlutterFire biasanya menangani ini secara otomatis.

---

## 4. Konfigurasi Database (Firestore) & Storage

### A. Cloud Firestore
Aplikasi menggunakan Firestore untuk menyimpan data user (Nama, Nomor HP, dll).
1. Di Firebase Console, buka **Build** > **Firestore Database**.
2. Klik **Create database**.
3. Pilih lokasi server terdekat (misal: `asia-southeast2` untuk Jakarta).
4. Set *Security Rules* ke **Test mode** (untuk tahap development). Jangan lupa ubah menjadi *Production rules* sebelum rilis publik.

### B. Firebase Storage
Digunakan untuk menyimpan foto profil user.
1. Di Firebase Console, buka **Build** > **Storage**.
2. Klik **Get Started**.
3. Mulai dengan **Test mode** dan pilih region yang sama dengan Firestore.

---

## 5. Konfigurasi Build Runner & Riverpod Generator

Aplikasi ini menggunakan Code Generation dari `riverpod_generator` untuk mengurus State Management dan Routing (`go_router`).

Setiap kali Anda mengubah file `*.dart` yang memiliki anotasi `@riverpod` (seperti `router.dart` atau `auth_controller.dart`), Anda **WAJIB** menjalankan *build runner*.

### Menjalankan Build Runner
Buka terminal di root proyek dan jalankan:
```bash
# Untuk build satu kali saja:
dart run build_runner build --delete-conflicting-outputs

# ATAU, jalankan dalam mode "watch" agar berjalan otomatis saat Anda meng-save file:
dart run build_runner watch --delete-conflicting-outputs
```

*Catatan: Hal ini akan menghasilkan file `*.g.dart` (contoh: `auth_controller.g.dart`). Jangan pernah mengedit file berakhiran `.g.dart` secara manual.*

---

## 6. Penyesuaian `android/app/build.gradle` (Opsional tapi Disarankan)
Untuk mencegah error kompiliasi MultiDex di Android (karena banyaknya library Firebase), pastikan minSdkVersion Anda setidaknya **21**.

Buka file `android/app/build.gradle`, temukan bagian `defaultConfig`, dan sesuaikan:
```gradle
defaultConfig {
    applicationId "com.example.ayam_segar"
    minSdkVersion 21 // Pastikan ini minimal 21
    targetSdkVersion flutter.targetSdkVersion
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
    multiDexEnabled true // Tambahkan ini jika Anda mendapati error 64K methods
}
```

---

## 7. Menjalankan Aplikasi
Setelah semuanya terkonfigurasi, Anda dapat menguji aplikasi Anda.

```bash
flutter clean
flutter pub get
flutter run
```

---
### Checklist Penyelesaian
- [x] Flutter SDK terinstall
- [x] Proyek Firebase dibuat
- [x] `flutterfire configure` sukses dijalankan
- [x] SHA-1 ditambahkan untuk Google Sign-In
- [x] Firestore & Storage aktif di Test Mode
- [x] `build_runner` sukses men-generate `.g.dart`
- [x] Aplikasi sukses berjalan (tidak crash/blank)
