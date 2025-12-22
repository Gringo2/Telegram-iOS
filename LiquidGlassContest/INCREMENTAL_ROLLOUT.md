# Liquid Glass Incremental Rollout Strategy

**Philosophy**: Single-feature push → validate pipeline → iterate.

---

## Phase 0: Tab Bar Only (FIRST PUSH)

**Goal**: Validate architecture and CI/CD pipeline with minimal surface area.

### Scope
- ✅ Tab bar Liquid Glass effects only
- ✅ Blur of tab bar content (no background)
- ✅ Tap highlight on tab icons (40ms)
- ✅ Optional: Small scale/bounce on selected tab
- ❌ **NO** changes to buttons, sliders, switches, or other UI

### Files Modified
```
submodules/TelegramUI/Sources/
├── LiquidTabBar.swift (NEW)
└── MainTabBarController.swift (MODIFY - swap UITabBar → LiquidTabBar)
```

### Implementation

**File: `LiquidTabBar.swift`**
```swift
import UIKit

final class LiquidTabBar: UITabBar {
    private let glassLayer = CALayer()
    private var blurredContentCache: CGImage?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGlassLayer()
    }
    
    private func setupGlassLayer() {
        guard glassLayer.superlayer == nil else { return }
        
        // Capture tab bar's own content
        refreshBlurredContent()
        
        glassLayer.frame = bounds
        glassLayer.contents = blurredContentCache
        layer.insertSublayer(glassLayer, at: 0)
    }
    
    private func refreshBlurredContent() {
        // Render tab bar content to image
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        layer.render(in: context)
        
        guard let snapshot = UIGraphicsGetImageFromCurrentImageContext() else { return }
        
        // Apply vImage blur (leveraging existing ImageBlur.swift)
        let blurred = blurredImage(snapshot, radius: 20.0, iterations: 2)
        blurredContentCache = blurred?.cgImage
    }
    
    // Tap highlight animation
    func animateTabSelection(at index: Int) {
        guard index >= 0, index < subviews.count - 1 else { return }
        let itemView = subviews[index + 1]
        
        // 40ms opacity spike
        let highlight = CABasicAnimation(keyPath: "opacity")
        highlight.fromValue = 1.0
        highlight.toValue = 0.7
        highlight.duration = 0.04
        highlight.autoreverses = true
        highlight.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        itemView.layer.add(highlight, forKey: "tapHighlight")
        
        // Optional: small bounce
        let bounce = CASpringAnimation(keyPath: "transform.scale")
        bounce.fromValue = 1.0
        bounce.toValue = 1.04
        bounce.mass = 1.0
        bounce.stiffness = 200.0
        bounce.damping = 28.28
        bounce.duration = bounce.settlingDuration
        
        itemView.layer.add(bounce, forKey: "bounce")
    }
}
```

**File: `MainTabBarController.swift` (MODIFY)**
```swift
// Find initialization of tab bar controller
// Replace:
// let tabBarController = UITabBarController()

// With:
let tabBarController = UITabBarController()
tabBarController.setValue(LiquidTabBar(), forKey: "tabBar")
```

---

## Validation Checklist

### Build & Integration
- [ ] Create feature branch: `feature/liquid-glass-tabbar`
- [ ] Implement `LiquidTabBar.swift`
- [ ] Integrate into main tab bar controller
- [ ] Build succeeds on Xcode 15+
- [ ] No new warnings or errors

### Runtime Testing
- [ ] Run on iOS 18 simulator
- [ ] Run on iOS 16 device (if available)
- [ ] Verify tab bar renders correctly
- [ ] Tap each tab - verify 40ms highlight
- [ ] Verify blur applies to tab bar content only
- [ ] No visual glitches or artifacts

### Performance Validation
- [ ] Profile with Instruments (Time Profiler)
  - Blur computation < 5ms
  - Animation frame time < 8ms
- [ ] Profile with Instruments (Allocations)
  - No memory leaks
  - Cached blur < 10MB
- [ ] Visual inspection: no jank during tab switch

### Pipeline Testing
- [ ] Push to remote branch
- [ ] Verify GitHub Actions build passes (if configured)
- [ ] No regression in other screens
- [ ] Tab navigation remains functional

---

## Phase 1: Chat Buttons (SECOND PUSH)

**Only proceed after Phase 0 validates successfully.**

### Scope
- Chat input buttons (attach, voice, send)
- Reuse `LiquidTabBar` blur patterns
- Add to existing `ChatTextInputActionButtonsNode`

**Estimated effort**: 3-4 hours

---

## Phase 2: Switches & Sliders (THIRD PUSH)

**Only proceed after Phase 1 validates successfully.**

### Scope
- Switch knob glass effect
- Slider thumb glass effect
- Velocity-based stretch deformation

**Estimated effort**: 4-5 hours

---

## Phase 3: Full Polish & Optimization (FINAL PUSH)

### Scope
- Cross-device profiling (iPhone 8, 12, 15 Pro)
- Animation parameter tuning
- Memory optimization
- Battery impact testing
- Visual QA against iOS 18 reference

**Estimated effort**: 6-8 hours

---

## Risk Mitigation

**If tab bar implementation fails:**
- Fall back to standard `UITabBar`
- No impact on other features
- Easy to revert single-file change

**If performance is poor:**
- Reduce blur radius
- Increase cache TTL
- Disable on devices < A10 chip

---

## Success Metrics

### Phase 0 (Tab Bar)
- ✅ Builds successfully
- ✅ No visual regressions
- ✅ Frame time < 8ms on iPhone 8
- ✅ Memory < 10MB overhead

### Full Implementation
- ✅ All components have Liquid Glass
- ✅ Matches iOS 18 visual fidelity
- ✅ Performance acceptable on iPhone 8
- ✅ Battery impact < 5%
