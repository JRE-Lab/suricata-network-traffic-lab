diff --git a/lab/LAB.md b/lab/LAB.md
new file mode 100644
index 0000000000000000000000000000000000000000..a8835999b3f7aba5b1de46a9514c033abacf0ee5
--- /dev/null
+++ b/lab/LAB.md
@@ -0,0 +1,139 @@
+# Suricata Network Traffic Lab (Ubuntu)
+
+This lab guides you through installing Suricata, running it in IDS mode, generating traffic, and validating alerts in `eve.json`.
+
+## Outcomes
+
+- Install Suricata from the official OISF repository.
+- Run Suricata in IDS (passive) mode.
+- Generate ICMP and HTTP traffic.
+- Validate detections in `eve.json`.
+- Create a local rule and confirm it fires.
+
+## Prerequisites
+
+- Ubuntu 22.04+ (or 20.04 with minor adjustments)
+- `sudo` privileges
+- Internet access to install packages
+
+## 1) Install Suricata and tools
+
+Run the helper script or copy the commands below.
+
+```bash
+sudo ./scripts/setup_suricata.sh
+```
+
+The helper script installs Suricata, downloads updated rules, and validates the default configuration.
+
+Manual commands:
+
+```bash
+sudo apt-get update
+sudo apt-get install -y software-properties-common
+sudo add-apt-repository -y ppa:oisf/suricata-stable
+sudo apt-get update
+sudo apt-get install -y suricata jq tcpdump curl
+sudo suricata-update
+sudo suricata -T -c /etc/suricata/suricata.yaml
+```
+
+## 2) Identify your network interface
+
+List interfaces and pick the one with an IP address (often `eth0`, `ens160`, `enp0s3`, or `wlan0`).
+
+```bash
+ip -br addr
+```
+
+## 3) Run Suricata in IDS mode
+
+Use the helper script to start Suricata on your chosen interface.
+
+```bash
+sudo ./scripts/run_suricata.sh eth0
+```
+
+This creates logs in:
+
+- `/var/log/suricata/eve.json`
+- `/var/log/suricata/fast.log`
+
+## 4) Generate traffic
+
+### ICMP traffic
+
+```bash
+ping -c 4 8.8.8.8
+```
+
+### HTTP traffic
+
+Start a local web server:
+
+```bash
+python3 -m http.server 8080
+```
+
+In another terminal:
+
+```bash
+curl -I http://127.0.0.1:8080
+```
+
+## 5) View alerts and events
+
+```bash
+sudo tail -f /var/log/suricata/eve.json
+```
+
+Filter alerts only:
+
+```bash
+sudo jq 'select(.event_type=="alert")' /var/log/suricata/eve.json
+```
+
+## 6) Add a local rule
+
+Copy the provided rule to your Suricata rules directory:
+
+```bash
+sudo cp rules/local.rules /etc/suricata/rules/local.rules
+sudo suricata-update
+sudo systemctl restart suricata
+```
+
+The included rule generates an alert on ICMP echo requests.
+
+Re-run the ping from step 4 and verify the alert:
+
+```bash
+sudo jq 'select(.alert.signature=="LAB ICMP Echo Request")' /var/log/suricata/eve.json
+```
+
+## 7) Stop Suricata
+
+If you started Suricata with the helper script, stop it with:
+
+```bash
+sudo pkill suricata
+```
+
+If you started Suricata with systemd:
+
+```bash
+sudo systemctl stop suricata
+```
+
+## Troubleshooting
+
+- If you see no alerts, confirm the correct interface and rerun the IDS command.
+- Verify Suricata is running: `pgrep -a suricata` or `sudo systemctl status suricata`.
+- Ensure `local.rules` is referenced in `/etc/suricata/suricata.yaml` (default on Ubuntu).
+
+## Clean up
+
+```bash
+sudo apt-get remove -y suricata
+sudo rm -rf /var/log/suricata
+```
