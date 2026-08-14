#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration ---
APP_NAME="RecomBox"
BINARY_NAME="recombox"
INSTALL_DIR="/opt/$BINARY_NAME"
BIN_LINK="/usr/local/bin/$BINARY_NAME"
DESKTOP_FILE="/usr/share/applications/${BINARY_NAME}.desktop"

echo "🗑️  Starting uninstallation of $APP_NAME..."

# Error handling function
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# 1. Dependency Check
command -v sudo >/dev/null 2>&1 || error_exit "sudo is required but not installed."

# 2. Confirm before proceeding
read -r -p "This will remove $APP_NAME ($INSTALL_DIR, $BIN_LINK, $DESKTOP_FILE). Continue? [y/N] " confirm
case "$confirm" in
    [yY][eE][sS]|[yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

# 3. Remove the symlink
if [ -L "$BIN_LINK" ] || [ -e "$BIN_LINK" ]; then
    echo "🔗 Removing symlink $BIN_LINK..."
    sudo rm -f "$BIN_LINK"
else
    echo "ℹ️  No symlink found at $BIN_LINK, skipping."
fi

# 4. Remove the install directory
if [ -d "$INSTALL_DIR" ]; then
    echo "📂 Removing $INSTALL_DIR..."
    sudo rm -rf "$INSTALL_DIR"
else
    echo "ℹ️  No install directory found at $INSTALL_DIR, skipping."
fi

# 5. Remove the desktop entry
if [ -f "$DESKTOP_FILE" ]; then
    echo "🎨 Removing menu shortcut $DESKTOP_FILE..."
    sudo rm -f "$DESKTOP_FILE"
else
    echo "ℹ️  No desktop entry found at $DESKTOP_FILE, skipping."
fi

# 6. Refresh desktop database if available (non-fatal if missing)
if command -v update-desktop-database >/dev/null 2>&1; then
    sudo update-desktop-database /usr/share/applications/ >/dev/null 2>&1 || true
fi

echo "---"
echo "✅ Success! $APP_NAME has been uninstalled."