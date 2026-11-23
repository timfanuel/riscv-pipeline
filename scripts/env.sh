# Source this in each terminal:  source scripts/env.sh
_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
# OSS CAD Suite goes after the system PATH so the venv's python3 is the one used.
export PATH="$PATH:$_ROOT/.tools/oss-cad-suite/bin"
source "$_ROOT/.venv/bin/activate"
# cocotb uses these Icarus launchers (made by setup.sh) instead of OSS CAD's wrappers.
[ -d "$_ROOT/.tools/icarus-shim" ] && export ICARUS_BIN_DIR="$_ROOT/.tools/icarus-shim"
echo "env ready: $(verilator --version 2>/dev/null | head -1) | cocotb $(python -c 'import cocotb;print(cocotb.__version__)')"
unset _ROOT
