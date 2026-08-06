#!/usr/bin/env bash
# GhostGPS — одна команда для Mac. Ставит зависимости, поднимает туннель и сервер.
set -euo pipefail
cd "$(dirname "$0")"

PY="${PYTHON:-python3}"

if [ ! -d .venv ]; then
  echo "==> Создаю окружение (.venv)…"
  "$PY" -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate

echo "==> Устанавливаю пакет и зависимости…"
pip install -q --upgrade pip >/dev/null
pip install -q -e .

# iOS 17+ требует туннель от root (RemoteServiceDiscovery через tunneld).
echo "==> Поднимаю туннель к iPhone (нужен пароль Mac для sudo)…"
sudo -v
sudo "$(pwd)/.venv/bin/python" -m pymobiledevice3 remote tunneld >/tmp/ghost_tunneld.log 2>&1 &
TUN=$!
trap 'sudo kill "$TUN" 2>/dev/null || true' EXIT
sleep 5

echo "==> Стартую GhostGPS…"
python server.py
