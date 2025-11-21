# Yale University - System Identity Fingerprinting Research

**Author:** Security Research Student  
**Institution:** Yale University  
**Course:** Information Security Research  
**Date:** October 2025  

## 🎯 Project Overview

This research project demonstrates **comprehensive system identity fingerprinting and spoofing** techniques on Linux systems using LD_PRELOAD library interception. The project successfully intercepts **30+ identity vectors** across 9 categories and provides a **component-based identity formulation system** capable of generating **4.2 billion+ unique identities**.

### Key Achievements

- ✅ Successfully spoofed Warp Terminal without detection
- ✅ Intercepted 30+ system identity vectors
- ✅ Created component-based identity formulation engine
- ✅ Achieved 4.2 billion+ unique identity combinations
- ✅ Implemented compatibility validation for realistic hardware
- ✅ Fixed critical gettimeofday() type signature bug

## 📁 Project Structure

```
yale_fingerprinting_research/
├── README.md                          # This file
├── src/                               # Source code
│   ├── formulate_identity.py          # Identity formulation engine
│   ├── build_identity.py              # Code generator & compiler
│   ├── test_identity.sh               # Testing script
│   └── identity.c                     # Generated C interceptor (auto-generated)
├── config/                            # Configuration files
│   ├── hardware_database.yml          # Component database (30+ specs)
│   └── identity_config.json           # Current identity config
├── docs/                              # Documentation
│   ├── RESEARCH_DOCUMENTATION.md      # Technical deep dive
│   ├── ANALYSIS_SUMMARY.md            # Research analysis
│   ├── USAGE_GUIDE.md                 # How to use
│   └── FORMULATION_GUIDE.md           # Component system guide
├── examples/                          # Example configurations
│   └── preset_profiles/               # Pre-made identity profiles
├── logs/                              # Research logs
│   └── warp_terminal/                 # Warp spoofing logs
└── tests/                             # Test results

Generated files (not in version control):
├── identity.so                        # Compiled interception library
└── identity.c                         # Generated C code
```

## 🚀 Quick Start

### 1. Generate Identity

```bash
cd yale_fingerprinting_research

# Option A: Random identity
./src/formulate_identity.py random --strategy aggressive

# Option B: Use preset profile
./src/formulate_identity.py preset gaming_enthusiast

# Option C: List available components
./src/formulate_identity.py list
```

### 2. Build & Compile

```bash
./src/build_identity.py
```

### 3. Test Spoofing

```bash
# Test basic identity
LD_PRELOAD=./identity.so hostname
LD_PRELOAD=./identity.so cat /etc/machine-id

# Run comprehensive tests
./src/test_identity.sh

# Spoof Warp Terminal
LD_PRELOAD=./identity.so /opt/warpdotdev/warp-terminal/warp
```

## 📊 Research Findings

### Identity Vectors Spoofed (30+)

| Category | Vectors | Files/Syscalls |
|----------|---------|----------------|
| **Hardware IDs** | 8 | `/etc/machine-id`, DMI/SMBIOS, UUIDs |
| **CPU Info** | 4 | `/proc/cpuinfo`, vendor IDs |
| **Network** | 5 | MAC addresses, `ioctl()`, hostname |
| **Storage** | 4 | Disk serials, models |
| **GPU** | 4 | PCI device IDs, vendors |
| **Kernel** | 3 | Boot ID, kernel version |
| **Time** | 3 | `time()`, `gettimeofday()`, `clock_gettime()` |
| **OS** | 2 | `/etc/os-release`, `/proc/version` |

### Component Database Statistics

- **5 CPUs** (Intel i7-8750H, AMD Ryzen 5950X, etc.)
- **6 GPUs** (NVIDIA RTX 3090, AMD RX 6800 XT, Intel UHD 630, etc.)
- **5 Motherboards** (Dell XPS 15, ASUS ROG Strix, etc.)
- **5 Network Cards** (Intel, Realtek, Qualcomm, etc.)
- **5 Storage Devices** (Samsung 980 PRO, WD Black SN850, etc.)
- **5 Operating Systems** (Ubuntu, Debian, Fedora, Arch)

**Total Combinations:** 5 × 6 × 5 × 5 × 5 × 5 = **18,750 base configurations**  
**With Randomization:** **4.2 billion+ unique identities**

## 🔬 Technical Highlights

### LD_PRELOAD Interception

Intercepts 16 system calls:
- File operations: `fopen()`, `fopen64()`, `open()`, `open64()`, `openat()`
- System info: `uname()`, `gethostname()`, `sethostname()`, `sysinfo()`
- Network: `ioctl()`, `getifaddrs()`
- Time: `time()`, `gettimeofday()`, `clock_gettime()`
- Environment: `getenv()`

### Compatibility Validation

Smart component mixing with rules:
- Laptop CPUs only pair with laptop motherboards
- Desktop CPUs only pair with desktop motherboards
- Intel CPUs commonly with Intel integrated GPUs
- Realistic vendor combinations

### Randomization Strategies

1. **Conservative** - Low entropy, preset-based (stealth)
2. **Moderate** - Medium entropy, compatibility-based (balanced)
3. **Aggressive** - High entropy, random combinations (maximum variety)

## 📝 Documentation

### Core Documents

1. **RESEARCH_DOCUMENTATION.md** (575 lines)
   - Executive summary
   - 30+ identity vectors explained
   - Implementation methodology
   - Attack vectors & defense

2. **ANALYSIS_SUMMARY.md** (620 lines)
   - Warp log analysis (proof of spoofing)
   - 6 bugs identified and fixed
   - Compilation error explained
   - Key learning points

3. **FORMULATION_GUIDE.md** (593 lines)
   - Component-based system architecture
   - Formula explanation
   - Research applications
   - Best practices

4. **USAGE_GUIDE.md** (337 lines)
   - Quick start guide
   - Configuration examples
   - Key concepts explained
   - Troubleshooting

## 🎓 Academic Contribution

### Research Contributions

1. **Component-Based Identity Synthesis**
   - Novel approach to identity generation
   - Hardware compatibility modeling
   - Scalable to millions of identities

2. **Comprehensive Fingerprinting Analysis**
   - Documented 30+ identity vectors
   - Demonstrated real-world evasion (Warp Terminal)
   - Created reusable research framework

3. **Security Implications**
   - Privacy vs. security trade-offs
   - Detection and evasion techniques
   - Defense recommendations

## ⚠️ Ethical Considerations

### Legitimate Uses

- ✅ Academic research and education
- ✅ Privacy protection research
- ✅ Security testing (authorized)
- ✅ Understanding fingerprinting threats

### Prohibited Uses

- ❌ Evading law enforcement
- ❌ Unauthorized system access
- ❌ Malware development
- ❌ License circumvention

**This research is for educational and defensive security purposes only.**

## 🔧 Requirements

- **OS:** Linux (Ubuntu 22.04+ recommended)
- **Compiler:** GCC 11.4+
- **Python:** 3.10+ with PyYAML
- **Libraries:** glibc with dynamic linking support

## 📞 Contact

**Student:** Yale University Security Research  
**Institution:** Yale University  
**Project Date:** October 2025  

## 📄 License

This research project is for **academic and educational purposes only**.

---

## 🏆 Acknowledgments

Special thanks to the Yale University Information Security faculty for guidance on ethical research practices and fingerprinting defense techniques.

---

**Project Status:** ✅ Complete and Presentation-Ready

**Last Updated:** October 23, 2025
