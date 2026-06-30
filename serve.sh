#!/usr/bin/env bash
# Launch the local al-folio preview, detached so it survives the calling shell.
# Overrides baseurl to "" so links resolve at the localhost root, and serves
# on port 4001 (academicpages uses 4000). Logs to /tmp/personalsite_serve.log.
set -euo pipefail
cd "$(dirname "$0")"
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:$PATH"

pkill -f 'jekyll serve.*--port 4001' 2>/dev/null || true

# The prebuilt _site uses root-relative asset paths (/assets/...), so mount it
# at the root. URL: http://localhost:4001/
exec bundle exec jekyll serve --baseurl "" -H localhost --port 4001 --no-watch --skip-initial-build
