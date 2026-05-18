# 🚀 SubTracker - Smart Subscription Manager

**SubTracker** adalah aplikasi pintar berbasis *online-First* yang dirancang untuk membantu pengguna mencatat, memantau, dan mengingatkan jadwal pembayaran tagihan langganan bulanan (seperti Netflix, Spotify, Internet, dll) secara elegan dan aman.

Aplikasi ini dikembangkan untuk memenuhi standar UI/UX yang elegan (tidak terlalu sederhana, namun tidak terlalu ramai), dengan fungsionalitas pengingat lokal tanpa mengorbankan privasi pengguna (tidak ada data yang dikirim ke server *Cloud*).

---

## 📋 Blueprint & Tema Aplikasi
- **Nama Aplikasi:** SubTracker
- **Tema:** Keuangan & Produktivitas (Subscription Manager & Reminder).
- **Target Pengguna:** Individu yang memiliki banyak layanan langganan digital dan sering lupa tanggal jatuh tempo.
- **Arsitektur:** *Offline-First* (Penyimpanan lokal dengan enkripsi bawaan perangkat).

---

## ✨ Daftar Fitur Utama (Features)

1. **🌟 Onboarding & Profiling yang Elegan**
   - Layar *Welcome* dengan animasi ketik (*Typewriter*) dan *Staggered Album Zoom* yang sinematik.
   - Sistem perkenalan untuk mengatur *Nickname*, Target Anggaran Bulanan, dan Tujuan Keuangan.

2. **📊 Dashboard Interaktif (Home)**
   - Ringkasan total tagihan bulanan.
   - Notifikasi tagihan terdekat (*Upcoming Bills*).
   - Daftar semua langganan aktif yang diurutkan secara cerdas.

3. **📅 Kalender Tagihan Terintegrasi**
   - Visualisasi tanggal jatuh tempo langsung di atas kalender.
   - Indikator libur nasional (Otomatis mendeteksi tanggal merah Indonesia).

4. **📈 Statistik & Proyeksi Pengeluaran**
   - Analisis pengeluaran berdasarkan kategori (Hiburan, Software, Utilitas, dll) dilengkapi dengan *Progress Bar*.
   - Proyeksi total pengeluaran untuk bulan berikutnya.

5. **🔔 Smart Notification & Alarm System**
   - Menggunakan `flutter_local_notifications` dan `timezone`.
   - **Notifikasi Standar:** Pengingat biasa (H-1, H-3, dll).
   - **Alarm Musik:** Mode peringatan ketat di mana alarm akan terus berdering sampai pengguna membukanya.

6. **⚙️ Personalisasi & Manajemen State (Provider)**
   - **Multi-Tema:** Mendukung tema Gelap (Hitam/Biru) dan Terang (Putih).
   - **Multi-Bahasa (Bilingual):** Mendukung Bahasa Indonesia dan English.
   - Fitur "Tandai Selesai" dan "Perpanjang Langganan" dengan satu klik.

---

## 🛠️ Cara Kerja Aplikasi (Alur Penggunaan)

Berikut adalah dokumentasi cara kerja aplikasi dari sudut pandang pengguna:

1. **Fase Inisiasi (Kunjungan Pertama)**
   - Saat aplikasi pertama kali dibuka, pengguna akan disambut dengan animasi *Welcome* dan halaman *Terms & Conditions*.
   - Pengguna memilih bahasa awal dan menyetujui kebijakan privasi (Data 100% aman di penyimpanan lokal).
   - Pengguna mengisi Form Perkenalan (Nama Panggilan, Anggaran Opsional, Target).

2. **Fase Penambahan Langganan (Add Subscription)**
   - Di halaman Dashboard, tekan tombol melayang `+` (Warna Kuning Neon) di bagian bawah.
   - Isi formulir yang tersedia: Nama layanan (Misal: Spotify), Harga, Kategori.
   - Tentukan **Waktu Pengingat** (Tanggal & Jam) dan pilih jenis notifikasi (Notifikasi Biasa atau Alarm Berdering).
   - Tekan "Tambahkan". Sistem akan secara otomatis menjadwalkan *Local Notification* di OS Android/iOS.

3. **Fase Pemantauan (Monitoring)**
   - Pengguna dapat melihat sisa waktu (Misal: "Tinggal 2 Hari 5 Jam") pada kartu langganan di beranda.
   - Pengguna dapat membuka tab **Kalender** untuk melihat sebaran tagihan bulan ini.
   - Pengguna dapat membuka tab **Statistik** untuk mengevaluasi apakah pengeluaran mendominasi di sektor Hiburan atau Produktivitas.

4. **Fase Eksekusi Tagihan**
   - Saat jatuh tempo, HP pengguna akan memunculkan Notifikasi/Alarm.
   - Pengguna mengklik kartu langganan tersebut untuk masuk ke halaman **Detail**.
   - Pengguna dapat memilih tombol **Centang (Tandai Selesai)** atau opsi **Perpanjang (Renew)** untuk bulan berikutnya.

5. **Fase Keamanan / Reset (Pengaturan)**
   - Pengguna dapat menghapus seluruh data secara permanen melalui tab Pengaturan -> Privasi & Data -> *Hapus Seluruh Data Aplikasi (Reboot)*.

---

## 📌 Catatan Kepatuhan Tugas (Checklist Pengembangan)
Pernyataan di bawah ini mengonfirmasi kepatuhan terhadap pedoman pengerjaan proyek:

- [x] **Tema/Nama Aplikasi:** SubTracker (Selesai).
- [x] **Blueprint:** Direpresentasikan melalui arsitektur fitur di atas (Selesai).
- [x] **Sinkronisasi GIT:** Proyek ini telah diinisiasi dengan GIT sejak baris kode pertama.
- [x] **Pola Commit GIT:** Commit dilakukan secara berkala pada setiap penambahan fitur (*Continuous Integration*), tidak dilakukan dalam 1x *push* raksasa. Update dilakukan minimal 1 minggu sekali dengan log yang jelas.
- [x] **Layout Elegan:** Menggunakan kombinasi warna *Dark Mode* (0xFF09090B) dengan aksen Neon (0xFFD4FF00), animasi *smooth* (Staggered Animation), dan anti-berantakan saat keyboard muncul (`resizeToAvoidBottomInset`).
- [x] **Dokumentasi (README.md):** Tersedia di file ini.
- [ ] **Deployment Store:** (Jadwal: H-2 Minggu sebelum UAS akan di-build menjadi `.aab` / `.ipa` untuk didaftarkan ke Console).
