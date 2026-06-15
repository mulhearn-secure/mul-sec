AFTER-ACTION REPORT: USB Power Management Conflict Resolution
Date: June 07, 2026
System: TUF Gaming Laptop (Alder Lake-N Platform)
OS: Fedora Linux
Subject: Resolution of Input Device Latency Causing User Experience Degradation

1. Executive Summary
An investigation was conducted following user reports of significant input latency and unresponsiveness with a wired USB mouse. The issue manifested as a requirement for physical button interaction to "wake" the cursor before movement was registered. Root cause analysis identified a conflict between two system power management utilities: TLP (configured to disable USB autosuspend) and Powertop (executing aggressive --auto-tune policies). The latter was overriding kernel-level power settings post-boot, re-enabling autosuspend on critical input devices. The conflict was resolved by disabling the Powertop override mechanism and enforcing a persistent kernel parameter to disable USB runtime power management.

2. Incident Description & Symptoms
Symptom: Wired USB mouse becomes unresponsive after periods of inactivity. Cursor movement requires a left/right click event to trigger wake-up from a low-power state.
Severity: High (Impact on usability and productivity).
Scope: Affects all USB HID (Human Interface Device) inputs, specifically mice and keyboards.
Timeline: Issue persisted immediately following the installation and execution of powertop --auto-tune alongside standard tlp configuration.
3. Technical Analysis
3.1 Initial Configuration State
The system was configured with TLP (v1.10+) for power optimization.

Target Config (/etc/tlp.conf):
USB_AUTOSUSPEND=0 (Intended to disable global USB sleep).
USB_DENYLIST="062a:7269 30fa:2052" (Explicit exclusion of specific device IDs).
Applied Actions: sudo systemctl restart tlp.
3.2 Root Cause Identification
Analysis of tlp-stat -s and manual inspection of /sys/bus/usb/devices/*/power/control revealed that while TLP correctly applied its configuration upon startup, the kernel state was subsequently reverted.

Conflicting Agent: Powertop.
Mechanism: The command sudo powertop --auto-tune sets specific tunables in /sys/bus/ interfaces to their most aggressive power-saving states (auto).
Conflict Vector: Even if TLP sets power/control to on, Powertop's persistence service (or repeated manual invocation) resets these flags to auto either at boot or during idle cycles.
Evidence:
# Pre-fix State (via lsusb path inspection)
/sys/bus/usb/devices/.../power/control: auto  <-- Sleeping allowed
Despite USB_AUTOSUSPEND=0 in tlp.conf, the kernel honored the Powertop override.
3.3 Powertop Output Analysis
Review of the provided pasted-content-2026-06-07.txt log indicated numerous "Bad" runtime PM statuses for chipset components, but more critically, confirmed that Powertop was actively managing USB host controllers. The log showed:

Good          Autosuspend for USB device Full-Speed Mouse [Full-Speed Mouse]

While marked "Good" for power efficiency, this directly conflicted with the operational requirement for instant input response.

4. Remediation Actions Taken
Phase 1: Immediate Mitigation
Verification: Confirmed syntax correctness of /etc/tlp.conf.
Manual Override: Executed a direct kernel write to force USB devices out of suspend mode:
for dev in /sys/bus/usb/devices/*/power/control; do echo on | sudo tee $dev > /dev/null; done
Result: Immediate restoration of mouse functionality without button-click wake-up required.
Phase 2: Persistence & Hardening
To prevent recurrence upon reboot or service restart, the following actions were executed:

Disable Conflicting Services: Identified and disabled any active powertop systemd services preventing state reversion.
sudo systemctl disable --now powertop.service
sudo systemctl disable --now powertop-autotune.service
Implement Persistent Policy: Created a dedicated systemd unit fix-usb-power.service to enforce the on state at boot, ensuring precedence over TLP's initialization sequence.
Unit Path: /etc/systemd/system/fix-usb-power.service
Action: Runs a one-shot shell script iterating through all USB device nodes and writing on to power/control.
Status: Enabled and Active.
5. Verification & Testing
Method: System reboot followed by observation of input behavior.
Check: Ran cat /sys/bus/usb/devices/*/power/control post-boot. All values returned on.
User Test: Moved mouse after extended idle period (5+ minutes). Cursor movement was instantaneous; no click-to-wake required.
Status: RESOLVED.
6. Recommendations & Best Practices
Avoid Aggressive Auto-Tuning: Do not use powertop --auto-tune as a permanent fix. It is designed for diagnostics and temporary testing. It often conflicts with distribution-specific power managers like TLP or Fedora's native upower.
Granular Control: When using TLP, rely on USB_DENYLIST for specific hardware (mouse/keyboard/wifi) rather than globally disabling USB_AUTOSUSPEND unless necessary.
Service Monitoring: Regularly audit systemd services for duplicate power management logic (e.g., having both TLP and a custom Powertop service enabled).
Realtek WiFi Note: The system contains a Realtek RTL8821CE adapter, which is flagged as "Bad" for Runtime PM. It is recommended to also apply a similar persistent "force-on" rule for this PCI device to prevent intermittent network disconnects, should they occur.
Report Prepared By: Mul-sec
Classification: Internal Technical Record
Status: Closed
