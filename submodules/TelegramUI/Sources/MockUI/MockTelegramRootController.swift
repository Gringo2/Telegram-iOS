import Foundation
import UIKit
import Display
import AsyncDisplayKit

#if TELEGRAM_UI_ONLY

private final class MockTelegramRootNode: ASDisplayNode {
    private let bannerNode: MockUIBannerNode
    private let buttonNode: ASButtonNode
    
    override init() {
        self.bannerNode = MockUIBannerNode()
        
        self.buttonNode = ASButtonNode()
        self.buttonNode.setTitle("Open Mock Chat List", with: UIFont.systemFont(ofSize: 17.0), with: .white, for: .normal)
        self.buttonNode.backgroundColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        self.buttonNode.cornerRadius = 10.0
        
        super.init()
        
        self.backgroundColor = .black
        self.addSubnode(self.bannerNode)
        self.addSubnode(self.buttonNode)
    }
    
    override func layout() {
        super.layout()
        
        let bannerSize = self.bannerNode.updateLayout(size: self.bounds.size)
        self.bannerNode.frame = CGRect(origin: .zero, size: bannerSize)
        
        let buttonWidth: CGFloat = 200.0
        let buttonHeight: CGFloat = 50.0
        self.buttonNode.frame = CGRect(
            x: (self.bounds.width - buttonWidth) / 2.0,
            y: (self.bounds.height - buttonHeight) / 2.0,
            width: buttonWidth,
            height: buttonHeight
        )
    }
}

final class MockTelegramRootController: ViewController {
    private var controlNode: MockTelegramRootNode {
        return self.displayNode as! MockTelegramRootNode
    }
    
    override init(navigationBarPresentationData: NavigationBarPresentationData?) {
        super.init(navigationBarPresentationData: navigationBarPresentationData)
        
        self.title = "Telegram"
        self.navigationPresentation = .master
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadDisplayNode() {
        self.displayNode = MockTelegramRootNode()
        
        (self.displayNode as! MockTelegramRootNode).buttonNode.addTarget(
            self,
            action: #selector(self.openChatListPressed),
            forControlEvents: .touchUpInside
        )
    }
    
    @objc private func openChatListPressed() {
        let chatListController = MockChatListController(navigationBarPresentationData: nil)
        self.push(chatListController)
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.controlNode.frame = CGRect(origin: .zero, size: layout.size)
        self.controlNode.setNeedsLayout()
    }
}

#endif
