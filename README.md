[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">

  <h1 align="center">Electronic Vault Lock</h1>

  <p align="center">
    Kunci Kombinasi 4 digit
    <br />
    <a href="https://github.com/rroiii/Electronic-Vault-Lock"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/rroiii/Electronic-Vault-Lock">View Demo</a>
    ·
    <a href="https://github.com/rroiii/Electronic-Vault-Lock/issues">Report Bug</a>
    ·
    <a href="https://github.com/rroiii/Electronic-Vault-Lock/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#dekripsi">Dekripsi</a></li>
    <li><a href="#state---state-kunci-kombinasi">State - State Kunci Kombinasi</a></li>
    <li><a href="#state-diagram">State Diagram</a></li>
    <li><a href="#alur-kerja-state-pada-kunci-kombinasi">Alur Kerja State Pada Kunci Kombinasi</a></li>
  </ol>
</details>

## Dekripsi
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
## State Diagram
<div>
    <img src="State Diagram Synthesis.png" alt="Logo" width="400" height="400">
  </div>
  
## Alur Kerja State Pada Kunci Kombinasi

- Pada state start, Diberikan waktu untuk menerima input digit selama 5 detik. Jika sudah melewati 5 detik dan input digit dimasukkan salah, maka akan pergi ke state    waitTimer. Dimana pada state waitTimer, user harus menunggu 30 detik agar dapat menerima input lagi. Jika input sudah benar, maka akan ke state digit1.
- Pada state digit1 mirip dengan state start, dimana menerima input digit selama 5 detik. Jika salah akan ke state waitTimer dan jika benar maka akan ke state digit berikutnya. State digit2,digit3 mirip juga seperti state start.
- Jika pada state digit3 sudah benar diberikan inputnya, maka next statenya akan berubah menjadi state unlocked. Pada state unlocked, akan diberikan waktu input button_set dan button_lock selama 5 detik untuk menentukan jika ingin kembalik lock kunci atau set kunci kombinasi yang baru. Jika dipencet tombol lock, maka akan balik ke state start. Jika dipencet tombol set, maka akan set kunci kombinasi yang baru menggunakan enum tambahan yaitu unlocking dan setNewLock. Untuk menentukan apabali kunci sedang diunlock oleh user atau sedang diset kunci kombinasi yang baru oleh user.

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/rroiii/Electronic-Vault-Lock/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/rroiii/Electronic-Vault-Lock/network/members


Hasil Test Bench
![alt text](https://github.com/rroiii/Electronic-Vault-Lock/blob/main/Hasil%20Test%20Bench.png)

Hasil Synthesis
![alt text](https://github.com/rroiii/Electronic-Vault-Lock/blob/main/Synthesis.png)
