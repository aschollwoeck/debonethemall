#!/usr/bin/env bash
# Run the GUT test suite headless. Usage: ./run_tests.sh
set -euo pipefail
cd "$(dirname "$0")"

# Find the local Godot binary (kept in the project folder, gitignored).
GODOT="$(ls -1 ./Godot_v*_linux.x86_64 2>/dev/null | head -1 || true)"
if [[ -z "${GODOT}" ]]; then
	echo "Godot binary not found (expected ./Godot_v*_linux.x86_64). Set GODOT env var or place it here." >&2
	exit 1
fi

exec "${GODOT}" --headless -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json "$@"
