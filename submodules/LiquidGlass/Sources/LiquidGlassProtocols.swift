import UIKit

/// Protocol for objects that can display a glass highlight animation
public protocol GlassHighlighting: AnyObject {
    /// Animate a tap highlight at the specified location within the view's coordinate space
    func animateTap(at location: CGPoint)
}

/// Protocol for the Glass Controller to interact with its owner view
// (Intentionally minimal for Phase 1)
public protocol GlassEffectControllerDelegate: AnyObject {
    // Future expansion points
}
