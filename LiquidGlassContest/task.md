# Liquid Glass Contest - Incremental Rollout

## Phase 0: Tab Bar Only (FIRST PUSH) 🎯
- [ ] Create `LiquidTabBar.swift` in `submodules/TelegramUI/Sources/`
- [ ] Implement blur of tab bar content (leverage existing `ImageBlur.swift`)
- [ ] Implement 40ms tap highlight animation
- [ ] Implement optional scale/bounce on selection
- [ ] Integrate into `MainTabBarController.swift`
- [x] **Build & validate pipeline**
- [ ] Profile on iOS 18 simulator
- [ ] Profile on iOS 16 device (if available)
- [ ] Verify no regressions in other screens

## Phase 1: Chat Buttons (SECOND PUSH)
- [ ] Apply pattern from tab bar to `ChatTextInputActionButtonsNode`
- [ ] Implement glass effect for attach/voice/send buttons
- [ ] Reuse blur caching strategy
- [ ] Test & validate

## Phase 2: Switches & Sliders (THIRD PUSH)
- [ ] Implement `LiquidGlassSwitchKnobView`
- [ ] Add velocity-based stretch deformation
- [ ] Test & validate

## Phase 3: Full Architecture (IF NEEDED)
- [ ] Extract common patterns into `GlassView` base class
- [ ] Implement full layer hierarchy from expert plan
- [ ] Optimize across all components

## Phase 4: Final Polish & Optimization
- [ ] Cross-device profiling (iPhone 8, 12, 15 Pro)
- [ ] Animation parameter tuning against iOS 18
- [ ] Memory & battery optimization
- [ ] Contest submission preparation

