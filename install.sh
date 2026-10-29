#!/usr/bin/env bash
# Install orgo-deploy and the deploy-to-orgo Hermes skill on an Orgo computer (run as root).
#   curl -fsSL https://raw.githubusercontent.com/nickvasilescu/orgo-deploy/main/install.sh | bash
# Then: orgo-deploy setup   (asks for your Orgo API key; it never leaves this computer)
set -euo pipefail
SRC="${ORGO_DEPLOY_SRC:-https://raw.githubusercontent.com/nickvasilescu/orgo-deploy/main}"
[ "$(id -u)" = 0 ] || { echo "run as root"; exit 1; }
command -v supervisorctl >/dev/null || { echo "supervisord not found (Orgo agent templates ship it)"; exit 1; }

fetch() { if [ -f "$SRC/$1" ]; then cat "$SRC/$1"; else curl -fsSL "$SRC/$1"; fi; }
fetch bin/orgo-deploy > /usr/local/bin/orgo-deploy
chmod 755 /usr/local/bin/orgo-deploy

skills="${HERMES_HOME:-/root/.hermes}/skills"
if [ -d "$skills" ]; then
  mkdir -p "$skills/devops/deploy-to-orgo"
  fetch skill/deploy-to-orgo/SKILL.md > "$skills/devops/deploy-to-orgo/SKILL.md"
  echo "installed skill: $skills/devops/deploy-to-orgo"
fi
echo "installed /usr/local/bin/orgo-deploy"
if [ -n "${ORGO_API_KEY:-}" ]; then orgo-deploy setup; else
  echo "next: run 'orgo-deploy setup' to save an Orgo API key on this computer"; fi
