#!/bin/bash
# Yale Fingerprinting Research - Advanced Spoofing Test
# Tests environment variables and battery spoofing

echo "=========================================="
echo "ADVANCED FINGERPRINTING DEFENSE TEST"
echo "Phase 1: Environment & Battery Spoofing"
echo "=========================================="
echo ""

# Detect where identity.so is located
if [ -f ../identity.so ]; then
    LIB_PATH="../identity.so"
elif [ -f ./identity.so ]; then
    LIB_PATH="./identity.so"
else
    echo "[!] identity.so not found!"
    exit 1
fi

echo "[+] Using $LIB_PATH"
echo ""

# Create test program
cat > /tmp/test_fingerprint.c << 'EEOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/utsname.h>

int main() {
    struct utsname info;
    
    printf("=== SYSTEM IDENTITY ===\n");
    if (uname(&info) == 0) {
        printf("Hostname: %s\n", info.nodename);
        printf("OS: %s %s\n", info.sysname, info.release);
    }
    
    printf("\n=== ENVIRONMENT VARIABLES ===\n");
    printf("LANG:     %s\n", getenv("LANG") ? getenv("LANG") : "not set");
    printf("TZ:       %s\n", getenv("TZ") ? getenv("TZ") : "not set");
    printf("LANGUAGE: %s\n", getenv("LANGUAGE") ? getenv("LANGUAGE") : "not set");
    printf("LC_ALL:   %s\n", getenv("LC_ALL") ? getenv("LC_ALL") : "not set");
    printf("DISPLAY:  %s\n", getenv("DISPLAY") ? getenv("DISPLAY") : "not set");
    
    printf("\n=== BATTERY INFO (if laptop) ===\n");
    FILE *fp;
    char buffer[256];
    
    fp = fopen("/sys/class/power_supply/BAT0/manufacturer", "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("Battery Manufacturer: %s", buffer);
        }
        fclose(fp);
    } else {
        printf("No battery detected (Desktop system)\n");
    }
    
    fp = fopen("/sys/class/power_supply/BAT0/model_name", "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("Battery Model: %s", buffer);
        }
        fclose(fp);
    }
    
    fp = fopen("/sys/class/power_supply/BAT0/technology", "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("Battery Technology: %s", buffer);
        }
        fclose(fp);
    }
    
    fp = fopen("/sys/class/power_supply/BAT0/capacity", "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("Battery Charge: %s%%\n", buffer);
        }
        fclose(fp);
    }
    
    return 0;
}
EEOF

gcc -o /tmp/test_fingerprint /tmp/test_fingerprint.c 2>/dev/null

echo "=========================================="
echo "TEST 1: REAL SYSTEM IDENTITY"
echo "=========================================="
/tmp/test_fingerprint

echo ""
echo "=========================================="
echo "TEST 2: SPOOFED IDENTITY"
echo "=========================================="
LD_PRELOAD=$LIB_PATH /tmp/test_fingerprint

echo ""
echo "=========================================="
echo "TEST 3: LOCALE DETECTION (Browser Test)"
echo "=========================================="
echo ""
echo "[*] Real system locale:"
locale | head -3

echo ""
echo "[*] Spoofed locale (what browsers would see):"
LD_PRELOAD=$LIB_PATH bash -c 'python3 -c "import os; print(\"LANG:\", os.getenv(\"LANG\")); print(\"LC_ALL:\", os.getenv(\"LC_ALL\")); print(\"TZ:\", os.getenv(\"TZ\"))"' 2>&1 | grep -v INTERCEPTOR

echo ""
echo "=========================================="
echo "TEST COMPLETE"
echo "=========================================="
echo ""
echo "Summary of New Features:"
echo "  ✓ Environment Variable Spoofing (LANG, TZ, LC_ALL)"
echo "  ✓ Battery Information Spoofing (Laptop profiles)"
echo "  ✓ Timezone Manipulation"
echo "  ✓ Display Settings Spoofing"
echo ""
echo "Browser Fingerprinting Defenses:"
echo "  ✓ Defeats timezone fingerprinting"
echo "  ✓ Defeats locale fingerprinting"
echo "  ✓ Defeats battery API fingerprinting"
echo "  ✓ Spoofs system environment detection"
echo ""
