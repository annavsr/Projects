# -- Farben für die Augabe --
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

DATE=$(date '+%Y-%m-%d_%H-%M-%S')
REPORT_DOC="audit_report_$DATE.txt"

# -- Hilfsfunktionen --

seperate() {
  echo "========================================================="
}

section() {
  echo ""
  seperate
  echo -e "${BLUE} >>> $1${NC}"
  seperate
}

ok()       { echo -e " ${GREEN}[OK]${NC}"; }
warning()  { echo -e " ${YELLOW}[WARN]${NC}"; }
alarm()    { echo -e " ${RED}[ALARM]${NC}"; }
info()     { echo -e " [INFO]  $1"; }

# -- 1. Systeminformationen --

section "1. Systeminformations"

info "Operating System:  $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
info "Kernel:            $(uname -r)"
info "Architecture:      $(uname -m)"
info "Uptime:            $(uptime -p)"
info "Time:              $(date)"

# -- 2. Benutzer auf dem System -- 

section "2. Users on the system"

info: "All Users with login-shell:"

grep -E '/bin/bash|/bin/sh|/bin/zsh' /etc/passwd | while IFS=: read -r name _ uid gid _ _ _; do
  if  [ "$uid" -eq 0 ]; then
    alarm "ROOT-User: $name (UID=$uid)"
  elif [ "$uid" -ge 1000 ]; then
    ok "Normal User: $name (UID=$uid)"
  else
    warning "System-User with shell: $name (UID=$uid)"
  fi
done

info "logged in User:"
who

# -- 3. Offene Ports & lauschende Dienste -- 

section "3. Open ports & eavesdropping services"

info "The following services are eavedr>opping on network connections:"

if command -v ss &>/dev/null; then
  ss -tulpn | grep LISTEN | while read -r line; do
    port=$(echo "$line" | awk '{print $5}' | rev | cut -d: -f1 | rev)
    case $port in
        21) alarm "Port $port (FTP) - Unencrypted! Better to use SFTP | $line" ;;
        23) alarm "Port $port (Telnet) - Very Unsafe! Please deactivate | $line" ;;
        22) warning "Port $port (SSH) - Open. Secure with Key-Auth & Fail2ban" ;;
        80) warning "Port $port (HTTP) - Unencrypted. Prefer HTTPS" ;;
        443) ok "Port §port (HTTPS) - Encrypted, OK" ;;
        3306) warning "Port $port (MySQL) - DB accessible from outside?" ;;
        *) info "Port $port | $line" ;;
    esac
  done
else
  warning "ss not found, trying netstat..."
  netstat -tulpn 2>/dev/null | grep LISTEN || info "No tool found."
fi

