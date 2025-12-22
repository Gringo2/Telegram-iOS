import Foundation
import UIKit
import AsyncDisplayKit
import LiquidGlass

private final class SwitchNodeViewLayer: CALayer {
    override func setNeedsDisplay() {
    }
}

private final class SwitchNodeView: UISwitch {
    override class var layerClass: AnyClass {
        if #available(iOS 26.0, *) {
            return super.layerClass
        } else {
            return SwitchNodeViewLayer.self
        }
    }
}

open class SwitchNode: ASDisplayNode {
    public var valueUpdated: ((Bool) -> Void)?
    
    private let glassController = GlassEffectController()
    private weak var thumbView: UIView?
    
    public var frameColor = UIColor(rgb: 0xe0e0e0) {
        didSet {
            if self.isNodeLoaded {
                if oldValue != self.frameColor {
                    (self.view as! UISwitch).tintColor = self.frameColor
                }
            }
        }
    }
    public var handleColor = UIColor(rgb: 0xffffff) {
        didSet {
            if self.isNodeLoaded {
                //(self.view as! UISwitch).thumbTintColor = self.handleColor
            }
        }
    }
    public var contentColor = UIColor(rgb: 0x42d451) {
        didSet {
            if self.isNodeLoaded {
                if oldValue != self.contentColor {
                    (self.view as! UISwitch).onTintColor = self.contentColor
                }
            }
        }
    }
    
    private var _isOn: Bool = false
    public var isOn: Bool {
        get {
            return self._isOn
        } set(value) {
            if (value != self._isOn) {
                self._isOn = value
                if self.isNodeLoaded {
                    (self.view as! UISwitch).setOn(value, animated: false)
                }
            }
        }
    }
    
    override public init() {
        super.init()
        
        self.setViewBlock({
            return SwitchNodeView()
        })
    }
    
    override open func didLoad() {
        super.didLoad()
        
        self.view.isAccessibilityElement = false
        
        (self.view as! UISwitch).backgroundColor = self.backgroundColor
        (self.view as! UISwitch).tintColor = self.frameColor
        (self.view as! UISwitch).onTintColor = self.contentColor
        
        (self.view as! UISwitch).setOn(self._isOn, animated: false)
        
        (self.view as! UISwitch).addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        (self.view as! UISwitch).addTarget(self, action: #selector(glassTouchDown), for: .touchDown)
        (self.view as! UISwitch).addTarget(self, action: #selector(glassTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        (self.view as! UISwitch).addTarget(self, action: #selector(glassValueChanged), for: .valueChanged)
        
        self.locateAndAugmentThumb()
    }
    
    private func locateAndAugmentThumb() {
        // Heuristic to find the thumb view: usually it's a subview that has a shadow or is the discrete "knob"
        // On iOS 13+, it's often nested.
        func findThumb(in view: UIView) -> UIView? {
            // Check for shadow (common for thumb) or specific frame characteristics
            if view.layer.shadowOpacity > 0.0 || view.layer.shadowRadius > 0.0 {
                return view
            }
            // Or check if it's the specific "UISwitchModernVisualElement" (private class name check is risky)
            // Better: find strictly sized subview ~ 27x27
            if view.bounds.width >= 20.0 && view.bounds.width <= 32.0 && view.bounds.height >= 20.0 && view.bounds.height <= 32.0 {
               // Likely the thumb
               return view
            }
            
            for subview in view.subviews.reversed() { // Thumb usually on top
                if let found = findThumb(in: subview) {
                    return found
                }
            }
            return nil
        }
        
        if let thumb = findThumb(in: self.view) {
            self.thumbView = thumb
            thumb.layer.addSublayer(self.glassController.highlightLayer)
        }
    }
    
    @objc private func glassTouchDown() {
        if let thumb = self.thumbView {
             self.glassController.performScaleUp(view: thumb, at: CGPoint(x: thumb.bounds.midX, y: thumb.bounds.midY))
        } else {
             // Fallback: Scale entire switch if knob not found
             self.glassController.performScaleUp(view: self.view, at: CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY))
        }
    }
    
    @objc private func glassTouchUp() {
        if let thumb = self.thumbView {
             self.glassController.performBounceBack(view: thumb)
        } else {
             // Fallback
             self.glassController.performBounceBack(view: self.view)
        }
    }
    
    @objc private func glassValueChanged() {
        // Flash highlight on toggle
         if let thumb = self.thumbView {
             self.glassController.performTapAnimation(at: CGPoint(x: thumb.bounds.midX, y: thumb.bounds.midY))
        }
    }
    
    public func setOn(_ value: Bool, animated: Bool) {
        self._isOn = value
        if self.isNodeLoaded {
            (self.view as! UISwitch).setOn(value, animated: animated)
        }
    }
    
    override open func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        if #available(iOS 26.0, *) {
            return CGSize(width: 63.0, height: 28.0)
        } else {
            return CGSize(width: 51.0, height: 31.0)
        }
    }
    
    @objc func switchValueChanged(_ view: UISwitch) {
        self._isOn = view.isOn
        self.valueUpdated?(view.isOn)
    }
}
