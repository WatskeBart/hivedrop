# 🍯 HiveDrop

A containerized file distribution server that automatically downloads and serves software packages, extensions, and installers. Built with [unprivileged Nginx](https://hub.docker.com/r/nginxinc/nginx-unprivileged) for security.

## 🚀 Quick Start

```bash
# Pull and run the latest image
docker run --rm -p 8080:8080 ghcr.io/watskebart/hivedrop:latest
```

Navigate to [http://localhost:8080](http://localhost:8080) to browse available downloads.

## 📦 Available Downloads

- **VS Code Extensions** - Latest `.vsix` files from Microsoft Marketplace
- **Windows Software Installers** - Popular applications via Winget

## 🔄 Automated Updates

New container images build automatically:
- **Schedule**: Every Sunday at 22:00 UTC
- **Trigger**: Latest downloads from configured package lists
- **Registry**: `ghcr.io/watskebart/hivedrop:latest`

## 📁 Repository Structure

```
├── pollen/                     # 🌼 Download configuration
│   ├── vscode-extensions.txt   # VS Code extension IDs
│   └── winget-installers.txt   # Winget package IDs
├── honey/                      # 🍯 Downloaded files (generated)
│   ├── vscode-extensions/      # .vsix files
│   └── winget-installers/      # .exe/.msi/.msixbundle installers
└── scripts/                    # 🛠️ Download automation
    └── winget-downloader.ps1
```

### 🌼 Pollen (Configuration)

Contains package lists that define what gets downloaded:

- `vscode-extensions.txt` - One extension ID per line (e.g., `ms-python.python`)
- `winget-packages.txt` - One package ID per line (e.g., `Microsoft.VisualStudioCode`)

### 🍯 Honey (Artifacts)

Auto-generated directory containing downloaded files, served by Nginx.

## 🛠️ Development

### Adding Packages

1. **VS Code Extensions**: Add extension ID to `pollen/vscode-extensions.txt`
2. **Software**: Add package ID to `pollen/winget-installers.txt`

Find package IDs:
- VS Code: [Marketplace](https://marketplace.visualstudio.com/vscode) URLs contain IDs
- Winget: Use `winget search <app-name>` or browse [winget.run](https://winget.run)

### Local Testing

```bash
# Clone and build
git clone <repo-url>
cd hivedrop
docker build -t hivedrop:local .
docker run --rm -p 8080:8080 hivedrop:local
```

## 📋 Download Methods

- **VS Code Extensions**: Downloaded via [`offvsix`](https://pypi.org/project/offvsix/) Python package
- **Winget Packages**: Custom PowerShell script extracts installer URLs and downloads directly

## ⚡ Features

- **Rootless Security**: Runs as non-root user
- **Weekly Updates**: Fresh downloads every Sunday
- **Simple Web UI**: Default Nginx file browser interface
- **Offline Ready**: All files available without internet