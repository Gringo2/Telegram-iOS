# Phase 0 - Build & Test Instructions

**Status**: ✅ Code complete with safety improvements  
**Ready for**: Build → Visual QA → Profiling

---

## Files Modified

✅ **LiquidLensView.swift** - Tap highlight layer with safety checks  
✅ **TabBarComponent.swift** - Spring tuning (0.45s, 1.04x scale)

---

## Build Steps

### 1. Prerequisites
- Xcode 15+ installed
- iOS 18 Simulator or physical device (iPhone 8+ recommended)
- Telegram-iOS project opening correctly

### 2. Build Configuration
```bash
cd ~/Desktop/Telegram-iOS
```

**Option A: Build via Xcode**
1. Open `Telegram-iOS.xcodeproj` or workspace
2. Select **Product > Build** (⌘B)
3. Target: iOS Simulator (iOS 18) or physical device
4. Wait for build to complete (~2-5 minutes)

**Option B: Build via command line**
```bash
# Generate Xcode project if needed
python3 build-system/Make.py generateProject

# Build for simulator
xcodebuild -project Telegram-iOS.xcodeproj \
  -scheme Telegram \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=18.0' \
  build
```

### 3. Expected Build Output
✅ **Success**: 
- No errors related to `LiquidLensView` or `TabBarComponent`
- Build succeeds (warnings OK)

❌ **Failure scenarios**:
- `specularHighlightLayer` not found → Check line 95 exists
- `animateTapHighlight` not found → Check method was added
- Spring duration syntax error → Check `.spring(duration: 0.45)`

---

## Testing Checklist

### Visual QA (iOS 18 Simulator)

**Test 1: Tap Highlight**
- [ ] Launch app
- [ ] Navigate to tab bar
- [ ] Tap on each tab icon
- [ ] **Expected**: Brief white flash appears at tap location (40ms)
- [ ] **Verify**: Flash disappears immediately, doesn't persist

**Test 2: Scale Animation**
- [ ] Tap and hold on a tab
- [ ] **Expected**: Selected tab icon scales to ~1.04x (subtle enlargement)
- [ ] **Verify**: Not 1.15x (old value) - should be more subtle
- [ ] Release tap
- [ ] **Expected**: Smooth spring back to 1.0x scale

**Test 3: Spring Duration**
- [ ] Tap between different tabs
- [ ] **Expected**: Animation completes in ~450ms (slightly slower than before)
- [ ] **Verify**: Feels natural, not too fast or too slow

**Test 4: Rapid Tapping**
- [ ] Rapidly tap multiple tabs (5+ taps/second)
- [ ] **Expected**: Each tap shows single flash, no stacking
- [ ] **Verify**: No visual artifacts or leftover highlights

**Test 5: Dark Mode**
- [ ] Enable dark mode (Settings > Appearance)
- [ ] Repeat Test 1-4
- [ ] **Expected**: Highlight works in both light and dark mode
- [ ] **Optional**: Check if brightness feels appropriate

### Edge Cases

**Test 6: No Crashes**
- [ ] Background/foreground app multiple times
- [ ] Rotate device (if physical device)
- [ ] Switch between tabs rapidly
- [ ] **Expected**: No crashes, no assertions fired

---

## Profiling Instructions

### Battery Impact Test (iPhone 8 recommended)

**Prerequisites**: Physical iPhone 8, iOS 15+, Instruments app

**Steps:**
1. Connect iPhone 8 to Mac
2. Open **Instruments** → Choose **Energy Log** template
3. Select Telegram app
4. Start recording
5. **Baseline**: Use app normally for 60 seconds (no tab switching)
6. **Test**: Switch tabs continuously for 60 seconds
7. Stop recording
8. **Analyze**: Compare energy usage

**Success Criteria:**
- Energy overhead during tab switching: < 7%
- No sustained high CPU usage
- GPU usage spikes only during animations

### Performance Profiling

**Option A: Xcode Instruments (Time Profiler)**
```bash
# Build for profiling
xcodebuild -project Telegram-iOS.xcodeproj \
  -scheme Telegram \
  -destination 'platform=iOS,name=Your iPhone' \
  -configuration Release \
  build
```

1. Product → Profile (⌘I)
2. Select **Time Profiler**
3. Record during tab switching
4. **Check**: `animateTapHighlight` execution time < 2ms

**Option B: Xcode Debug Navigator**
1. Run app in Debug mode
2. Open **Debug Navigator** (⌘7)
3. Switch tabs multiple times
4. **Check**: CPU < 15%, Memory stable

---

## Visual QA Against iOS 18

### Reference Comparison

**Get iOS 18 reference:**
1. Record iOS 18 native tab bar at 240fps (slo-mo)
2. Measure highlight duration frame-by-frame
3. Compare to Telegram implementation

**What to look for:**
- ✅ Highlight appears on tap down (not tap up)
- ✅ Flash duration ~40ms (2-3 frames at 60fps)
- ✅ Scale increase subtle (~4%)
- ✅ Spring feels natural, not robotic
- ⚠️ Brightness matches (may need adjustment)

---

## Rollback Procedure

**If tests fail and rollback needed:**

```bash
# Revert LiquidLensView.swift
git checkout HEAD -- submodules/TelegramUI/Components/LiquidLens/Sources/LiquidLensView.swift

# Revert TabBarComponent.swift
git checkout HEAD -- submodules/TelegramUI/Components/TabBarComponent/Sources/TabBarComponent.swift

# Rebuild
xcodebuild -scheme Telegram build
```

---

## Success Metrics

**Phase 0 passes if:**
- ✅ Build succeeds with no errors
- ✅ Tap highlight visible and natural
- ✅ Scale animation subtle (~1.04x)
- ✅ Spring duration ~450ms
- ✅ No crashes during rapid tapping
- ✅ Battery impact < 7% (if profiled)
- ✅ Visual match to iOS 18 (acceptable tolerance)

**Decision Point:**
- **Battery < 7%** → Proceed to Phase 1 (chat buttons)
- **Battery > 7%** → Consider vImage blur optimization

---

## Next Steps After Testing

**If Phase 0 succeeds:**
1. Document findings in testing log
2. Update `task.md` - mark Phase 0 complete
3. Begin Phase 1: Chat buttons
4. Apply same pattern (tap highlight + spring tuning)

**If issues found:**
1. Document specific failures
2. Adjust parameters (brightness, duration, scale)
3. Rebuild and retest
4. Iterate until acceptable

---

## Support & Troubleshooting

**Common Issues:**

**Build fails with "Cannot find specularHighlightLayer"**
- Check line 95 in LiquidLensView.swift exists
- Verify property is spelled correctly

**Tap highlight not visible**
- Check alpha value (line 137) - may need to increase
- Verify layer is added to hierarchy (line 154)
- Check if highlight is behind other layers

**Animation feels wrong**
- Too fast? Increase duration beyond 0.45s
- Too slow? Decrease to 0.42s
- Scale too subtle? Try 1.05x instead of 1.04x

**Performance issues**
- Profile with Instruments Time Profiler
- Check for animation stacking (should be prevented)
- Verify GPU is handling CALayer animations

---

## Contact

For questions or issues:
- Check `PHASE0_SUMMARY.md` for technical details
- Review `BLUR_ANALYSIS.md` for architecture
- See `TAB_BAR_REVIEW.md` for existing implementation
