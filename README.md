# MPG HRIS - Mobile Client

Aplikasi mobile untuk pegawai sebagai bagian dari ekosistem MPG HRIS. Dirancang dengan antarmuka modern (Bento Grid) dan fitur keamanan tingkat tinggi berbasis biometrik.

## 🚀 Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Networking**: Dio
- **Maps**: Google Maps Flutter / Flutter Map
- **Biometric**: Google ML Kit (Face Detection)
- **Local Storage**: Hive & Shared Preferences
- **Themes**: Google Fonts (Inter/Outfit), Bento Grid UI, Glassmorphism.

## 🛠 Panduan Jalankan Proyek

1. **Prasyarat**
   - Flutter SDK installed.
   - Android Studio / VS Code dengan ekstensi Dart & Flutter.

2. **Setup Environment**
   ```bash
   cp .env.example .env
   # Masukkan BASE_URL API di .env
   ```

3. **Instal Dependensi**
   ```bash
   flutter pub get
   ```

4. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

## 📂 Struktur Proyek

Proyek mengikuti pola clean architecture sederhana di Flutter:
- `lib/screens`: UI Layer (Antarmuka pengguna).
- `lib/providers`: State Management (Logika aplikasi).
- `lib/repositories`: Data Layer (Interaksi dengan API).
- `lib/models`: Struktur data.
- `lib/widgets`: Komponen UI reusable.

## ✨ Fitur Utama (Highlight)

1. **Presensi Real-time**: Check-in/out berbasis lokasi (Geofencing) dan deteksi wajah (Face Recognition).
2. **Dashboard Bento**: Tampilan modern yang merangkum statistik kerja, poin lembur, dan jadwal.
3. **Pengajuan Izin/Cuti**: Form pengajuan digital dengan lampiran bukti file/foto.
4. **Signature Capture**: Fitur tanda tangan digital untuk verifikasi dokumen/izin.
5. **Notifikasi**: Integrasi notifikasi untuk pengumuman dan status pengajuan.

## 🎨 Design Guidelines

- **Primary Colors**: Navy (`#1E293B`), Orange (`#F59E0B`), White (`#FFFFFF`).
- **Style**: Soft shadows, rounded corners (Bento Grid), dan micro-animations.
- **Theme**: Konfigurasi tema utama tersedia di `lib/theme.dart`.

## 🛡️ Quality Assurance (QA) & Testing

Sistem mobile ini terintegrasi dengan modul backend. Untuk skenario pengujian lengkap (termasuk Matriks Role & Isolasi Data), silakan merujuk ke panduan utama di:
👉 **[PANDUAN QA (Web Project)](file:///c:/xampp/htdocs/mpg-hris/QA_GUIDE.md)**

---
Developed by MPG Team.
