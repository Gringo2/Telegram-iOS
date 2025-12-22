import UIKit

public final class GlassInteractionAnimator {
    
    // MARK: - Physics Constants
    
    public struct Physics {
        /// 40ms flash for immediate feedback
        public static let tapHighlight = (duration: 0.04, scale: 1.0)
        
        /// Scale up to 1.04x with ζ = 0.85
        public static let scaleUp = (
            duration: 0.18,
            scale: 1.04,
            damping: 22.68,
            stiffness: 180.0,
            mass: 1.0
        )
        
        /// Critically damped bounce back
        public static let bounce = (
            duration: 0.45,
            damping: 28.28,
            stiffness: 200.0,
            mass: 1.0
        )
    }
    
    // MARK: - Animation Logic
    
    /// Pure logic: Calculates and applies the tap highlight animation to a layer
    public static func animateTapHighlight(layer: CALayer, at location: CGPoint) {
        // Remove previous animation to prevent stacking
        layer.removeAnimation(forKey: "tapHighlight")
        
        // 40ms opacity spike
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = Physics.tapHighlight.duration
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // Center the layer at tap location
        // Note: layer frame/position updates should be handled by the controller/owner if complex,
        // but for a simple highlight layer, setting position here is standard.
        // Assuming layer is already sized (e.g. 80x80) by its owner.
        layer.position = location
        CATransaction.commit()
        
        layer.add(animation, forKey: "tapHighlight")
    }
    
    /// Pure logic: Applies scale animation to a view
    public static func animateScaleUp(view: UIView, at location: CGPoint) {
        let p = Physics.scaleUp
        
        // Calculate relative anchor point
        let anchorX = location.x / view.bounds.width
        let anchorY = location.y / view.bounds.height
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        view.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
        view.layer.position = location
        CATransaction.commit()
        
        let scale = CASpringAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.0
        scale.toValue = p.scale
        scale.mass = p.mass
        scale.stiffness = p.stiffness
        scale.damping = p.damping
        scale.duration = scale.settlingDuration
        scale.fillMode = .forwards
        scale.isRemovedOnCompletion = false
        
        view.layer.add(scale, forKey: "scaleUp")
        // Manual property update to match fillMode
        view.layer.transform = CATransform3DMakeScale(p.scale, p.scale, 1.0)
    }
    
    public static func animateBounceBack(view: UIView) {
        let p = Physics.bounce
        
        let bounce = CASpringAnimation(keyPath: "transform.scale")
        bounce.fromValue = view.layer.presentation()?.value(forKeyPath: "transform.scale") ?? Physics.scaleUp.scale
        bounce.toValue = 1.0
        bounce.mass = p.mass
        bounce.stiffness = p.stiffness
        bounce.damping = p.damping
        bounce.duration = bounce.settlingDuration
        
        view.layer.add(bounce, forKey: "bounceBack")
        view.layer.transform = CATransform3DIdentity
        
        // Reset anchor point cleanly
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.layer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        CATransaction.commit()
    }
}
