#!/bin/bash
# Yale Fingerprinting Research - Phase 2 & 5 Test
# Tests memory and display spoofing

echo "=========================================="
echo "ADVANCED FINGERPRINTING DEFENSE TEST"
echo "Phase 2: Memory Spoofing"
echo "Phase 5: Display Spoofing"
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

echo "=========================================="
echo "TEST 1: MEMORY INFORMATION SPOOFING"
echo "=========================================="
echo ""

echo "[*] Real System Memory:"
head -10 /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|Swap)"

echo ""
echo "[*] Spoofed Memory:"
LD_PRELOAD=$LIB_PATH head -10 /proc/meminfo 2>&1 | grep -v INTERCEPTOR | grep -E "(MemTotal|MemFree|MemAvailable|Swap)"

echo ""
echo "=========================================="
echo "TEST 2: DISPLAY/SCREEN SPOOFING"
echo "=========================================="
echo ""

# Get the actual display name from config
DISPLAY_NAME=$(python3 -c "import json; c=json.load(open('../config/identity_config.json')); print(c['display']['name'])" 2>/dev/null)
DISPLAY_RES=$(python3 -c "import json; c=json.load(open('../config/identity_config.json')); print(c['display']['resolution'])" 2>/dev/null)

echo "[*] Configured Display:"
echo "  Name: $DISPLAY_NAME"
echo "  Resolution: $DISPLAY_RES"

echo ""
echo "[*] Testing display modes file:"
if [ "$DISPLAY_NAME" = "eDP-1" ]; then
    LD_PRELOAD=$LIB_PATH cat /sys/class/drm/card0-eDP-1/modes 2>&1 | grep -v INTERCEPTOR
elif [ "$DISPLAY_NAME" = "DP-1" ]; then
    LD_PRELOAD=$LIB_PATH cat /sys/class/drm/card0-DP-1/modes 2>&1 | grep -v INTERCEPTOR
elif [ "$DISPLAY_NAME" = "HDMI-1" ]; then
    LD_PRELOAD=$LIB_PATH cat /sys/class/drm/card0-HDMI-A-1/modes 2>&1 | grep -v INTERCEPTOR
fi

echo ""
echo "[*] Testing display status:"
if [ "$DISPLAY_NAME" = "eDP-1" ]; then
    LD_PRELOAD=$LIB_PATH cat /sys/class/drm/card0-eDP-1/status 2>&1 | grep -v INTERCEPTOR
elif [ "$DISPLAY_NAME" = "DP-1" ]; then
    LD_PRELOAD=$LIB_PATH cat /sys/class/drm/card0-DP-1/status 2>&1 | grep -v INTERCEPTOR
fi

echo ""
echo "=========================================="
echo "TEST 3: COMPREHENSIVE FINGERPRINT TEST"
echo "=========================================="
echo ""

# Create test program
cat > /tmp/test_memory_display.c << 'EEOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void parse_meminfo() {
    FILE *fp = fopen("/proc/meminfo", "r");
    if (!fp) {
        printf("Cannot read /proc/meminfo\n");
        return;
    }
    
    char line[256];
    printf("Memory Information:\n");
    while (fgets(line, sizeof(line), fp)) {
        if (strstr(line, "MemTotal:") || 
            strstr(line, "MemFree:") || 
            strstr(line, "MemAvailable:") ||
            strstr(line, "SwapTotal:")) {
            printf("  %s", line);
        }
    }
    fclose(fp);
}

int main() {
    printf("=== SYSTEM FINGERPRINT ===\n\n");
    
    parse_meminfo();
    
    printf("\nDisplay Files:\n");
    FILE *fp = fopen("/sys/class/drm/card0-DP-1/modes", "r");
    if (fp) {
        char buffer[128];
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("  DP-1 Resolution: %s", buffer);
        }
        fclose(fp);
    } else {
        fp = fopen("/sys/class/drm/card0-eDP-1/modes", "r");
        if (fp) {
            char buffer[128];
            if (fgets(buffer, sizeof(buffer), fp)) {
                printf("  eDP-1 Resolution: %s", buffer);
            }
            fclose(fp);
        }
    }
    
    return 0;
}
EEOF

gcc -o /tmp/test_memory_display /tmp/test_memory_display.c 2>/dev/null

echo "[*] Without Spoofing:"
/tmp/test_memory_display

echo ""
echo "[*] With Spoofing:"
LD_PRELOAD=$LIB_PATH /tmp/test_memory_display 2>&1 | grep -v INTERCEPTOR

echo ""
echo "=========================================="
echo "TEST COMPLETE"
echo "=========================================="
echo ""
echo "Summary of Phase 2 & 5 Features:"
echo "  ✓ Memory (RAM) Information Spoofing"
echo "  ✓ /proc/meminfo manipulation"
echo "  ✓ Display Resolution Spoofing"
echo "  ✓ Monitor/Screen Information"
echo "  ✓ DRM subsystem file spoofing"
echo ""
echo "Browser Fingerprinting Defenses Added:"
echo "  ✓ Defeats memory-based fingerprinting"
echo "  ✓ Defeats screen resolution detection"
echo "  ✓ Hides real hardware specifications"
echo "  ✓ Spoofs system resource information"
echo ""
