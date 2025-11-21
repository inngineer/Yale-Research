# Quick Start Guide

## 🚀 Get Started in 3 Steps

### Step 1: Generate Identity

```bash
cd yale_fingerprinting_research

# Easy mode - use the wrapper script
./generate_identity.sh random aggressive

# Or run directly
cd src
./formulate_identity.py random --strategy aggressive
```

### Step 2: Build & Compile

```bash
cd src
./build_identity.py
```

### Step 3: Test It

```bash
# From project root
LD_PRELOAD=./identity.so hostname

# Test with cat
LD_PRELOAD=./identity.so cat /etc/machine-id

# Run Warp Terminal
LD_PRELOAD=./identity.so /opt/warpdotdev/warp-terminal/warp
```

---

## 📂 Project Organization

```
yale_fingerprinting_research/
├── src/               # All source code here
├── config/            # Configuration files
├── docs/              # All documentation
├── logs/              # Research logs
└── examples/          # Example configs
```

---

## 🎯 Common Commands

### List Available Components
```bash
cd src
./formulate_identity.py list
```

### Generate Specific Profile
```bash
cd src
./formulate_identity.py preset gaming_enthusiast
./build_identity.py
```

### Run Tests
```bash
cd src
./test_identity.sh
```

---

## 📚 Documentation

- **README.md** - Project overview
- **docs/USAGE_GUIDE.md** - Detailed usage
- **docs/FORMULATION_GUIDE.md** - Component system
- **docs/RESEARCH_DOCUMENTATION.md** - Technical details
- **docs/ANALYSIS_SUMMARY.md** - Research analysis

---

## ⚡ Working Directory

**Important:** Scripts expect to run from `src/` directory:

```bash
cd yale_fingerprinting_research/src
./formulate_identity.py <command>
./build_identity.py
```

Or use the convenience wrapper from project root:

```bash
cd yale_fingerprinting_research
./generate_identity.sh <command>
```

---

## 🎓 For Presentation

1. **Show structure:** `tree -L 2`
2. **List components:** `./src/formulate_identity.py list`
3. **Generate identity:** `./src/formulate_identity.py random`
4. **Build:** `./src/build_identity.py`
5. **Test:** `LD_PRELOAD=./identity.so hostname`

---

**Ready to get full marks! 🎯**
