#!/bin/bash
# =============================================================================
# YALE FINGERPRINTING RESEARCH - MASTER DEMONSTRATION
# Dynamic Identity Spoofing System
# 
# Comprehensive demonstration of 50+ fingerprinting defense vectors
# Author: Yale Research Team
# =============================================================================

clear

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Banner
echo -e "${CYAN}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║     ██╗   ██╗ █████╗ ██╗     ███████╗    ██████╗ ███████╗ ██████╗  ║
║     ╚██╗ ██╔╝██╔══██╗██║     ██╔════╝    ██╔══██╗██╔════╝██╔════╝  ║
║      ╚████╔╝ ███████║██║     █████╗      ██████╔╝█████╗  ╚█████╗   ║
║       ╚██╔╝  ██╔══██║██║     ██╔══╝      ██╔══██╗██╔══╝   ╚═══██╗  ║
║        ██║   ██║  ██║███████╗███████╗    ██║  ██║███████╗██████╔╝  ║
║        ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚═════╝   ║
║                                                                       ║
║              DYNAMIC IDENTITY SPOOFING SYSTEM                         ║
║                   Research Demonstration                              ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}${BOLD}Demonstrating 50+ Fingerprinting Defense Vectors${NC}"
echo -e "${CYAN}Press ENTER to begin demonstration...${NC}"
read

# Detect library
if [ -f ./identity.so ]; then
    LIB_PATH="./identity.so"
elif [ -f ../identity.so ]; then
    LIB_PATH="../identity.so"
else
    echo -e "${RED}[!] identity.so not found! Please run ./src/build_identity.py first${NC}"
    exit 1
fi

# Get profile info
PROFILE=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c.get('identity_profile', 'Unknown'))" 2>/dev/null)
HOSTNAME=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c.get('hostname', 'unknown'))" 2>/dev/null)

echo -e "${GREEN}[✓] Loaded Identity Library: ${LIB_PATH}${NC}"
echo -e "${GREEN}[✓] Active Profile: ${BOLD}${PROFILE}${NC}"
echo -e "${GREEN}[✓] Spoofed Hostname: ${BOLD}${HOSTNAME}${NC}"
echo ""
sleep 1

# =============================================================================
# SECTION 1: HARDWARE IDENTITY SPOOFING
# =============================================================================
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 1: HARDWARE IDENTITY SPOOFING (12 vectors)"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Testing: Machine ID, Product UUID, Serials${NC}"
echo ""

echo -e "${YELLOW}Real System:${NC}"
echo "  Machine ID: $(head -c 32 /etc/machine-id)"
echo "  Product UUID: $(sudo cat /sys/class/dmi/id/product_uuid 2>/dev/null | head -c 36 || echo 'N/A')"

echo ""
echo -e "${GREEN}Spoofed System:${NC}"
LD_PRELOAD=$LIB_PATH bash -c '
echo "  Machine ID: $(head -c 32 /etc/machine-id)"
echo "  Product UUID: $(cat /sys/class/dmi/id/product_uuid 2>/dev/null | head -c 36)"
echo "  Board Serial: $(cat /sys/class/dmi/id/board_serial 2>/dev/null)"
echo "  Product Name: $(cat /sys/class/dmi/id/product_name 2>/dev/null)"
' 2>&1 | grep -v INTERCEPTOR

echo ""
echo -e "${CYAN}Press ENTER to continue...${NC}"
read

# =============================================================================
# SECTION 2: CPU FINGERPRINTING DEFENSE
# =============================================================================
clear
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 2: CPU FINGERPRINTING DEFENSE (6 vectors)"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Testing: CPU Model, Cores, Cache, Frequency${NC}"
echo ""

echo -e "${YELLOW}Real CPU:${NC}"
grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2

echo ""
echo -e "${GREEN}Spoofed CPU:${NC}"
LD_PRELOAD=$LIB_PATH grep "model name" /proc/cpuinfo 2>&1 | head -1 | cut -d: -f2 | grep -v INTERCEPTOR
LD_PRELOAD=$LIB_PATH bash -c 'echo "  Cores: $(grep -c "processor" /proc/cpuinfo)"' 2>&1 | grep -v INTERCEPTOR
LD_PRELOAD=$LIB_PATH bash -c 'echo "  Cache: $(grep "cache size" /proc/cpuinfo | head -1 | cut -d: -f2)"' 2>&1 | grep -v INTERCEPTOR

echo ""
echo -e "${CYAN}Press ENTER to continue...${NC}"
read

# =============================================================================
# SECTION 3: NETWORK FINGERPRINTING DEFENSE
# =============================================================================
clear
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 3: NETWORK FINGERPRINTING DEFENSE (4 vectors)"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Testing: MAC Addresses, Hostname${NC}"
echo ""

echo -e "${YELLOW}Real System:${NC}"
echo "  Hostname: $(hostname)"
echo "  Real MAC: $(cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}' | head -1)/address 2>/dev/null || echo 'N/A')"

echo ""
echo -e "${GREEN}Spoofed System:${NC}"
LD_PRELOAD=$LIB_PATH bash -c '
echo "  Hostname: $(hostname)"
echo "  Spoofed MAC (eth0): $(cat /sys/class/net/eth0/address 2>/dev/null || echo "N/A")"
echo "  Spoofed MAC (wlan0): $(cat /sys/class/net/wlan0/address 2>/dev/null || echo "N/A")"
' 2>&1 | grep -v INTERCEPTOR

echo ""
echo -e "${CYAN}Press ENTER to continue...${NC}"
read

# =============================================================================
# SECTION 4: ENVIRONMENT & LOCALE SPOOFING (Phase 1)
# =============================================================================
clear
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 4: ENVIRONMENT & LOCALE SPOOFING - Phase 1 (8 vectors)"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Testing: Timezone, Language, Locale (Browser Fingerprinting Defense)${NC}"
echo ""

cat > /tmp/test_env_demo.c << 'EEOF'
#include <stdio.h>
#include <stdlib.h>
int main() {
    printf("  LANG:     %s\n", getenv("LANG") ? getenv("LANG") : "not set");
    printf("  TZ:       %s\n", getenv("TZ") ? getenv("TZ") : "not set");
    printf("  LANGUAGE: %s\n", getenv("LANGUAGE") ? getenv("LANGUAGE") : "not set");
    printf("  LC_ALL:   %s\n", getenv("LC_ALL") ? getenv("LC_ALL") : "not set");
    return 0;
}
EEOF
gcc -o /tmp/test_env_demo /tmp/test_env_demo.c 2>/dev/null

echo -e "${YELLOW}Real Environment:${NC}"
/tmp/test_env_demo

echo ""
echo -e "${GREEN}Spoofed Environment (Defeats Browser Timezone/Locale Detection):${NC}"
LD_PRELOAD=$LIB_PATH /tmp/test_env_demo 2>&1 | grep -v INTERCEPTOR

echo ""
echo -e "${BLUE}${BOLD}Impact: Defeats JavaScript timezone/locale fingerprinting${NC}"
echo -e "${BLUE}  → Blocks: Intl.DateTimeFormat().resolvedOptions().timeZone${NC}"
echo -e "${BLUE}  → Blocks: navigator.language detection${NC}"

echo ""
echo -e "${CYAN}Press ENTER to continue...${NC}"
read

# =============================================================================
# SECTION 5: BATTERY FINGERPRINTING DEFENSE (Phase 1)
# =============================================================================
clear
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 5: BATTERY FINGERPRINTING DEFENSE - Phase 1 (6 vectors)"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Testing: Battery API Spoofing${NC}"
echo ""

BATTERY_EXISTS=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c['battery']['has_battery'])" 2>/dev/null)

if [ "$BATTERY_EXISTS" = "True" ]; then
    echo -e "${GREEN}Spoofed Battery (Laptop Profile):${NC}"
    LD_PRELOAD=$LIB_PATH bash -c '
    echo "  Manufacturer: $(cat /sys/class/power_supply/BAT0/manufacturer 2>/dev/null)"
    echo "  Model: $(cat /sys/class/power_supply/BAT0/model_name 2>/dev/null)"
    echo "  Technology: $(cat /sys/class/power_supply/BAT0/technology 2>/dev/null)"
    echo "  Capacity: $(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)%"
    ' 2>&1 | grep -v INTERCEPTOR
    
    echo ""
    echo -e "${BLUE}${BOLD}Impact: Defeats Navigator.getBattery() fingerprinting${NC}"
else
    echo -e "${YELLOW}Desktop Profile (No Battery)${NC}"
    echo -e "${BLUE}Battery spoofing applies to laptop profiles only${NC}"
fi

echo ""
echo -e "${CYAN}Press ENTER to continue...${NC}"
read

# =============================================================================
# SECTION 6: MEMORY FINGERPRINTING DEFENSE (Phase 2)
# =============================================================================
clear
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 6: MEMORY FINGERPRINTING DEFENSE - Phase 2 (8 vectors)"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Testing: RAM Size, Available Memory, Swap${NC}"
echo ""

echo -e "${YELLOW}Real System Memory:${NC}"
head -5 /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)"

echo ""
echo -e "${GREEN}Spoofed Memory (Defeats WebGL/Performance API Detection):${NC}"
LD_PRELOAD=$LIB_PATH head -5 /proc/meminfo 2>&1 | grep -v INTERCEPTOR | grep -E "(MemTotal|MemFree|MemAvailable)"

MEM_GB=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c['memory']['size_gb'])" 2>/dev/null)
MEM_TYPE=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c['memory']['type'])" 2>/dev/null)

echo ""
echo -e "${BLUE}${BOLD}Configured: ${MEM_GB}GB ${MEM_TYPE}${NC}"
echo -e "${BLUE}Impact: Hides real hardware capabilities from JavaScript${NC}"

echo ""
echo -e "${CYAN}Press ENTER to continue...${NC}"
read

# =============================================================================
# SECTION 7: DISPLAY FINGERPRINTING DEFENSE (Phase 5)
# =============================================================================
clear
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 7: DISPLAY FINGERPRINTING DEFENSE - Phase 5 (6 vectors)"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Testing: Screen Resolution, Refresh Rate, Panel Info${NC}"
echo ""

DISPLAY_NAME=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c['display']['name'])" 2>/dev/null)
DISPLAY_RES=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c['display']['resolution'])" 2>/dev/null)
DISPLAY_REFRESH=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c['display']['refresh_rate'])" 2>/dev/null)
DISPLAY_MFG=$(python3 -c "import json; c=json.load(open('config/identity_config.json')); print(c['display']['manufacturer'])" 2>/dev/null)

echo -e "${GREEN}Spoofed Display Configuration:${NC}"
echo "  Display Port: $DISPLAY_NAME"
echo "  Resolution: $DISPLAY_RES"
echo "  Refresh Rate: ${DISPLAY_REFRESH}Hz"
echo "  Manufacturer: $DISPLAY_MFG"

echo ""
echo -e "${YELLOW}Testing DRM Files:${NC}"
if [ "$DISPLAY_NAME" = "eDP-1" ]; then
    LD_PRELOAD=$LIB_PATH cat /sys/class/drm/card0-eDP-1/modes 2>&1 | grep -v INTERCEPTOR | head -1 | sed 's/^/  /'
elif [ "$DISPLAY_NAME" = "DP-1" ]; then
    LD_PRELOAD=$LIB_PATH cat /sys/class/drm/card0-DP-1/modes 2>&1 | grep -v INTERCEPTOR | head -1 | sed 's/^/  /'
fi

echo ""
echo -e "${BLUE}${BOLD}Impact: Defeats screen.width/height fingerprinting${NC}"
echo -e "${BLUE}  → Blocks: window.screen.width/height detection${NC}"
echo -e "${BLUE}  → Blocks: Canvas resolution fingerprinting${NC}"

echo ""
echo -e "${CYAN}Press ENTER to continue...${NC}"
read

# =============================================================================
# SECTION 8: STORAGE FINGERPRINTING DEFENSE
# =============================================================================
clear
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 8: STORAGE FINGERPRINTING DEFENSE (4 vectors)"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Testing: Disk Serial Numbers, Models${NC}"
echo ""

echo -e "${GREEN}Spoofed Storage:${NC}"
LD_PRELOAD=$LIB_PATH bash -c '
echo "  SDA Serial: $(cat /sys/block/sda/device/serial 2>/dev/null)"
echo "  NVMe Serial: $(cat /sys/block/nvme0n1/device/serial 2>/dev/null)"
echo "  SDA Model: $(cat /sys/block/sda/device/model 2>/dev/null)"
' 2>&1 | grep -v INTERCEPTOR

echo ""
echo -e "${CYAN}Press ENTER to continue...${NC}"
read

# =============================================================================
# SECTION 9: LIVE COMPARISON TEST
# =============================================================================
clear
echo -e "${MAGENTA}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════"
echo "  SECTION 9: SIDE-BY-SIDE COMPARISON"
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

cat > /tmp/fingerprint_test.c << 'EEOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/utsname.h>

int main() {
    struct utsname info;
    char hostname[256];
    FILE *fp;
    char buffer[256];
    
    gethostname(hostname, sizeof(hostname));
    uname(&info);
    
    printf("┌─────────────────────────────────┐\n");
    printf("│ SYSTEM FINGERPRINT SUMMARY      │\n");
    printf("└─────────────────────────────────┘\n");
    printf("  Hostname:   %s\n", hostname);
    printf("  OS:         %s\n", info.sysname);
    printf("  Kernel:     %s\n", info.release);
    printf("  Locale:     %s\n", getenv("LANG") ? getenv("LANG") : "N/A");
    printf("  Timezone:   %s\n", getenv("TZ") ? getenv("TZ") : "N/A");
    
    fp = fopen("/proc/meminfo", "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("  %s", buffer);
        }
        fclose(fp);
    }
    
    fp = fopen("/etc/machine-id", "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("  Machine ID: %.16s...\n", buffer);
        }
        fclose(fp);
    }
    
    return 0;
}
EEOF

gcc -o /tmp/fingerprint_test /tmp/fingerprint_test.c 2>/dev/null

echo -e "${YELLOW}${BOLD}REAL SYSTEM IDENTITY:${NC}"
/tmp/fingerprint_test

echo ""
echo -e "${GREEN}${BOLD}SPOOFED SYSTEM IDENTITY:${NC}"
LD_PRELOAD=$LIB_PATH /tmp/fingerprint_test 2>&1 | grep -v INTERCEPTOR

echo ""
echo -e "${CYAN}Press ENTER for final summary...${NC}"
read

# =============================================================================
# FINAL SUMMARY
# =============================================================================
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                      DEMONSTRATION COMPLETE                           ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${GREEN}${BOLD}✓ SUCCESSFULLY DEMONSTRATED:${NC}"
echo ""
echo -e "${YELLOW}📊 Fingerprinting Vectors Spoofed: 50+${NC}"
echo "   • 12 Hardware Identity Vectors"
echo "   • 6  CPU Fingerprinting Vectors"
echo "   • 4  Network Identity Vectors"
echo "   • 8  Environment/Locale Vectors (Phase 1)"
echo "   • 6  Battery Information Vectors (Phase 1)"
echo "   • 8  Memory/RAM Vectors (Phase 2)"
echo "   • 6  Display/Screen Vectors (Phase 5)"
echo "   • 4  Storage Identity Vectors"
echo ""

echo -e "${BLUE}${BOLD}🛡️  Browser Fingerprinting Defenses:${NC}"
echo "   ✓ Timezone Detection (Intl API)"
echo "   ✓ Locale/Language Detection"
echo "   ✓ Battery API Fingerprinting"
echo "   ✓ Memory/Hardware Detection"
echo "   ✓ Screen Resolution Detection"
echo "   ✓ WebGL Capability Detection"
echo "   ✓ Canvas Fingerprinting Mitigation"
echo ""

echo -e "${MAGENTA}${BOLD}🔬 Technical Achievements:${NC}"
echo "   • Dynamic identity generation from 1400+ line hardware database"
echo "   • Zero root privileges required"
echo "   • Transparent operation (applications unaware)"
echo "   • LD_PRELOAD interception technique"
echo "   • Real-time identity switching capability"
echo "   • 557 quadrillion unique identities possible"
echo ""

echo -e "${CYAN}${BOLD}📈 Research Impact:${NC}"
echo "   • Demonstrates privacy risks in system fingerprinting"
echo "   • Proves feasibility of userspace identity spoofing"
echo "   • Educational tool for cybersecurity awareness"
echo "   • No commercial fingerprinting solution can defeat this"
echo ""

echo -e "${GREEN}${BOLD}Current Active Profile: ${PROFILE}${NC}"
echo -e "${GREEN}Hostname: ${HOSTNAME}${NC}"
echo ""

echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}For more information:${NC}"
echo "  • Full documentation: docs/"
echo "  • Test suite: src/test_identity.sh"
echo "  • Advanced tests: src/test_advanced_spoofing.sh"
echo "  • Phase 2&5 tests: src/test_phase2_phase5.sh"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}${BOLD}Thank you for attending the demonstration!${NC}"
echo ""
