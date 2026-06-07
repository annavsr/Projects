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

