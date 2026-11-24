#!/bin/sh
# Xcode Cloud (App Store Connect builds) runs this after cloning the repository, before xcodebuild.
# The "TABFLOW Extension" target builds the Safari web extension from src/ with Node.js
# (apple/scripts/build-safari-extension.sh), and Xcode Cloud's Macs have no Node.js. Without this script that build
# phase stops with "error: TABFLOW extension build: Node.js was not found" ("Command PhaseScriptExecution failed").
# Installs Node.js with Homebrew only when a usable one (22.18 or newer) is missing. Local Xcode builds never run it.
set -eu
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1
PATH="${TABFLOW_BREW_PATHS:-/opt/homebrew/bin:/usr/local/bin}:$PATH"   # where Homebrew links node; the build phase looks there too
export PATH

usable() {
  command -v node >/dev/null 2>&1 &&
    node -e 'const [a,b]=process.versions.node.split(".").map(Number);process.exit(a>22||(a===22&&b>=18)?0:1)' 2>/dev/null
}

if ! usable; then
  command -v brew >/dev/null 2>&1 || { echo "error: TABFLOW: Node.js 22.18+ is needed to build the Safari extension, and Homebrew is not available to install it."; exit 1; }
  echo "TABFLOW: installing Node.js with Homebrew (needed by the TABFLOW Extension build phase)"
  brew install node || brew upgrade node
  usable || { echo "error: TABFLOW: Node.js 22.18+ is still not available after brew install node."; exit 1; }
fi
echo "TABFLOW: using Node.js $(node -p process.versions.node) ($(command -v node))"
