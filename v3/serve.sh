#!/usr/bin/env bash
# Serve web-preview on the local network so you can open it on a phone.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PORT="${PORT:-8765}"

cd "$ROOT"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required"
  exit 1
fi

IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "YOUR_MAC_IP")"

echo ""
echo "  Comnts mobile prototype"
echo "  -----------------------"
echo "  On this Mac:   http://127.0.0.1:${PORT}/"
echo "  On your phone: http://${IP}:${PORT}/"
echo ""
echo "  Same Wi‑Fi as the Mac. Then open the URL in Safari."
echo "  Optional: Share → Add to Home Screen for fullscreen."
echo ""
echo "  Ctrl+C to stop."
echo ""

exec python3 - "$PORT" <<'PY'
import http.server
import sys

PORT = int(sys.argv[1])

class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, max-age=0")
        self.send_header("Pragma", "no-cache")
        super().end_headers()

    def log_message(self, format, *args):
        sys.stderr.write("%s - %s\n" % (self.address_string(), format % args))

server = http.server.ThreadingHTTPServer(("0.0.0.0", PORT), NoCacheHandler)
server.serve_forever()
PY
