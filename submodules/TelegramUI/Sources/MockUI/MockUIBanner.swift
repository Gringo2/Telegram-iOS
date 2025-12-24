import Foundation
import UIKit
import Display
import AsyncDisplayKit

#if TELEGRAM_UI_ONLY

final class MockUIBannerNode: ASDisplayNode {
    private let backgroundNode: ASDisplayNode
    private let textNode: ASTextNode
    
    override init() {
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        
        self.textNode = ASTextNode()
        self.textNode.attributedText = NSAttributedString(
            string: "🧪 UI-ONLY MODE",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 14.0),
                .foregroundColor: UIColor.white
            ]
        )
        
        super.init()
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.textNode)
    }
    
    override func layout() {
        super.layout()
        
        self.backgroundNode.frame = self.bounds
        
        let textSize = self.textNode.measure(CGSize(width: self.bounds.width, height: .greatestFiniteMagnitude))
        self.textNode.frame = CGRect(
            x: (self.bounds.width - textSize.width) / 2.0,
            y: (self.bounds.height - textSize.height) / 2.0,
            width: textSize.width,
            height: textSize.height
        )
    }
    
    func updateLayout(size: CGSize) -> CGSize {
        let height: CGFloat = 32.0
        self.frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: height))
        self.setNeedsLayout()
        return CGSize(width: size.width, height: height)
    }
}

#endif
