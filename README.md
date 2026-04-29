# qpm — Qiscus PM CLI

Command-line tool untuk akses Qiscus Project Management.

## Download

### Via terminal (direkomendasikan)

**Windows** (PowerShell — jalankan sebagai Administrator):

```powershell
Invoke-WebRequest -Uri "https://github.com/Qiscus-Integration/qpm/releases/latest/download/cli-win.exe" -OutFile "C:\Windows\System32\qpm.exe"
```

**macOS**:

```bash
curl -L https://github.com/Qiscus-Integration/qpm/releases/latest/download/cli-macos -o qpm
chmod +x qpm
sudo mv qpm /usr/local/bin/qpm
```

**Linux**:

```bash
curl -L https://github.com/Qiscus-Integration/qpm/releases/latest/download/cli-linux -o qpm
chmod +x qpm
sudo mv qpm /usr/local/bin/qpm
```

### Manual download

Download file dari [halaman Releases](https://github.com/Qiscus-Integration/qpm/releases/latest), lalu simpan ke PATH:

| OS | File | Rename ke | Taruh di |
| --- | --- | --- | --- |
| Windows | `cli-win.exe` | `qpm.exe` | `C:\Windows\System32\` |
| macOS | `cli-macos` | `qpm` | `/usr/local/bin/` |
| Linux | `cli-linux` | `qpm` | `/usr/local/bin/` |

> macOS/Linux: jalankan `chmod +x qpm` setelah download sebelum dipindah ke PATH.

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
