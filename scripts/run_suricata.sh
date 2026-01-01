diff --git a/scripts/run_suricata.sh b/scripts/run_suricata.sh
new file mode 100755
index 0000000000000000000000000000000000000000..6c4b3317768fc45363d89a60b5331234116d326d
--- /dev/null
+++ b/scripts/run_suricata.sh
@@ -0,0 +1,37 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+if [[ $EUID -ne 0 ]]; then
+  echo "Please run as root (use sudo)." >&2
+  exit 1
+fi
+
+if [[ $# -lt 1 ]]; then
+  echo "Usage: $0 <interface>" >&2
+  exit 1
+fi
+
+INTERFACE="$1"
+CONFIG_FILE="/etc/suricata/suricata.yaml"
+
+if ! command -v suricata >/dev/null 2>&1; then
+  echo "Suricata is not installed. Run scripts/setup_suricata.sh first." >&2
+  exit 1
+fi
+
+if ! ip link show "$INTERFACE" >/dev/null 2>&1; then
+  echo "Interface $INTERFACE not found." >&2
+  exit 1
+fi
+
+if [[ ! -f "$CONFIG_FILE" ]]; then
+  echo "Config file $CONFIG_FILE not found." >&2
+  exit 1
+fi
+
+systemctl stop suricata || true
+
+suricata -c "$CONFIG_FILE" -i "$INTERFACE" -D
+
+echo "Suricata started in IDS mode on $INTERFACE."
+echo "View logs with: tail -f /var/log/suricata/eve.json"
