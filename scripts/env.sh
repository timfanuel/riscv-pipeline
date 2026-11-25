# Source this in each terminal:  source scripts/env.sh
_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
# OSS CAD Suite goes after the system PATH so the venv's python3 is the one used.
export PATH="$PATH:$_ROOT/.tools/oss-cad-suite/bin"
source "$_ROOT/.venv/bin/activate"
# cocotb uses these Icarus launchers (made by setup.sh) instead of OSS CAD's wrappers.
[ -d "$_ROOT/.tools/icarus-shim" ] && export ICARUS_BIN_DIR="$_ROOT/.tools/icarus-shim"
# The venv only works with the Python it was built with, so it can't be shared
# between WSL distros (e.g. Ubuntu-22.04 vs a newer "Ubuntu").
if ! python -c 'import cocotb' >/dev/null 2>&1; then
  echo "!! cocotb not found for $(python --version 2>&1) in $(. /etc/os-release; echo "$PRETTY_NAME")."
  echo "   The venv was built with: $(grep '^version' "$_ROOT/.venv/pyvenv.cfg" | cut -d' ' -f3)"
  echo "   If you're in the wrong WSL distro, open the right one (on Windows: wsl -d Ubuntu-22.04)."
  echo "   Otherwise rebuild the venv: rm -rf .venv && bash scripts/setup.sh"
  unset _ROOT; return 1 2>/dev/null || exit 1
fi
echo "env ready: $(verilator --version 2>/dev/null | head -1) | cocotb $(python -c 'import cocotb;print(cocotb.__version__)')"
unset _ROOT
