import UIKit

/// Orchestrates glass effects (highlight, deformation) for a target view.
/// Does NOT manage layer hierarchy - the owner view must add `highlightLayer` to its layer tree.
public final class GlassEffectController {
    
    // MARK: - Public Layers
    
    /// The layer rendering the specular highlight.
    /// Owner view is responsible for adding this to its layer hierarchy and setting its frame/layout.
    public let highlightLayer = GlassHighlightLayer()
    
    // MARK: - Initialization
    
    public init() {
        // No-op init: purely composition helper
    }
    
    // MARK: - Interaction Handling
    
    /// Trigger a tap animation at the specified location
    /// - Parameter location: Touch location in the owner view's coordinate space
    public func performTapAnimation(at location: CGPoint) {
        GlassInteractionAnimator.animateTapHighlight(layer: highlightLayer, at: location)
    }
    
    /// Trigger a scale up animation on the target view
    /// - Parameter view: The view to scale (usually the lens view)
    /// - Parameter location: The touch source location
    public func performScaleUp(view: UIView, at location: CGPoint) {
        GlassInteractionAnimator.animateScaleUp(view: view, at: location)
    }
    
    /// Trigger a bounce back animation
    /// - Parameter view: The view to reset
    public func performBounceBack(view: UIView) {
        GlassInteractionAnimator.animateBounceBack(view: view)
    }
    
    // MARK: - Layout
    
    /// Helper to update sublayers if needed (e.g. if the highlight layer needs explicit resizing)
    public func updateLayout(bounds: CGRect) {
        // Assuming highlight layer manages its own internal gradient layout via layoutSublayers()
        // If we strictly follow Phase 0, highlight layer is sized 80x80 usually, 
        // but here it might be filling the view or just positioned.
        // For Phase 0 logic: highlight is 80x80 positioned at tap.
        
        // However, GlassHighlightLayer instructions (Step 2) had "gradientLayer.frame = self.bounds"
        // This implies GlassHighlightLayer is intended to be the size of the *effect* or the *view*?
        // In Phase 0 inline code:
        // self.specularHighlightLayer.frame = CGRect(x: location.x - 40, y: location.y - 40, width: 80, height: 80)
        
        // So the controller doesn't need to force layout on bounds change if the frame is dynamic per tap.
        // But if we want it to be a persistent overlay, we might size it to bounds.
        
        // Phase 1 strategy is "Augment". We'll let the animator handle frame positioning as it did in Phase 0.
        // No explicit layout update needed for the Highlight *itself* yet.
    }
}
