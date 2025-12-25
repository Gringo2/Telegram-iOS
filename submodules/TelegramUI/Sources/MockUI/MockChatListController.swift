import Foundation
import UIKit
import Display
import AsyncDisplayKit
import AppBundle

#if TELEGRAM_UI_ONLY

struct MockPeer {
    let id: String
    let name: String
    let lastMessage: String
    let unreadCount: Int
    let avatarColor: UIColor
}

private let mockPeers: [MockPeer] = [
    MockPeer(id: "1", name: "Saved Messages", lastMessage: "You: Test message", unreadCount: 0, avatarColor: UIColor(red: 0.345, green: 0.663, blue: 0.902, alpha: 1.0)),
    MockPeer(id: "2", name: "John Doe", lastMessage: "Hey, how are you?", unreadCount: 3, avatarColor: UIColor(red: 0.902, green: 0.345, blue: 0.345, alpha: 1.0)),
    MockPeer(id: "3", name: "Design Team", lastMessage: "Alice: New mockups ready", unreadCount: 5, avatarColor: UIColor(red: 0.345, green: 0.902, blue: 0.537, alpha: 1.0)),
    MockPeer(id: "4", name: "Jane Smith", lastMessage: "Thanks!", unreadCount: 0, avatarColor: UIColor(red: 0.902, green: 0.663, blue: 0.345, alpha: 1.0)),
    MockPeer(id: "5", name: "Dev Chat", lastMessage: "Bob: Fixed the bug", unreadCount: 12, avatarColor: UIColor(red: 0.537, green: 0.345, blue: 0.902, alpha: 1.0))
]

private final class MockChatListItemNode: ASDisplayNode {
    private let avatarNode: ASDisplayNode
    private let nameNode: ASTextNode
    private let messageNode: ASTextNode
    private let badgeNode: ASTextNode
    private let badgeBackgroundNode: ASDisplayNode
    private let separatorNode: ASDisplayNode
    
    private let peer: MockPeer
    
    init(peer: MockPeer) {
        self.peer = peer
        
        self.avatarNode = ASDisplayNode()
        self.avatarNode.backgroundColor = peer.avatarColor
        self.avatarNode.cornerRadius = 25.0
        
        self.nameNode = ASTextNode()
        self.nameNode.attributedText = NSAttributedString(
            string: peer.name,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17.0, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
        )
        
        self.messageNode = ASTextNode()
        self.messageNode.attributedText = NSAttributedString(
            string: peer.lastMessage,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15.0),
                .foregroundColor: UIColor(white: 0.6, alpha: 1.0)
            ]
        )
        
        self.badgeBackgroundNode = ASDisplayNode()
        self.badgeBackgroundNode.backgroundColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        self.badgeBackgroundNode.cornerRadius = 10.0
        self.badgeBackgroundNode.isHidden = peer.unreadCount == 0
        
        self.badgeNode = ASTextNode()
        self.badgeNode.attributedText = NSAttributedString(
            string: "\(peer.unreadCount)",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 14.0),
                .foregroundColor: UIColor.white
            ]
        )
        self.badgeNode.isHidden = peer.unreadCount == 0
        
        self.separatorNode = ASDisplayNode()
        self.separatorNode.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        
        super.init()
        
        self.backgroundColor = .black
        self.addSubnode(self.avatarNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.messageNode)
        self.addSubnode(self.badgeBackgroundNode)
        self.addSubnode(self.badgeNode)
        self.addSubnode(self.separatorNode)
    }
    
    override func layout() {
        super.layout()
        
        let leftInset: CGFloat = 16.0
        let avatarSize: CGFloat = 50.0
        let verticalPadding: CGFloat = 8.0
        
        self.avatarNode.frame = CGRect(
            x: leftInset,
            y: verticalPadding,
            width: avatarSize,
            height: avatarSize
        )
        
        let contentLeft = leftInset + avatarSize + 12.0
        let contentWidth = self.bounds.width - contentLeft - 16.0
        
        let nameSize = self.nameNode.measure(CGSize(width: contentWidth - 60.0, height: .greatestFiniteMagnitude))
        self.nameNode.frame = CGRect(
            x: contentLeft,
            y: verticalPadding + 4.0,
            width: nameSize.width,
            height: nameSize.height
        )
        
        let messageSize = self.messageNode.measure(CGSize(width: contentWidth, height: .greatestFiniteMagnitude))
        self.messageNode.frame = CGRect(
            x: contentLeft,
            y: verticalPadding + 4.0 + nameSize.height + 4.0,
            width: messageSize.width,
            height: messageSize.height
        )
        
        if !self.badgeNode.isHidden {
            let badgeSize = self.badgeNode.measure(CGSize(width: 100.0, height: 20.0))
            let badgeWidth = max(20.0, badgeSize.width + 12.0)
            
            self.badgeBackgroundNode.frame = CGRect(
                x: self.bounds.width - 16.0 - badgeWidth,
                y: verticalPadding + 4.0,
                width: badgeWidth,
                height: 20.0
            )
            
            self.badgeNode.frame = CGRect(
                x: self.bounds.width - 16.0 - badgeWidth + (badgeWidth - badgeSize.width) / 2.0,
                y: verticalPadding + 4.0 + (20.0 - badgeSize.height) / 2.0,
                width: badgeSize.width,
                height: badgeSize.height
            )
        }
        
        self.separatorNode.frame = CGRect(
            x: contentLeft,
            y: self.bounds.height - 0.5,
            width: self.bounds.width - contentLeft,
            height: 0.5
        )
    }
}

private final class MockChatListNode: ASDisplayNode {
    private let bannerNode: MockUIBannerNode
    private let scrollNode: ASScrollNode
    private let itemNodes: [MockChatListItemNode]
    
    override init() {
        self.bannerNode = MockUIBannerNode()
        self.scrollNode = ASScrollNode()
        self.itemNodes = mockPeers.map { MockChatListItemNode(peer: $0) }
        
        super.init()
        
        self.backgroundColor = .black
        self.addSubnode(self.bannerNode)
        self.addSubnode(self.scrollNode)
        self.itemNodes.forEach { self.scrollNode.addSubnode($0) }
    }
    
    override func layout() {
        super.layout()
        
        let bannerSize = self.bannerNode.updateLayout(size: self.bounds.size)
        self.bannerNode.frame = CGRect(origin: .zero, size: bannerSize)
        
        self.scrollNode.frame = CGRect(
            x: 0.0,
            y: bannerSize.height,
            width: self.bounds.width,
            height: self.bounds.height - bannerSize.height
        )
        
        let itemHeight: CGFloat = 66.0
        for (index, node) in self.itemNodes.enumerated() {
            node.frame = CGRect(x: 0.0, y: CGFloat(index) * itemHeight, width: self.bounds.width, height: itemHeight)
        }
        
        self.scrollNode.view.contentSize = CGSize(width: self.bounds.width, height: CGFloat(self.itemNodes.count) * itemHeight)
    }
}

final class MockChatListController: ViewController {
    private var controlNode: MockChatListNode {
        return self.displayNode as! MockChatListNode
    }
    
    override init(navigationBarPresentationData: NavigationBarPresentationData?) {
        super.init(navigationBarPresentationData: navigationBarPresentationData)
        
        self.title = "Chats"
        
        // Configuring Tab Bar Item for Liquid Glass Fidelity
        self.tabBarItem.title = "Chats"
        if let icon = UIImage(bundleImageName: "Chat List/Tabs/IconChats") {
            self.tabBarItem.image = icon
            self.tabBarItem.selectedImage = icon
        }
        self.tabBarItem.animationName = "TabChats"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadDisplayNode() {
        self.displayNode = MockChatListNode()
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.controlNode.frame = CGRect(origin: .zero, size: layout.size)
        self.controlNode.setNeedsLayout()
    }
}

#endif
