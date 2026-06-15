# ~/.bashrc — Training-mode, non-destructive (safe) for learners
# Purpose: suggest commands only (never executes destructive actions)
#version 1 26-04-23
# If not run-ning interactively, don't do anything
[[ -z $PS1 ]] && return

# -------------------------
# --- 1. Safety & Hygiene
# -------------------------
# Clear cloud creds so they don't sit in memory
unset AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID GOOGLE_API_KEY

# Hardening Bash History (CyberSec Best Practice)
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

# -------------------------
# --- 2. Distro detection
# -------------------------
_detect_distro() {
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    case "${ID,,}" in
      ubuntu|debian|pop|linuxmint) echo "debian_like"; return ;;
      # arch) echo "arch"; return ;; # Commented out per request
      rhel|centos|fedora|rocky|almalinux|nobara) echo "rhel_like"; return ;;
      *) echo "other"; return ;;
    esac
  else
    echo "other"
  fi
}
DISTRO_FAMILY=$(_detect_distro)

# -------------------------
# --- 3. Prompt (Classic NT/2000 focus)
# -------------------------
git_branch_update() {
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch_cached=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    git_branch_cached=" ($git_branch_cached)"
  else
    git_branch_cached=""
  fi
}

PROMPT_COMMAND="git_branch_update"
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$git_branch_cached\[\e[0m\]\$ '

# -------------------------
# --- 4. Safe training aliases
# -------------------------
if [[ $DISTRO_FAMILY == "rhel_like" ]]; then
  alias update='echo "→ RHEL: sudo dnf update"'
  alias install='echo "→ RHEL: sudo dnf install <pkg>"'
  alias search='echo "→ RHEL: dnf search <term>"'
  alias remove='echo "→ RHEL: sudo dnf remove <pkg>"'
else
  alias update='echo "→ Debian: sudo apt update && sudo apt upgrade -y"'
  alias install='echo "→ Debian: sudo apt install <pkg>"'
  alias search='echo "→ Debian: apt search <term>"'
  alias remove='echo "→ Debian: sudo apt remove <pkg>"'
fi

alias ll='ls -lh --color=auto'
alias la='ls -la --color=auto'
alias ..='cd ..'
alias cls='clear'
alias dir='ls -lah --color=auto'

# -------------------------
# --- 5. Cribsheet function
# -------------------------
cribsheet() {
  local category="${1:-all}"
  echo -e "\e[33m=== Suggested commands only - Review before running ===\e[0m"

  case "$category" in
    pkg)
      if [[ $DISTRO_FAMILY == "rhel_like" ]]; then
        cat <<'CMD'
# RHEL / Fedora / Rocky
sudo dnf update
dnf search <term>
sudo dnf install <pkg>
sudo dnf remove <pkg>
CMD
      else
        cat <<'CMD'
# Ubuntu / Debian / Kubuntu
sudo apt update && sudo apt upgrade -y
apt search <term>
sudo apt install <pkg>
sudo apt remove <pkg>
CMD
      fi
      ;;

    net)
      cat <<'CMD'
# === Network & SSH (SysAdmin Basics) ===
# Local Connectivity
ip -br a                  # Brief IP overview
ip route show             # Find your default gateway
nmcli device status       # Check NetworkManager interface status

# SSH (Secure Shell)
ssh user@<ip>             # Basic login
ssh -i ~/.ssh/id_rsa <ip> # Login using specific private key
ssh-copy-id user@<ip>     # Pro-tip: Copy your public key to a server

# Hardening (Disable Passwords)
# Edit /etc/ssh/sshd_config:
# PasswordAuthentication no
# PubkeyAuthentication yes
sudo systemctl restart sshd

# Troubleshooting
ss -tulpn                 # Show open ports (Who is listening?)
mtr google.com            # 'Next-gen' traceroute (Live stats)
CMD
      ;;

    rhel)
      cat <<'CMD'
# === RHEL / Rocky / AlmaLinux Common Commands ===
firewall-cmd --list-all        # Check active firewall rules
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
sestatus                       # Check SELinux status
journalctl -u <service> -f     # Tail live logs for a service
CMD
      ;;

    htb)
      cat <<'CMD'
# === HackTheBox / Pentesting Workflow ===
sudo openvpn --config ~/htb/lab.ovpn
nmap -sC -sV -oN scan.txt <target>
nc -lvnp 4444
CMD
      ;;

    vm)
      cat <<'CMD'
# === KVM / Virt-Manager (Headless SysAdmin) ===
virsh list --all               # List all VMs
virsh start <vmname>           # Power on a VM
virsh snapshot-create-as --domain <vmname> --name "pre-lab"
CMD
      ;;

    all|*)
      echo "Available topics: pkg, net, rhel, htb, vm"
      echo "Usage: cribsheet net"
      ;;
  esac
}

helpme() {
  echo -e "\n\e[36m--- Training Mode Quick Start ---\e[0m"
  echo "Type 'cribsheet <topic>' to see common commands."
  echo "Topics: pkg, net, rhel, htb, vm"
  echo -e "---------------------------------\n"
}
# -------------------------
# --- 6. Login Banner
# -------------------------
echo -e "\e[32m[SYSTEM READY v2 26-04-23]\e[0m Environment: \e[34m$DISTRO_FAMILY\e[0m"
echo -e "Type '\e[36mhelpme\e[37m' or '\e[36mcribsheet\e[37m' for references."
