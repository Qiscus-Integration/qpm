# qpm — Qiscus PM CLI

Command-line tool untuk akses Qiscus Project Management.

## Download

Download binary sesuai OS kamu:

| OS | File |
|---|---|
| Windows | `qpm.exe` |
| macOS | `qpm-macos` |
| Linux | `qpm-linux` |

Simpan ke PATH (misal: `C:\Windows\System32\` untuk Windows, atau `/usr/local/bin/` untuk macOS/Linux).

## Cara Pakai

### 1. Login

```bash
qpm login
```

Akan membuka browser untuk OAuth. Setelah selesai, copy token yang muncul dan paste di terminal.

### 2. Cek status

```bash
qpm whoami
```

### 3. Lihat perintah yang tersedia

```bash
qpm tools
```

### 4. Jalankan perintah

```bash
# Contoh: lihat daftar project
qpm project list

# Contoh: buat ticket baru
qpm ticket create --title "Bug X" --project-id <uuid> --priority high
```

### 5. Mode interaktif (tanpa flag)

Kalau lupa flag yang diperlukan, jalankan tanpa flag — wizard akan bertanya:

```bash
qpm ticket create
```

Akan muncul prompt untuk isi field yang diperlukan satu per satu.

## Opsi Lain

```bash
# Output JSON (untuk parsing)
qpm project list --json

# Pakai server lain (satu kali)
qpm --server https://project.qiscus.io project list

# Force refresh cache tools
qpm --refresh tools
```

## Help

```bash
qpm --help
```
