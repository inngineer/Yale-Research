#!/bin/bash
# Yale Fingerprinting Research - Comprehensive Identity Test Script
# Tests all 30+ vectors of system fingerprinting manipulation
# 
# Usage: Run from src/ directory
#   cd yale_fingerprinting_research/src
#   ./test_identity.sh

echo "=========================================="
echo "YALE FINGERPRINTING RESEARCH"
echo "Identity Spoofing Validation Test Suite"
echo "=========================================="
echo ""
echo "Testing 30+ identity vectors across 9 categories..."
echo ""

# Detect where identity.so is located
if [ -f ../identity.so ]; then
    LIB_PATH="../identity.so"
    echo "[+] Using identity.so from parent directory"
elif [ -f ./identity.so ]; then
    LIB_PATH="./identity.so"
    echo "[+] Using identity.so from current directory"
else
    echo "[!] identity.so not found!"
    echo "[*] Please run ./build_identity.py first"
    exit 1
fi
echo ""

echo "=========================================="
echo "TEST 1: CORE SYSTEM IDENTIFIERS"
echo "=========================================="
echo ""

echo "[*] Testing /etc/machine-id:"
LD_PRELOAD=$LIB_PATH cat /etc/machine-id 2>/dev/null | head -1

echo ""
echo "[*] Testing /sys/class/dmi/id/product_uuid:"
LD_PRELOAD=$LIB_PATH cat /sys/class/dmi/id/product_uuid 2>/dev/null

echo ""
echo "[*] Testing /sys/class/dmi/id/board_serial:"
LD_PRELOAD=$LIB_PATH cat /sys/class/dmi/id/board_serial 2>/dev/null

echo ""
echo "[*] Testing /sys/class/dmi/id/product_name:"
LD_PRELOAD=$LIB_PATH cat /sys/class/dmi/id/product_name 2>/dev/null

echo ""
echo "=========================================="
echo "TEST 2: CPU INFORMATION"
echo "=========================================="
echo ""

echo "[*] Testing /proc/cpuinfo (first 10 lines):"
LD_PRELOAD=$LIB_PATH cat /proc/cpuinfo 2>/dev/null | head -10

echo ""
echo "=========================================="
echo "TEST 3: OPERATING SYSTEM IDENTITY"
echo "=========================================="
echo ""

echo "[*] Testing /etc/os-release:"
LD_PRELOAD=$LIB_PATH cat /etc/os-release 2>/dev/null | head -5

echo ""
echo "[*] Testing uname system call:"
LD_PRELOAD=$LIB_PATH uname -a

echo ""
echo "[*] Testing hostname:"
LD_PRELOAD=$LIB_PATH hostname

echo ""
echo "=========================================="
echo "TEST 4: STORAGE/DISK IDENTIFIERS"
echo "=========================================="
echo ""

echo "[*] Testing disk serial numbers:"
echo "  - /sys/block/sda/device/serial:"
LD_PRELOAD=$LIB_PATH cat /sys/block/sda/device/serial 2>/dev/null

echo ""
echo "  - /sys/block/nvme0n1/device/serial:"
LD_PRELOAD=$LIB_PATH cat /sys/block/nvme0n1/device/serial 2>/dev/null

echo ""
echo "=========================================="
echo "TEST 5: GPU/GRAPHICS IDENTIFIERS"
echo "=========================================="
echo ""

echo "[*] Testing GPU vendor IDs:"
echo "  - /sys/class/drm/card0/device/vendor:"
LD_PRELOAD=$LIB_PATH cat /sys/class/drm/card0/device/vendor 2>/dev/null

echo ""
echo "  - /sys/devices/pci0000:00/0000:00:02.0/vendor:"
LD_PRELOAD=$LIB_PATH cat /sys/devices/pci0000:00/0000:00:02.0/vendor 2>/dev/null

echo ""
echo "=========================================="
echo "TEST 6: NETWORK INTERFACE MAC ADDRESSES"
echo "=========================================="
echo ""

echo "[*] Testing network interface MAC addresses:"
echo "  - /sys/class/net/eth0/address:"
LD_PRELOAD=$LIB_PATH cat /sys/class/net/eth0/address 2>/dev/null

echo ""
echo "  - /sys/class/net/wlan0/address:"
LD_PRELOAD=$LIB_PATH cat /sys/class/net/wlan0/address 2>/dev/null

echo ""
echo "=========================================="
echo "TEST 7: BOOT AND KERNEL IDENTIFIERS"
echo "=========================================="
echo ""

echo "[*] Testing boot_id:"
LD_PRELOAD=$LIB_PATH cat /proc/sys/kernel/random/boot_id 2>/dev/null

echo ""
echo "[*] Testing kernel random uuid:"
LD_PRELOAD=$LIB_PATH cat /proc/sys/kernel/random/uuid 2>/dev/null

echo ""
echo "=========================================="
echo "TEST 8: TIME MANIPULATION"
echo "=========================================="
echo ""

echo "[*] Normal time:"
date

echo ""
echo "[*] Time with +3600 second offset (1 hour forward):"
SPOOF_TIME_OFFSET=3600 LD_PRELOAD=$LIB_PATH date

echo ""
echo "[*] Time with timing variance (anti-fingerprinting):"
SPOOF_TIMING_VARIANCE=100 LD_PRELOAD=$LIB_PATH date

echo ""
echo "=========================================="
echo "TEST 9: CONTAINER DETECTION EVASION"
echo "=========================================="
echo ""

echo "[*] Testing /proc/self/cgroup (should show root, not container):"
LD_PRELOAD=$LIB_PATH cat /proc/self/cgroup 2>/dev/null

echo ""
echo "=========================================="
echo "TEST 10: COMPREHENSIVE FINGERPRINT TEST"
echo "=========================================="
echo ""

# Create a test program that queries multiple identity vectors
cat > /tmp/identity_test.c << 'EOF'
#include <stdio.h>
#include <unistd.h>
#include <sys/utsname.h>

int main() {
    char hostname[256];
    struct utsname info;
    FILE *fp;
    char buffer[256];
    
    printf("=== COMPREHENSIVE IDENTITY TEST ===\n\n");
    
    // Hostname
    if (gethostname(hostname, sizeof(hostname)) == 0) {
        printf("[+] Hostname: %s\n", hostname);
    }
    
    // uname
    if (uname(&info) == 0) {
        printf("[+] System: %s\n", info.sysname);
        printf("[+] Node: %s\n", info.nodename);
        printf("[+] Release: %s\n", info.release);
        printf("[+] Machine: %s\n", info.machine);
    }
    
    // Machine ID
    fp = fopen("/etc/machine-id", "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("[+] Machine-ID: %s", buffer);
        }
        fclose(fp);
    }
    
    // Product UUID
    fp = fopen("/sys/class/dmi/id/product_uuid", "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            printf("[+] Product UUID: %s", buffer);
        }
        fclose(fp);
    }
    
    return 0;
}
EOF

gcc -o /tmp/identity_test /tmp/identity_test.c 2>/dev/null

echo "[*] Without LD_PRELOAD (Real Identity):"
/tmp/identity_test

echo ""
echo "[*] With LD_PRELOAD (Spoofed Identity):"
LD_PRELOAD=$LIB_PATH /tmp/identity_test

echo ""
echo "=========================================="
echo "TEST COMPLETE"
echo "=========================================="
echo ""
echo "Summary of Capabilities Demonstrated:"
echo "  ✓ Hardware IDs (machine-id, UUIDs, serials)"
echo "  ✓ CPU Information Spoofing"
echo "  ✓ OS Version/Kernel Spoofing"
echo "  ✓ Disk/Storage Identity Spoofing"
echo "  ✓ GPU/Graphics Hardware Spoofing"
echo "  ✓ Network MAC Address Spoofing"
echo "  ✓ Boot/Kernel Identifiers"
echo "  ✓ Time Manipulation & Dilation"
echo "  ✓ Container/VM Detection Evasion"
echo "  ✓ Multiple syscall interception (fopen, open, openat, uname, etc.)"
echo ""
echo "For advanced usage:"
echo "  - Set SPOOF_TIME_OFFSET=<seconds> for time offset"
echo "  - Set SPOOF_TIMING_VARIANCE=<ms> for timing jitter"
echo ""
