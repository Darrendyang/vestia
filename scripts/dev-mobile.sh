#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -x "$ROOT/.tools/flutter/bin/flutter" ]]; then
  FLUTTER="$ROOT/.tools/flutter/bin/flutter"
elif command -v flutter >/dev/null 2>&1; then
  FLUTTER="$(command -v flutter)"
else
  echo "Flutter SDK 未找到，请安装 Flutter 或准备项目本地工具链。" >&2
  exit 1
fi
DEVICE="${DEVICE:-chrome}"
API_URL="${AISHOP_API_URL:-http://127.0.0.1:8080}"
export FLUTTER_STORAGE_BASE_URL="${FLUTTER_STORAGE_BASE_URL:-https://storage.flutter-io.cn}"
export PUB_HOSTED_URL="${PUB_HOSTED_URL:-https://pub.flutter-io.cn}"
cd "$ROOT/apps/mobile"
exec "$FLUTTER" run -d "$DEVICE" --dart-define="AISHOP_API_URL=$API_URL"
