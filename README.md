# V-Scan-Toolkit                                                                                                                                                       # Vulnerability Scanning Toolkit

A simple, menu-driven Bash script that brings together popular open-source security and vulnerability scanning tools under one interactive CLI. Instead of remembering different flags and syntax for each tool, just run the script, pick a number, and answer a few prompts.

> **Created by:** vishnu

---

## Features

- Interactive numbered menu — no need to memorize commands
- Banner displayed on launch
- Wraps 13 well-known security tools:
  1. nmap
  2. whatweb
  3. dnsrecon
  4. dirb
  5. nikto
  6. OWASP ZAP
  7. Trivy
  8. Grype + Syft (Anchore)
  9. Prowler
  10. kube-bench / kube-hunter
  11. OWASP Dependency-Check
  12. OpenVAS / Greenbone Community Edition
  13. gobuster
- Checks whether each tool is installed before running it, with a clear warning if missing
- Guided prompts for each tool (target, wordlist, extensions, cloud provider, etc.)

## Requirements

This script does **not** install any scanning tools — it assumes they're already installed and available in your `$PATH` (or via Docker for tools like OWASP ZAP). Install whichever tools you plan to use, for example on Debian/Kali:

```bash
sudo apt install nmap whatweb dnsrecon dirb nikto gobuster
```

Other tools (Trivy, Grype, Syft, Prowler, kube-bench, kube-hunter, OWASP Dependency-Check, OpenVAS/Greenbone) should be installed per their official documentation.

## Usage

```bash
chmod +x vuln_scanner.sh
./vuln_scanner.sh
```

Then select a tool from the menu and follow the prompts.

### Example: gobuster

```
13)  gobuster
Enter URL: http://example.com
Enter custom wordlist path: /usr/share/wordlists/dirb/common.txt
Enter extensions if any (comma separated, e.g. php,txt,html) [press Enter to skip]: php,html
```

## Disclaimer

This tool is intended for **authorized security testing and educational purposes only**. Only scan systems and networks you own or have explicit permission to test. Unauthorized scanning may be illegal in your jurisdiction.

## License

MIT License — feel free to use, modify, and distribute.
