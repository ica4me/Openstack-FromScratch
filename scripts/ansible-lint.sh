#!/usr/bin/env bash
set -euo pipefail

if ! command -v ansible-lint >/dev/null 2>&1; then
  python3 -m pip install --user ansible-lint
fi

ansible-lint .
