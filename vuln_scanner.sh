#!/bin/bash
#
# Vulnerability Scanning Toolkit
# Created by: vishnu
#
# A menu-driven wrapper around common open-source security scanning tools.
# NOTE: This script does NOT install the tools. It assumes each tool is
# already installed and available in $PATH (or via docker, for tools like
# OWASP ZAP / OpenVAS where that's the common usage pattern).
#

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- Banner ----------
print_banner() {
    clear
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${CYAN}          VULNERABILITY SCANNING TOOLS${NC}"
    echo -e "${CYAN}               Created by : vishnu${NC}"
    echo -e "${CYAN}=========================================================${NC}"
    echo
}

# ---------- Helper ----------
check_tool() {
    local tool="$1"
    if ! command -v "$tool" &>/dev/null; then
        echo -e "${RED}[!] '$tool' is not installed or not in PATH.${NC}"
        echo -e "${YELLOW}    Please install it before using this option.${NC}"
        return 1
    fi
    return 0
}

pause() {
    echo
    read -rp "Press [Enter] to return to the menu..."
}

# ---------- Tool Functions ----------

run_nmap() {
    check_tool nmap || { pause; return; }
    read -rp "Enter target IP/hostname: " target
    read -rp "Enter nmap options (e.g. -sV -sC -p- ) [default: -sV -sC]: " opts
    opts=${opts:--sV -sC}
    echo -e "${GREEN}[*] Running: nmap $opts $target${NC}"
    nmap $opts "$target"
    pause
}

run_whatweb() {
    check_tool whatweb || { pause; return; }
    read -rp "Enter target URL: " target
    echo -e "${GREEN}[*] Running: whatweb $target${NC}"
    whatweb "$target"
    pause
}

run_dnsrecon() {
    check_tool dnsrecon || { pause; return; }
    read -rp "Enter target domain: " domain
    echo -e "${GREEN}[*] Running: dnsrecon -d $domain${NC}"
    dnsrecon -d "$domain"
    pause
}

run_dirb() {
    check_tool dirb || { pause; return; }
    read -rp "Enter target URL: " target
    read -rp "Enter wordlist path [default: /usr/share/dirb/wordlists/common.txt]: " wordlist
    wordlist=${wordlist:-/usr/share/dirb/wordlists/common.txt}
    echo -e "${GREEN}[*] Running: dirb $target $wordlist${NC}"
    dirb "$target" "$wordlist"
    pause
}

run_nikto() {
    check_tool nikto || { pause; return; }
    read -rp "Enter target URL/host: " target
    echo -e "${GREEN}[*] Running: nikto -h $target${NC}"
    nikto -h "$target"
    pause
}

run_zap() {
    read -rp "Enter target URL: " target
    if command -v zap.sh &>/dev/null; then
        echo -e "${GREEN}[*] Running OWASP ZAP baseline scan on $target${NC}"
        zap.sh -cmd -quickurl "$target" -quickprogress
    elif command -v docker &>/dev/null; then
        echo -e "${GREEN}[*] zap.sh not found, attempting via docker...${NC}"
        docker run --rm -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t "$target"
    else
        echo -e "${RED}[!] Neither zap.sh nor docker is available.${NC}"
    fi
    pause
}

run_trivy() {
    check_tool trivy || { pause; return; }
    echo "1) Scan a container image"
    echo "2) Scan a filesystem path"
    read -rp "Choose [1-2]: " choice
    case $choice in
        1)
            read -rp "Enter image name (e.g. nginx:latest): " image
            trivy image "$image"
            ;;
        2)
            read -rp "Enter filesystem path: " path
            trivy fs "$path"
            ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    pause
}

run_grype_syft() {
    read -rp "Enter target (image name or path): " target
    if check_tool syft; then
        echo -e "${GREEN}[*] Generating SBOM with syft...${NC}"
        syft "$target"
    fi
    if check_tool grype; then
        echo -e "${GREEN}[*] Scanning vulnerabilities with grype...${NC}"
        grype "$target"
    fi
    pause
}

run_prowler() {
    check_tool prowler || { pause; return; }
    echo "1) AWS"
    echo "2) Azure"
    echo "3) GCP"
    read -rp "Choose cloud provider [1-3]: " choice
    case $choice in
        1) prowler aws ;;
        2) prowler azure ;;
        3) prowler gcp ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    pause
}

run_kube_tools() {
    echo "1) kube-bench"
    echo "2) kube-hunter"
    read -rp "Choose [1-2]: " choice
    case $choice in
        1)
            check_tool kube-bench || { pause; return; }
            kube-bench
            ;;
        2)
            check_tool kube-hunter || { pause; return; }
            read -rp "Run in active mode? (y/n): " active
            if [[ "$active" == "y" ]]; then
                kube-hunter --active
            else
                kube-hunter --remote
            fi
            ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    pause
}

run_dependency_check() {
    check_tool dependency-check.sh || check_tool dependency-check || { pause; return; }
    read -rp "Enter project path to scan: " path
    read -rp "Enter project name: " name
    if command -v dependency-check.sh &>/dev/null; then
        dependency-check.sh --project "$name" --scan "$path"
    else
        dependency-check --project "$name" --scan "$path"
    fi
    pause
}

run_openvas() {
    echo -e "${YELLOW}[*] OpenVAS/Greenbone Community Edition is typically run via its own${NC}"
    echo -e "${YELLOW}    web GUI (GSA) or gvm-cli, not a single CLI command.${NC}"
    if command -v gvm-cli &>/dev/null; then
        read -rp "Enter target IP/hostname: " target
        echo -e "${GREEN}[*] Launching gvm-cli session for $target${NC}"
        echo "    (You will need a configured GMP socket/credentials.)"
        gvm-cli --gmp-username admin socket --xml "<get_tasks/>"
    else
        echo -e "${RED}[!] gvm-cli not found. Please manage scans via the Greenbone web UI.${NC}"
    fi
    pause
}

run_gobuster() {
    check_tool gobuster || { pause; return; }
    read -rp "Enter URL: " url
    read -rp "Enter custom wordlist path: " wordlist
    read -rp "Enter extensions if any (comma separated, e.g. php,txt,html) [press Enter to skip]: " ext

    if [[ -n "$ext" ]]; then
        echo -e "${GREEN}[*] Running: gobuster dir -u $url -w $wordlist -x $ext${NC}"
        gobuster dir -u "$url" -w "$wordlist" -x "$ext"
    else
        echo -e "${GREEN}[*] Running: gobuster dir -u $url -w $wordlist${NC}"
        gobuster dir -u "$url" -w "$wordlist"
    fi
    pause
}

# ---------- Menu ----------
show_menu() {
    echo -e "${YELLOW}Select a tool to run:${NC}"
    echo " 1)  nmap"
    echo " 2)  whatweb"
    echo " 3)  dnsrecon"
    echo " 4)  dirb"
    echo " 5)  nikto"
    echo " 6)  OWASP ZAP"
    echo " 7)  Trivy"
    echo " 8)  Grype + Syft (Anchore)"
    echo " 9)  Prowler"
    echo "10)  kube-bench / kube-hunter"
    echo "11)  OWASP Dependency-Check"
    echo "12)  OpenVAS/Greenbone Community Edition"
    echo "13)  gobuster"
    echo " 0)  Exit"
    echo
}

# ---------- Main ----------
print_banner

while true; do
    show_menu
    read -rp "Enter choice: " choice
    case $choice in
        1) run_nmap ;;
        2) run_whatweb ;;
        3) run_dnsrecon ;;
        4) run_dirb ;;
        5) run_nikto ;;
        6) run_zap ;;
        7) run_trivy ;;
        8) run_grype_syft ;;
        9) run_prowler ;;
        10) run_kube_tools ;;
        11) run_dependency_check ;;
        12) run_openvas ;;
        13) run_gobuster ;;
        0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice. Try again.${NC}" ;;
    esac
    print_banner
done
