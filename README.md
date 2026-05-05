# qpm — Qiscus PM CLI

Command-line tool untuk akses Qiscus Project Management.

## Download

### Via terminal (direkomendasikan)

**Windows** (PowerShell — jalankan sebagai Administrator):

```powershell
Invoke-WebRequest -Uri "https://github.com/Qiscus-Integration/qpm/releases/latest/download/qpm-win.exe" -OutFile "C:\Windows\System32\qpm.exe"
```

**macOS**:

```bash
curl -L https://github.com/Qiscus-Integration/qpm/releases/latest/download/qpm-macos -o qpm
chmod +x qpm
sudo mv qpm /usr/local/bin/qpm
```

**Linux**:

```bash
curl -L https://github.com/Qiscus-Integration/qpm/releases/latest/download/qpm-linux -o qpm
chmod +x qpm
sudo mv qpm /usr/local/bin/qpm
```

### Manual download

Download file dari [halaman Releases](https://github.com/Qiscus-Integration/qpm/releases/latest), lalu simpan ke PATH:

| OS | File | Rename ke | Taruh di |
| --- | --- | --- | --- |
| Windows | `qpm-win.exe` | `qpm.exe` | `C:\Windows\System32\` |
| macOS | `qpm-macos` | `qpm` | `/usr/local/bin/` |
| Linux | `qpm-linux` | `qpm` | `/usr/local/bin/` |

> macOS/Linux: jalankan `chmod +x qpm` setelah download sebelum dipindah ke PATH.

## Memulai

### 1. Login

```bash
qpm login
```

Akan membuka browser untuk OAuth. Setelah selesai, token otomatis tersimpan di `~/.qpm/config.json`.

### 2. Cek status

```bash
# Siapa saya?
qpm whoami

# Lihat perintah yang tersedia
qpm tools
```

## Project Context (Deteksi Otomatis)

Mirip cara `.git/` menyimpan metadata repository, `qpm` membuat folder `.qpm/` di
directory projectmu untuk menyimpan project ID dan konfigurasi.

```text
project-acme/
├── .qpm/
│   └── config.json     ← project ID + server URL
├── src/
└── ...
```

**`.qpm/config.json` structure:**
```json
{
  "projectId": "seed-project-acme-onboarding",
  "baseUrl": "https://project.qiscus.io"
}
```

Cukup setup sekali per directory — setelah itu semua command otomatis tahu project mana yang aktif.

### Setup

```bash
# Masuk ke folder project, lalu set project ID
cd ~/projects/acme-onboarding
qpm project use seed-project-acme-onboarding
# → membuat .qpm/config.json + langsung fetch data project dari server

# Set project berbeda di folder lain
cd ~/projects/beta-internal
qpm project use seed-project-beta-internal

# Set global (fallback untuk semua folder tanpa .qpm/)
qpm project use --global seed-project-default

# Cek project aktif + info cache
qpm project current

# Hapus project dari folder ini
qpm project use --unset
```

### Priority Detection

1. `--project-id` flag (selalu menang jika diberikan)
2. `.qpm/config.json` di current dir atau parent terdekat (walk up seperti git)
3. `git config qpm.projectId` (backwards compat)
4. `currentProject` di `~/.qpm/config.json` (global fallback)
5. Interactive wizard (muncul jika tidak ada yang diset)

### Manual Sync

Untuk refresh data project dari server:

```bash
qpm sync
# atau
qpm project sync
```

### Multi-project Workflow

```bash
# Vibe code di beberapa project sekaligus — tiap folder punya context sendiri
cd ~/projects/acme && qpm ticket create --name "Fix auth"      # → acme project
cd ~/projects/beta && qpm ticket create --name "Add dashboard"  # → beta project
```

### Setelah Set Project

```bash
# Sebelum: butuh --project-id setiap kali
qpm ticket create --project-id "seed-project-acme-onboarding" --name "Fix bug"

# Sesudah: project-id auto-terdeteksi dari .qpm/config.json
qpm ticket create --name "Fix bug"
#   using project seed-project-acme-onboarding (from .qpm/config.json)
```

## Membuat Ticket

### Mode Non-interaktif (dengan flag)

Jalankan single command tanpa perlu interactive prompt:

```bash
# Ticket dasar
qpm ticket create \
  --project-id "seed-project-acme-onboarding" \
  --name "Fix login endpoint" \
  --priority major

# Dengan description dari file markdown
qpm ticket create \
  --project-id "seed-project-acme-onboarding" \
  --name "Fix login endpoint" \
  --priority major \
  --template "readme.md"

# Dengan field optional
qpm ticket create \
  --project-id "seed-project-acme-onboarding" \
  --name "API Documentation" \
  --priority normal \
  --assignee-id "@me" \
  --estimation-hours 40 \
  --tags "documentation,backend"
```

### Mode Interaktif (dengan wizard)

Jalankan tanpa flag untuk interactive prompt:

```bash
# Wizard akan bertanya field yang diperlukan satu per satu
qpm ticket create

# Atau paksa mode interaktif meski ada flag
qpm ticket create --interactive
```

## Opsi Ticket Create

| Flag | Tipe | Wajib | Contoh |
|------|------|-------|--------|
| `--project-id` | string | ✓ (atau set via `qpm project use`) | `seed-project-acme-onboarding` |
| `--name` | string | ✓ | `"Fix login endpoint"` |
| `--priority` | enum | | `critical`, `major`, `normal`, `minor` |
| `--ticket-type` | string | | `"Bug"`, `"Feature"`, `"Task"` |
| `--platform` | string | | `"Backend"`, `"Frontend"`, `"Mobile"` |
| `--assignee-id` | string | | user-id atau `@me` |
| `--estimation-hours` | number | | `8`, `16`, `24` |
| `--parent-task-id` | string | | ID ticket parent (untuk subtask) |
| `--tags` | array | | `"tag1,tag2,tag3"` |
| `--template` | string | | path ke file markdown |

### Nilai Khusus

```bash
# Reference user saat ini
--assignee-id "@me"
```

## List & Query

### List Ticket

```bash
# Semua ticket
qpm ticket list

# Filter by project
qpm ticket list --project-id "proj-id"

# Ticket saya saja
qpm ticket list --mine

# Filter by status
qpm ticket list --state "in_progress"

# Search
qpm ticket list --search "login"
```

### List Project

```bash
qpm project list
qpm project list --search "Acme"
```

## JSON Output

Untuk scripting/automation, gunakan `--json`:

```bash
qpm ticket list --json | jq '.[] | {id, name, priority}'
```

## Global Options

```bash
qpm [global-options] <command>

--server <url>       # Override server URL
--token <jwt>        # Override Bearer token
--json               # Raw JSON output
--no-color           # Disable colored output
-i, --interactive    # Force interactive mode
--refresh            # Force tool discovery refresh
-h, --help           # Show help
-v, --version        # Show version
```

## Contoh Penggunaan

### Contoh 1: Quick Bug Report

```bash
qpm ticket create \
  --project-id "seed-project-acme-onboarding" \
  --name "Login button broken on mobile" \
  --priority major \
  --assignee-id "@me" \
  --estimation-hours 4
```

### Contoh 2: Feature dengan Specification

```bash
# 1. Buat ticket
TICKET=$(qpm ticket create \
  --project-id "proj-id" \
  --name "User Dashboard" \
  --priority major \
  --estimation-hours 40 \
  --json | jq -r '.pageId')

# 2. Tambah detailed specification
qpm page create_subpage \
  --parent-page-id "$TICKET" \
  --title "Specification" \
  --template "requirements.md"
```

### Contoh 3: Bulk Import (Script)

```bash
#!/bin/bash
while IFS=',' read -r project title priority; do
  qpm ticket create \
    --project-id "$project" \
    --name "$title" \
    --priority "$priority"
done < tickets.csv
```

## Troubleshooting

### Error "not signed in"

```bash
qpm login
```

### Command not found

```bash
# Refresh tool cache
qpm tools --refresh
```

### Flag tidak parse dengan benar

Pastikan semua required field disediakan dengan flag:

- `ticket create` butuh: `--project-id` dan `--name` minimal
- Field lainnya opsional

## Tips

1. **Tab Completion**: Configure shell autocomplete (perlu konfigurasi shell)
2. **Scripting**: Selalu gunakan `--json` untuk parsing hasil di script
3. **Markdown Files**: Gunakan `$(cat file.md)` atau `--template file.md`
4. **Dry Run**: Gunakan `--json` untuk lihat output sebelum execute
5. **Config Location**: `~/.qpm/config.json` menyimpan token dan server URL
