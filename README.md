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


<a href="https://www.star-history.com/?repos=RecomBox%2FRecomBox&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=RecomBox/RecomBox&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=RecomBox/RecomBox&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=RecomBox/RecomBox&type=date&legend=top-left" />
 </picture>
</a>

# Download


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
<img width="1920" height="1080" alt="Screenshot (551)" src="https://github.com/user-attachments/assets/a8f41e0e-1430-4243-89e1-727f556abf2a" />

### View
<img width="1920" height="1080" alt="Screenshot (552)" src="https://github.com/user-attachments/assets/b6455082-1b4c-48ec-958b-26d0270fd468" />

### Search
<img width="1920" height="1080" alt="Screenshot (553)" src="https://github.com/user-attachments/assets/f926264a-b776-4c39-b77b-959382ce91ff" />

### Download
<img width="1920" height="1080" alt="Screenshot (554)" src="https://github.com/user-attachments/assets/fb96d09d-dec6-4099-89f4-f1dbaa401cfd" />


### Watch
<img width="1920" height="1080" alt="Screenshot (555)" src="https://github.com/user-attachments/assets/9f8c7c83-2682-4ff6-9dc7-abc7461e578c" />

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
