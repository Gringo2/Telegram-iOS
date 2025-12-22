import UIKit

public final class GlassHighlightLayer: CALayer {
    
    private let gradientLayer = CAGradientLayer()
    
    public override init() {
        super.init()
        setupLayer()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        // Radial gradient for 3D specular look
        gradientLayer.type = .radial
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        
        // Center the gradient effect
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        // Initial state: hidden
        self.opacity = 0.0
        
        // Add gradient as logic-free sublayer
        addSublayer(gradientLayer)
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        gradientLayer.frame = self.bounds
    }
    
    // Configurable brightness API
    public func setBrightness(_ alpha: CGFloat) {
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(alpha).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
    }
}
