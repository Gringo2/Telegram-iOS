# Phase 0 Crash Debug Guide

**Device**: iPhone 12  
**Issue**: App crashes on launch  
**Build**: ci/pipeline (commit 0263a82)

---

## Immediate Steps to Get Crash Log

### Option 1: Xcode Console (Fastest)
1. Connect iPhone 12 to Mac
2. Open **Xcode** → **Window** → **Devices and Simulators**
3. Select your iPhone 12
4. Click **View Device Logs**
5. Find latest "Telegram" crash
6. Copy full crash log

### Option 2: Settings App
1. On iPhone: **Settings** → **Privacy** → **Analytics & Improvements** → **Analytics Data**
2. Find "Telegram" crash report
3. Tap to view, then Share/AirDrop to Mac

### Option 3: Console.app
1. On Mac: Open **Console.app**
2. Select iPhone 12 from sidebar
3. Filter for "Telegram"
4. Look for crash report

---

## Most Likely Causes (Based on Our Changes)

### 1. Thread Assertion Crash (HIGH PROBABILITY) ⚠️

**Our code:**
```swift
// LiquidLensView.swift:241
assert(Thread.isMainThread, "animateTapHighlight must be called on main thread")
```

**Problem**: If `animateTapHighlight` is called from background thread, app crashes

**Crash signature:**
```
Assertion failed: (Thread.isMainThread)
```

**Why it might happen:**
- If gesture recognizer fires on background queue
- If TabBarComponent initialization happens off main thread

**Fix:**
Remove the assertion temporarily, or make it debug-only:
```swift
#if DEBUG
assert(Thread.isMainThread, "...")
#endif
```

---

### 2. Coordinate Space Issue (MEDIUM PROBABILITY)

**Our code:**
```swift
// TabBarComponent.swift:291
let tapLocation = recognizer.location(in: self.liquidLensView)
self.liquidLensView.animateTapHighlight(at: tapLocation)
```

**Problem**: If `liquidLensView` is nil or not in view hierarchy yet

**Crash signature:**
```
Fatal error: Unexpectedly found nil while unwrapping an Optional value
```

**Fix:**
Add nil check:
```swift
if let liquidLensView = self.liquidLensView.superview {
    let tapLocation = recognizer.location(in: self.liquidLensView)
    self.liquidLensView.animateTapHighlight(at: tapLocation)
}
```

---

### 3. Layer Hierarchy Issue (LOW PROBABILITY)

**Our code:**
```swift
// LiquidLensView.swift:154
self.containerView.layer.addSublayer(self.specularHighlightLayer)
```

**Problem**: If `containerView.layer` is not ready yet

**Crash signature:**
```
EXC_BAD_ACCESS (SIGSEGV)
```

**Fix:**
Defer layer addition to `didMoveToWindow`:
```swift
override public func didMoveToWindow() {
    super.didMoveToWindow()
    if self.specularHighlightLayer.superlayer == nil {
        self.containerView.layer.addSublayer(self.specularHighlightLayer)
    }
}
```

---

### 4. CAGradientLayer Type Issue (LOW PROBABILITY)

**Our code:**
```swift
// LiquidLensView.swift:135
self.specularHighlightLayer.type = .radial
```

**Problem**: `.radial` not available on iOS 12-14

**Crash signature:**
```
unrecognized selector sent to instance
```

**Fix:**
Add availability check:
```swift
if #available(iOS 12.0, *) {
    self.specularHighlightLayer.type = .radial
}
```

---

## Quick Emergency Rollback

**If you need the app working NOW**, revert our changes:

```bash
cd ~/Desktop/Telegram-iOS
git checkout ci/pipeline
git revert 0263a82
git push origin ci/pipeline
```

This will remove Phase 0 changes and rebuild.

---

## Systematic Debugging Approach

### Step 1: Get the Crash Log
**CRITICAL**: Without crash log, we're guessing. Get it using methods above.

### Step 2: Identify Crash Line
Look for stack trace in crash log:
```
Thread 0 Crashed:
0   Telegram   0x000000010436c4b8 LiquidLensView.animateTapHighlight
1   Telegram   0x000000010438a2c0 TabBarComponent.onTabSelectionGesture
```

This tells us EXACTLY which line crashed.

### Step 3: Apply Targeted Fix
Based on crash line, apply one of the fixes above.

### Step 4: Test Locally
Before pushing fix:
```bash
# Build for device locally
xcodebuild -scheme Telegram \
  -destination 'platform=iOS,name=iPhone 12' \
  build
```

---

## Common Crash Patterns

### Pattern 1: Crashes Immediately on Launch
**Likely**: Layer initialization issue (containerView not ready)
**Fix**: Move layer addition to `didMoveToWindow`

### Pattern 2: Crashes on First Tab Tap
**Likely**: Thread assertion or coordinate space issue
**Fix**: Remove assertion or add nil check

### Pattern 3: Crashes After a Few Seconds
**Likely**: Animation cleanup issue or memory problem
**Fix**: Check animation key conflicts

---

## Emergency Patch (If Crash Log Not Available)

**Try this safe version** - removes all potentially problematic code:

```swift
// LiquidLensView.swift - Replace animateTapHighlight with:
public func animateTapHighlight(at location: CGPoint) {
    // Temporarily disabled for debugging
    return
    
    /* Original code commented out
    assert(Thread.isMainThread, "...")
    self.specularHighlightLayer.removeAnimation(forKey: "tapHighlight")
    // ... rest
    */
}
```

This disables tap highlight but keeps app stable.

---

## What to Share

**Please provide:**
1. ✅ Full crash log (most important!)
2. Device iOS version (iPhone 12 running iOS ?)
3. When it crashes (launch, first tap, after delay?)
4. Any error message shown to user
5. GitHub Actions build log (if available)

**With crash log, I can provide exact fix in < 5 minutes.**
