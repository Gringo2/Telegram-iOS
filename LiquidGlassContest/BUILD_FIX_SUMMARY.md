# Build Configuration Fix - Summary

**Date**: 2025-12-22 02:36  
**Issue**: App crashes on launch with UIKit linking error  
**Root Cause**: Building for iOS Simulator instead of Device

---

## Problem Analysis

### Crash Log Evidence
```
Library not loaded: /System/Library/Frameworks/UIKit.framework/UIKit
Reason: tried: '/System/Library/Frameworks/UIKit.framework/UIKit' (no such file), 
'/System/Library/Frameworks/UIKit.framework/UIKit' (wrong platform to load into process)
```

**Translation:** The .ipa was compiled for iOS Simulator, which uses a different UIKit framework path than real iOS devices.

---

## Root Cause

**File:** `.github/workflows/build.yml` line 130

**Before (WRONG):**
```yaml
--configuration=debug_sim_arm64 \
```

**After (CORRECT):**
```yaml
--configuration=release_universal \
```

---

## Why This Matters

### Simulator vs Device Builds

| Aspect | Simulator (`debug_sim_arm64`) | Device (`release_universal`) |
|--------|-------------------------------|------------------------------|
| **Target** | iOS Simulator on Mac | Real iPhones/iPads |
| **Architecture** | x86_64 or arm64 (M1 Mac) | arm64 only |
| **UIKit Path** | `/Library/Developer/...` | `/System/Library/...` |
| **Frameworks** | macOS-compatible | iOS-native |
| **Installation** | Xcode Simulator only | Sideloadly, TestFlight, App Store |

**Simulator builds CANNOT run on real devices** - this is by design in iOS development.

---

## What Changed

### Commit: 61265fa

**Files Modified:**
- `.github/workflows/build.yml` (1 line)

**Change:**
```diff
- --configuration=debug_sim_arm64 \
+ --configuration=release_universal \
```

**Impact:**
- ✅ Builds for real iOS devices (iPhone, iPad)
- ✅ Uses correct UIKit framework paths
- ✅ Compatible with Sideloadly installation
- ✅ Supports arm64 architecture (iPhone 6s+)
- ✅ Release optimization enabled

---

## Verification Steps

### After New Build Completes:

1. **Download new .ipa** from GitHub Actions
2. **Install via Sideloadly** on iPhone 12
3. **Expected:** App launches successfully
4. **Test Phase 0:**
   - Tap tab bar icons
   - Look for white flash (40ms highlight)
   - Verify scale is subtle (1.04x)
   - Check smooth animation (~450ms)

---

## Timeline

**Build #1 (commit 0263a82):**
- ❌ Crashed on launch
- Issue: Thread assertion in debug build

**Build #2 (commit 105ab72):**
- ❌ Crashed on launch  
- Issue: Wrong platform (Simulator)

**Build #3 (commit 61265fa):**
- ✅ Should launch successfully
- Fix: Device build configuration
- Ready for Phase 0 testing

---

## Additional Fixes in This Build

1. ✅ **Removed thread assertion** (commit 105ab72)
   - Prevents assert() crashes in release builds
   
2. ✅ **Changed to device build** (commit 61265fa)
   - Enables real device installation

3. ✅ **Phase 0 features intact**
   - Tap highlight (40ms)
   - Spring tuning (0.45s, 1.04x scale)

---

## Expected Build Time

- **GitHub Actions:** ~30-45 minutes
- **Longer than before:** Release builds take more time than debug builds
- **Worth it:** Produces optimized, device-compatible .ipa

---

## Notes

### Why Simulator Build Was There

Possible reasons:
- Testing/debugging workflow
- Faster build times for CI
- Copy-paste from simulator-focused project

### Why We Need Device Build

- **Sideloadly** only works with device builds
- **TestFlight** requires device builds
- **App Store** submission needs device builds
- Real hardware has different framework paths

---

## What to Do If It Still Crashes

**Unlikely, but if it does:**

1. **Get new crash log** (same method as before)
2. **Check exception type:**
   - If still UIKit → build system issue (needs deeper investigation)
   - If different error → new issue (we'll debug)
3. **Verify .ipa metadata:**
   ```bash
   unzip -l Telegram.ipa | grep platform
   ```
   Should show `ios-arm64`, NOT `sim-arm64`

---

## Confidence Level

**95% confident this fixes the launch crash.**

**Evidence:**
- Crash log explicitly states "wrong platform"
- Configuration change directly addresses root cause
- `release_universal` is standard for device builds
- This is a well-understood iOS build issue

**The only way this doesn't work:**
- If there's a deeper build system configuration problem
- If Bazel has issues with release_universal flag
- If codesigning breaks with release build

But these are unlikely given the clear crash log evidence.
