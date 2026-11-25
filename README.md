# XAU GOLD SIGNAL — HFM MT5 M5

Starter project untuk dashboard Android/web + bridge MT5. Dashboard **tidak terhubung otomatis** ke HFM sampai server dan EA dipasang serta dikonfigurasi.

## Isi
- `web/index.html`: dashboard responsif.
- `server.py`: API penerima data dari EA MT5.
- `mt5/XAU_GOLD_SIGNAL_BRIDGE.mq5`: EA bridge untuk chart XAUUSD M5.

## Menjalankan server (VPS/PC)
1. Pasang Python 3.10+.
2. Jalankan: `pip install flask`
3. Jalankan: `python server.py`
4. Buka `http://IP_SERVER:8080` untuk uji awal. Untuk penggunaan publik, pasang domain + HTTPS (reverse proxy seperti Nginx/Caddy). Jangan biarkan endpoint tanpa perlindungan di internet; tambahkan token/API key sebelum produksi.

## Menghubungkan HFM MT5
1. Buka MT5 desktop di PC/VPS (aplikasi MT5 Android tidak dapat memasang/menjalankan EA).
2. Buka MetaEditor, compile file `mt5/XAU_GOLD_SIGNAL_BRIDGE.mq5`.
3. Tempel EA ke chart simbol Gold/XAUUSD milik akun HFM dengan timeframe M5.
4. Ganti `ServerURL` di input EA menjadi `http://IP_SERVER:8080/api/mt5` (atau URL HTTPS domain Anda).
5. Di MT5: Tools > Options > Expert Advisors > centang Allow WebRequest for listed URL, tambahkan host server.
6. Aktifkan Algo Trading dan pastikan EA berjalan. Periksa tab Experts/Journal.

## Notifikasi
Tombol notifikasi meminta izin browser. Notifikasi standar muncul ketika dashboard terbuka. Agar tetap menerima notifikasi saat tab tertutup/HP terkunci, perlu HTTPS, service worker, Web Push (VAPID), dan penyimpanan subscription di server; itu belum dikonfigurasi dalam starter ini.

## Strategi dan risiko
- Sinyal dihitung dari candle M5 yang sudah tutup: EMA 9/21 cross, RSI 14, dan arah candle.
- SL memakai high/low candle sinyal; TP memakai rasio reward:risk 1:2.
- Risiko target 1% ditampilkan sebagai parameter, tetapi kalkulasi lot otomatis belum diaktifkan. Verifikasi tick value, contract size, minimum lot, stop level, spread, equity, dan risiko aktual di MT5 sebelum transaksi.
- EA ini hanya mengirim sinyal ke dashboard; tidak membuka/menutup order.
- Uji di akun demo terlebih dahulu. Strategi indikator tidak menjamin profit.
