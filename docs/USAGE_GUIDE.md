# Dynamic Identity Spoofing System - Usage Guide

## Quick Start

### 1. Modify Your Identity

Edit `identity_config.json` to change any value:

```bash
nano identity_config.json
```

**Example: Change suffix from 73 to 74**
```json
"_id_suffix": "74",
```

All hardware identifiers (machine-id, serials, MACs) will automatically append this suffix.

### 2. Build & Compile

Run the builder script:

```bash
./build_identity.py
```

This automatically:
- Reads `identity_config.json`
- Generates `identity.c` with your values
- Compiles to `identity.so`

### 3. Use It

```bash
# Test with any command
LD_PRELOAD=./identity.so hostname

# Run Warp Terminal with spoofed identity
LD_PRELOAD=./identity.so /opt/warpdotdev/warp-terminal/warp
```

---

## What Was Fixed

### The `gettimeofday()` Compilation Error

**Problem:**
```c
// Your old code (line 373):
int gettimeofday(struct timeval *tv, struct timezone *tz);

// System expects:
int gettimeofday(struct timeval *__restrict __tv, void *__restrict __tz);
```

**Why it failed:**
1. **`__restrict`** keyword - C99 optimization hint (pointers don't alias)
2. **`void *`** instead of **`struct timezone *`** - `struct timezone` is deprecated

**Solution in new code:**
```c
static int (*real_gettimeofday)(struct timeval* __restrict, void* __restrict) = NULL;
int gettimeofday(struct timeval *__restrict tv, void *__restrict tz) {
    // ... implementation
}
```

---

## Configuration Examples

### Example 1: Quick Identity Switch

Change just the suffix to create a new fingerprint:

```json
"_id_suffix": "99",
```

All MACs, serials, and IDs will end in "99".

### Example 2: Different Hardware Profile

```json
"hardware": {
  "product_name": "Lenovo ThinkPad X1 Carbon",
  "board_vendor": "LENOVO",
  ...
}
```

### Example 3: Custom Network MACs

```json
"network": {
  "interfaces": {
    "eth0": "aa:bb:cc:dd:ee",
    "wlan0": "11:22:33:44:55"
  }
}
```

The suffix is automatically appended: `aa:bb:cc:dd:ee:73`

---

## Advanced Usage

### Time Manipulation

```bash
# Add 1 hour offset
SPOOF_TIME_OFFSET=3600 LD_PRELOAD=./identity.so date

# Add timing jitter (100ms variance)
SPOOF_TIMING_VARIANCE=100 LD_PRELOAD=./identity.so ./my_app
```

### Create Multiple Profiles

```bash
# Create profile variations
cp identity_config.json profiles/profile_73.json
cp identity_config.json profiles/profile_74.json

# Edit and build specific profile
cp profiles/profile_74.json identity_config.json
./build_identity.py
```

---

## How It Works

### 1. Configuration File → C Code Generation

`build_identity.py` reads JSON and template-fills C code:

```python
# JSON
"hostname": "research-workstation",
"_id_suffix": "73"

# Becomes C code
static const char* FAKE_HOSTNAME = "research-workstation";
{ "/etc/machine-id", "a1b2c3d4e5f67890a1b2c3d4e5f6795573\n" },
```

### 2. LD_PRELOAD Interception

```
Application calls fopen("/etc/machine-id", "r")
         ↓
LD_PRELOAD redirects to YOUR fopen()
         ↓
Your code checks: is this "/etc/machine-id"? Yes!
         ↓
Return fake data via fmemopen()
         ↓
Application reads fake machine-id
```

### 3. Transparent Spoofing

The application never knows it's been intercepted. From its perspective, it just read the real file.

---

## Debugging

### Check what's being spoofed:

```bash
LD_PRELOAD=./identity.so cat /etc/machine-id
LD_PRELOAD=./identity.so hostname
LD_PRELOAD=./identity.so uname -a
```

### Verify compilation:

```bash
gcc -shared -fPIC -o identity.so identity.c -ldl
```

### Check if library loads:

```bash
LD_PRELOAD=./identity.so bash -c 'echo $LD_PRELOAD'
```

---

## Key Concepts Explained

### 1. Function Signatures & Type Safety

C requires **exact** function signature matches when overriding:

```c
// System header says:
int foo(int *__restrict a, void *__restrict b);

// You MUST match exactly:
int foo(int *__restrict a, void *__restrict b) { ... }

// This WON'T work:
int foo(int *a, void *b) { ... }  // Missing __restrict
```

### 2. `dlsym(RTLD_NEXT, "function")`

Gets pointer to the REAL function (next in chain):

```c
static int (*real_fopen)(...) = NULL;
if (!real_fopen) { 
    real_fopen = dlsym(RTLD_NEXT, "fopen");  // Get real fopen
}
return real_fopen(path, mode);  // Call it
```

### 3. `fmemopen()` - Memory as a File

Creates a FILE* from a memory buffer:

```c
char data[] = "fake content\n";
FILE *fp = fmemopen(data, strlen(data), "r");
// Now fp can be read like a normal file
```

### 4. `__attribute__((constructor))`

Runs automatically when library loads (before main()):

```c
__attribute__((constructor))
void init() {
    printf("Loaded!\n");  // Runs immediately
}
```

---

## Security Notes

### Detection Methods

Your spoofing CAN be detected by:

1. **Checking LD_PRELOAD**
   ```c
   if (getenv("LD_PRELOAD")) { /* detected */ }
   ```

2. **Direct Syscalls**
   Apps bypassing libc (rare but possible)

3. **Consistency Checks**
   Comparing multiple sources (files vs ioctl vs /dev/mem)

4. **Performance Timing**
   Interception adds microseconds of latency

### Limitations

**Cannot spoof:**
- Statically linked binaries
- Kernel-level queries (need kernel module)
- Hardware instructions (CPUID, RDTSC)
- Direct /dev/mem access (requires root)

---

## Troubleshooting

### "Compilation failed"
- Check JSON syntax: `python3 -m json.tool identity_config.json`
- Ensure gcc installed: `sudo apt install build-essential`

### "No such file or directory"
- Make sure you're in `/home/ingineer/`
- Check file exists: `ls -la identity_config.json`

### "Function not found"
- Your `dlsym()` might be failing
- Check library path: `ldd identity.so`

---

## For Your Presentation

### Key Points to Emphasize:

1. **30+ Identity Vectors** spoofed across 9 categories
2. **No root required** - pure userspace
3. **Transparent** - applications unaware
4. **Dynamic** - change identities without code editing
5. **Educational** - demonstrates fingerprinting risks

### Demo Flow:

```bash
# 1. Show real identity
hostname
cat /etc/machine-id

# 2. Edit config
nano identity_config.json  # Change suffix to 74

# 3. Rebuild
./build_identity.py

# 4. Show spoofed identity
LD_PRELOAD=./identity.so hostname
LD_PRELOAD=./identity.so cat /etc/machine-id

# 5. Run real app (Warp)
LD_PRELOAD=./identity.so /opt/warpdotdev/warp-terminal/warp
```

---

## Further Extensions (Future Work)

1. **Web UI** - GUI for editing profiles
2. **Profile Manager** - Switch identities instantly
3. **Logging Mode** - Record what apps query
4. **Random Generator** - Generate realistic fake identities
5. **Process Targeting** - Different identities per app
6. **Kernel Module** - Spoof deeper (CPUID, etc.)

---

**Questions?** Check RESEARCH_DOCUMENTATION.md for technical details.
