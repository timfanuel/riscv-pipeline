#!/usr/bin/env bash
# One-time environment setup. Run from the repo root:  bash scripts/setup.sh
# Supports Ubuntu / WSL2 (x86_64) and macOS (Apple Silicon or Intel).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS="$ROOT/.tools"
mkdir -p "$TOOLS"

# ---- 1. OSS CAD Suite: Verilator 5.x, Icarus, Yosys, GTKWave in one bundle ----
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)  ASSET="linux-x64" ;;
  Darwin-arm64)  ASSET="darwin-arm64" ;;
  Darwin-x86_64) ASSET="darwin-x64" ;;
  *) echo "Unsupported platform: $(uname -s)-$(uname -m)"; exit 1 ;;
esac

if [ ! -d "$TOOLS/oss-cad-suite" ]; then
  echo ">> Downloading latest OSS CAD Suite ($ASSET)..."
  URL=$(curl -fsSL https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest \
        | grep -o "https://[^\"]*oss-cad-suite-$ASSET-[0-9]*\.tgz" | head -1)
  [ -n "$URL" ] || { echo "Could not find a release asset; download manually from"
                     echo "https://github.com/YosysHQ/oss-cad-suite-build/releases"; exit 1; }
  curl -fL "$URL" -o "$TOOLS/oss-cad-suite.tgz"
  tar -xzf "$TOOLS/oss-cad-suite.tgz" -C "$TOOLS"
  rm "$TOOLS/oss-cad-suite.tgz"
fi

# ---- 1b. Icarus launchers for cocotb ----
# OSS CAD Suite's bin/vvp wrapper sets PYTHONHOME to its bundled Python, which
# clashes with the venv's Python that cocotb is built against. These launchers
# run the real binaries without that override; env.sh points cocotb at them.
if [ "$(uname -s)" = Linux ]; then
SHIM="$TOOLS/icarus-shim"
OCS="$TOOLS/oss-cad-suite"
mkdir -p "$SHIM"
cat > "$SHIM/vvp" <<EOF
#!/bin/sh
exec "$OCS/lib/ld-linux-x86-64.so.2" --inhibit-cache --inhibit-rpath "" --library-path "$OCS/lib" "$OCS/libexec/vvp" "\$@"
EOF
cat > "$SHIM/iverilog" <<EOF
#!/bin/sh
exec "$OCS/bin/iverilog" "\$@"
EOF
chmod +x "$SHIM/vvp" "$SHIM/iverilog"
fi

# ---- 2. Python venv: cocotb + OpenLane 2 ----
if [ ! -d "$ROOT/.venv" ]; then
  echo ">> Creating Python venv..."
  python3 -m venv "$ROOT/.venv"
fi
"$ROOT/.venv/bin/pip" install -q --upgrade pip
"$ROOT/.venv/bin/pip" install -q -r "$ROOT/requirements.txt"

# ---- 3. Docker check (OpenLane runs its tools inside a container) ----
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  echo ">> Docker OK."
else
  echo "!! Docker not reachable. Install Docker Desktop (enable WSL2 integration on Windows),"
  echo "   start it, then rerun this script. Simulation still works without it."
fi

cat <<EOF

Setup done. In each new terminal, run:
    source scripts/env.sh
Then try:
    make test-flow      # cocotb tests on the flow-test block
    make harden-flow    # OpenLane RTL-to-GDS on Sky130 (first run downloads the PDK, ~1-2 GB)
EOF
