#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -x "$ROOT/.tools/jdk/Contents/Home/bin/java" ]]; then
  export JAVA_HOME="$ROOT/.tools/jdk/Contents/Home"
fi
cd "$ROOT/services/api"
exec ./gradlew bootRun
