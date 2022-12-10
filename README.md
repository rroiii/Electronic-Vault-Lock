# Electronic-Vault-Lock

# Dekripsi
Kunci kombinasi ini menerima 4 digit angka secara satu persatu. Jika semua digit yang dimasukkan benar, maka kunci kombinasi akan terbuka. Untuk memperlihatkan digit-digit akan tersebut digunakan 4 seven segment dan juga terdapat 4 LED yang digunakan untuk menandakan jika input angka yang dimasukkan benar atau tidak pada kunci kombinasinya. Setiap digit masing-masing dipasang dengan sebuah seven segment display dan LED. Setiap digit benar yang dimasukkan ke kunci kombinasi tersebut, maka seven segment akan mendisplay angka tersebut dan LED akan menyala warna hijau. Jika digit yang dimasukkan salah, maka seven segment tidak akan mendisplay apa-apa dan LED akan menyala berwarna merah, menyatakan bahwa digit yang dimasukkan salah.

Pada kunci kombinasi terdapat enam state yaitu start, unlocked, waitTimer, digit1, digit2, dan digit3. Cara kerja state digit secara umum adalah jika digit yang dimasukkan benar, maka akan berpindah ke digit selanjutnya sampai digi terakhir. Jika digit ke-4 benar, correct akan bernilai 1 dan maka state berpindah ke unlocked yang mengartikan perangkat kunci tersebut sudah terbuka. Dan untuk mengubah state open menjadi close, Maka kita harus mengubah nilai variabel dari button lock, Ini mengartikan pengguna kembali mengunci perangkatnya kembali. Dalam state close akan secara otomatis mengubah nilai variabel lock menjadi 1 yang mengartikan perangkat sudah terkunci kembali. Selain itu, Setiap digit terdapat pengecekan kesalahan saat dimasukkan input digitnya. Waktu yang diberikan untuk memberikan input masing-masing digit adalah maksimal 5 detik dan bila melebihi waktu tersebut akan kembali ke state start. Bila salah input, maka akan kembali ke state start dan tidak dapat memasukkan password selama 30 detik.

Waktu yang berikan pada kode VHDL ini menggunakan constant, sehingga sifatnya dinamik dan dapat diubah sesuai kemauan. Selain itu, terdapat juga fitur untuk mengganti password saat dalam state unlocked. Untuk mengganti password, button set harus ditekan terlebih dahulu.

Untuk keamanan yang lebih baik, pada kode VHDL ini juga menerapkan enkripsi dan dekripsi pada password yang disimpannya. Password akan disimpan dalam bentuk terenkripsi. Kemudian pada saat state start, password akan didekripsi terlebih dahulu agar bisa dicocokan dengan password yang akan dimasukkan. Hal tersebut dikarenakan password akan dimasukkan secara satu persatu, sehingga agar dapat dicocokkan dengan password yang tersimpan, password yang tersimpan harus didekripsi terlebih dahulu. 
Pada saat mengganti password pada state unlocked, password yang diinputkan juga akan dienkripsi kembali. Dengan begitu password yang disimpan akan selalu terenkripsi.

## State - State Kunci Kombinasi
```bash
start
unlocked
waitTimer
digit1
digit2
digit3
```
