#!/usr/bin/env bash
# Real Church Manager — PocketBase launcher (POSIX-safe Linux/macOS).
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

PB_BIN="$DIR/pocketbase"
PB_VERSION="${PB_VERSION:-0.22.21}"

if [ ! -x "$PB_BIN" ]; then
  echo "→ PocketBase chưa có. Đang tải v$PB_VERSION..."
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) echo "❌ Kiến trúc không hỗ trợ: $ARCH"; exit 1 ;;
  esac
  case "$OS" in
    darwin|linux) ;;
    *) echo "❌ OS không hỗ trợ: $OS (Windows dùng start.bat)"; exit 1 ;;
  esac
  URL="https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_${OS}_${ARCH}.zip"
  echo "  $URL"
  TMP="$(mktemp -d)"
  curl -fsSL "$URL" -o "$TMP/pb.zip"
  unzip -q "$TMP/pb.zip" -d "$TMP"
  mv "$TMP/pocketbase" "$PB_BIN"
  chmod +x "$PB_BIN"
  rm -rf "$TMP"
  echo "✓ Tải xong: $PB_BIN"
fi

ADDR="${ADDR:-127.0.0.1:8090}"
echo "→ Chạy PocketBase trên http://$ADDR"
echo "  Admin UI: http://$ADDR/_/"
echo "  Stop: Ctrl+C"
echo ""
exec "$PB_BIN" serve --http="$ADDR" --dir="$DIR/pb_data" --hooksDir="$DIR/pb_hooks" --migrationsDir="$DIR/pb_migrations"
