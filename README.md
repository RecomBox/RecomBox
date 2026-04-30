<!--
[<img src="https://github.com/GoodDay360/HyperionBox/blob/main/public/1500x500-banner.png?raw=true">](/)
-->
<div>
    <a href="https://discord.gg/TkArvnVvNG">
        <img src="https://dcbadge.limes.pink/api/server/TkArvnVvNG?style=flat" />
    </a>
    <a href="https://github.com/RecomBox/RecomBox/releases">
        <img src="https://img.shields.io/github/v/release/GoodDay360/HyperionBox" />
    </a>
    <a href="https://github.com/RecomBox/RecomBox/releases">
        <img src="https://img.shields.io/github/downloads/GoodDay360/HyperionBox/total?color=green" />
    </a>
    <a href="https://github.com/RecomBox/RecomBox/HyperionBox">
        <img src="https://img.shields.io/badge/human-coded-purple?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmZmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1wZXJzb24tc3RhbmRpbmctaWNvbiBsdWNpZGUtcGVyc29uLXN0YW5kaW5nIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjUiIHI9IjEiLz48cGF0aCBkPSJtOSAyMCAzLTYgMyA2Ii8+PHBhdGggZD0ibTYgOCA2IDIgNi0yIi8+PHBhdGggZD0iTTEyIDEwdjQiLz48L3N2Zz4=" />
    </a>
    <a href="https://deepwiki.com/GoodDay360/HyperionBox">
        <img src="https://deepwiki.com/badge.svg" />
    </a>
    <a href="https://github.com/RecomBox/RecomBox">
        <img src="https://img.shields.io/github/stars/RecomBox/RecomBox" />
    </a>
    
</div>


# Download
[![Download](https://img.shields.io/badge/Download-GitHub-blue?style=for-the-badge&logo=github)](https://github.com/GoodDay360/HyperionBox/releases/latest)

# What's RecomBox?
An open-source cross-platform torrent streaming app for Anime, Movies, and TV with cross-device watch progress tracking. 

# ✨ Features
- 🎬 **Stream Torrent** seamlessly from various sources.
- 📌 **Track your watch progress** and pick up where you left off.
- ☁️ **Google Drive Back Up** to sync your favorites and watch history across all your devices.
- ⬇️ **Download** for offline watching.
- 🔍 **Advanced search** for quick content discovery.
- 🧩 **Plugins**: add and update external torren provider without update entire app.

<!--

# How to use?
[Watch this video on YouTube](https://youtu.be/M32efmieHIg)
-->

### Tech Stack
![Flutter](https://img.shields.io/badge/flutter-%2320232a?style=for-the-badge&logo=flutter&logoColor=%2361DAFB) ![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=for-the-badge&logo=rust&logoColor=white) ![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white) 



# 📸 Screenshot
### Home
<img width="1920" height="1080" alt="Screenshot (551)" src="https://github.com/user-attachments/assets/ca13e8a7-837b-4a08-b0db-c83d7d63338a" />

### View
<img width="1920" height="1080" alt="Screenshot (552)" src="https://github.com/user-attachments/assets/886a6bc0-b86f-46ff-bad5-e167005e5169" />

### Search
<img width="1920" height="1080" alt="Screenshot (553)" src="https://github.com/user-attachments/assets/c4d57d17-370f-4d23-ab1c-1900eb446128" />

### Download
<img width="1920" height="1080" alt="Screenshot (554)" src="https://github.com/user-attachments/assets/a6b7a1cb-68c7-4498-bef4-0345308b341d" />

### Watch
<img width="1920" height="1080" alt="Screenshot (555)" src="https://github.com/user-attachments/assets/bf674089-1809-44cf-aac6-5b8463b5156d" />

# Contribution Guide




## Prerequisites

This project is built with [Tauri](https://v2.tauri.app/start/prerequisites/).  
Make sure you have installed all required prerequisites for your operating system.

## Package Manager & Frameworks

I use [Bun](https://bun.sh/) for package management. While Bun doesn’t directly affect how the app runs (since Tauri handles rendering), I prefer it for convenience. You’re free to use another package manager, but please avoid committing changes that are only needed for your local setup.  

The application itself is developed with **SolidJS** for the frontend and  css reset from **Bootstrap**, all running inside Tauri.

## Setup

Install the dependencies:

```bash
bun install
```

### Start a development

```bash
bun tauri dev
```
### Production

Build the application for production:

```bash
bun tauri build
```
