#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration ---
APP_NAME="RecomBox"
BINARY_NAME="recombox"
INSTALL_DIR="/opt/$BINARY_NAME"
BIN_LINK="/usr/local/bin/$BINARY_NAME"

# Specific URLs
TAR_URL="https://github.com/RecomBox/RecomBox/releases/latest/download/recombox-linux-x86_64.tar.gz"
ICON_URL="https://github.com/RecomBox/RecomBox/blob/main/assets/icon/icon-transparent.png?raw=true"

# Local temporary filename
LOCAL_TAR="${BINARY_NAME}.tar.gz"

echo "🚀 Starting installation of $APP_NAME..."

# Error handling function
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# 1. Dependency Check
for tool in curl tar sudo file; do
    command -v $tool >/dev/null 2>&1 || error_exit "$tool is required but not installed."
done

# 2. Workspace Setup
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT 
cd "$TEMP_DIR"

# 3. Download the Tarball
echo "📦 Downloading latest release..."
if ! curl -Lf "$TAR_URL" -o "$LOCAL_TAR"; then
    error_exit "Download failed. Check the URL: $TAR_URL"
fi

# 4. Integrity Check
if ! file "$LOCAL_TAR" | grep -q "gzip"; then
    error_exit "Downloaded file is not a valid gzip archive. Verify your release upload on GitHub."
fi

# 5. Deployment
echo "📂 Extracting to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo rm -rf "${INSTALL_DIR:?}"/* 
sudo tar -xzf "$LOCAL_TAR" -C "$INSTALL_DIR" --strip-components=1 || error_exit "Extraction failed."

# 6. Specific Binary Verification
if [ ! -f "$INSTALL_DIR/$BINARY_NAME" ]; then
    error_exit "Expected binary '$BINARY_NAME' was not found in the extracted files."
fi

# 7. Permissions and Linking
echo "⚙️  Setting permissions and symlinks..."
sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
sudo ln -sf "$INSTALL_DIR/$BINARY_NAME" "$BIN_LINK"

# 8. Icon and Desktop Entry
echo "🎨 Setting up menu shortcut..."
if ! sudo curl -Lf "$ICON_URL" -o "$INSTALL_DIR/icon.png"; then
    echo "⚠️  Warning: Icon download failed, but the app was installed."
fi

# Ensure the applications directory exists
sudo mkdir -p /usr/share/applications/

# FIX: Using 'tee' to handle redirection with sudo privileges
cat <<EOF | sudo tee "/usr/share/applications/${BINARY_NAME}.desktop" > /dev/null
[Desktop Entry]
Type=Application
Name=$APP_NAME
Comment=Stream movies and videos via torrent
Exec=$BIN_LINK
Icon=$INSTALL_DIR/icon.png
Terminal=false
Categories=AudioVideo;Video;Player;Network;
Keywords=movie;torrent;streaming;p2p;recombox;
EOF

echo "---"
echo "✅ Success! $APP_NAME has been installed."
echo "👉 Run it from your Application Menu or type '$BINARY_NAME' in your terminal."