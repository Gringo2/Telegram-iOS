import Foundation
import UIKit
import Display
import AsyncDisplayKit

#if TELEGRAM_UI_ONLY

final class MockWindow: UIWindow, WindowHost {
    
    // MARK: - WindowHost Protocol Implementation
    
    func forEachController(_ f: (ContainableController) -> Void) {
        if let root = self.rootViewController as? ContainableController {
            f(root)
        }
    }
    
    func present(_ controller: ContainableController, on level: PresentationSurfaceLevel, blockInteraction: Bool, completion: @escaping () -> Void) {
        self.rootViewController?.present(controller, animated: true, completion: completion)
    }
    
    func presentInGlobalOverlay(_ controller: ContainableController) {
        // No-op for mock
    }
    
    func addGlobalPortalHostView(sourceView: PortalSourceView) {
        // No-op for mock
    }
    
    func invalidateDeferScreenEdgeGestures() {
        // No-op for mock
    }
    
    func invalidatePrefersOnScreenNavigationHidden() {
        // No-op for mock
    }
    
    func invalidateSupportedOrientations() {
        // No-op for mock
    }
    
    func cancelInteractiveKeyboardGestures() {
        // No-op for mock
    }
}

#endif
