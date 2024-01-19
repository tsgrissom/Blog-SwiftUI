import LoremSwiftum
import SwiftUI

enum CommentTreeDisplayMode: CaseIterable {
    case all
    case collapsedAfterOne
}

struct CommentTreeView: View {
    
    private let parent: PostComment
    private let children: [PostComment]
    
    @State
    private var mode: CommentTreeDisplayMode
    
    init(
        _ parent: PostComment,
        children: [PostComment],
        mode: CommentTreeDisplayMode = .all
    ) {
        self.parent = parent
        self.children = children
        self.mode = mode
    }
    
    private func getViewForChild(text: String, action: @escaping () -> Void) -> some View {
        return HStack {
            Button(action: {
                action()
            }) {
                Image(systemName: "arrow.turn.down.right")
            }
            .buttonStyle(.plain)
            
            Text(text)
                .font(.caption)
            Spacer()
        }
    }
    
    private func getViewForChildComment(_ comment: PostComment, action: @escaping () -> Void) -> some View {
        return HStack {
            Button(action: {
                action()
            }) {
                Image(systemName: "arrow.turn.down.right")
            }
            .buttonStyle(.plain)
            
            CommentView(comment)
                .font(.caption)
            Spacer()
        }
    }
    
    private func cycleMode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switch mode {
        case .all:
            self.mode = .collapsedAfterOne
        case .collapsedAfterOne:
            self.mode = .all
        }
    }
    
    public var body: some View {
        VStack {
            CommentView(parent)
            
            switch mode {
                case .all: childrenDisplayModeAll
                case .collapsedAfterOne: childrenDisplayModeCollapsedAfterOne
            }
        }
    }
    
    private var childrenDisplayModeAll: some View {
        ForEach(children) { child in
            getViewForChildComment(child, action: cycleMode)
        }
    }
    
    @ViewBuilder
    private var childrenDisplayModeCollapsedAfterOne: some View {
        if children.count > 0 {
            getViewForChildComment(children[0], action: cycleMode)
        }
        
        if children.count > 1 {
            getViewForChild(text: "... \(children.count-1) more", action: cycleMode)
                .foregroundStyle(Color.accentColor)
        }
    }
}

#Preview("Display Mode All") {
    let firstName = LoremSwiftum.Lorem.firstName
    let tweet = LoremSwiftum.Lorem.tweet
    let shortTweet = LoremSwiftum.Lorem.shortTweet
    
    let mockUser = UserAccount(username: firstName, password: "Password")
    let mockPost = Post(body: tweet, postedBy: mockUser)
    let mockComment = PostComment(body: "Parent: \(shortTweet)", postedBy: mockUser, attachedTo: mockPost)
    let mockReplyToComment = PostComment(body: "Child: \(shortTweet)", postedBy: mockUser, attachedTo: mockPost, parentComment: mockComment)
    
    return CommentTreeView(mockComment, children: [mockReplyToComment, mockReplyToComment, mockReplyToComment], mode: .all)
}

#Preview("Display Mode Collapsed After One") {
    let firstName = LoremSwiftum.Lorem.firstName
    let tweet = LoremSwiftum.Lorem.tweet
    let shortTweet = LoremSwiftum.Lorem.shortTweet
    
    let mockUser = UserAccount(username: firstName, password: "Password")
    let mockPost = Post(body: tweet, postedBy: mockUser)
    let mockComment = PostComment(body: "Parent: \(shortTweet)", postedBy: mockUser, attachedTo: mockPost)
    let mockReplyToComment = PostComment(body: "Child: \(shortTweet)", postedBy: mockUser, attachedTo: mockPost, parentComment: mockComment)
    
    return CommentTreeView(mockComment, children: [mockReplyToComment, mockReplyToComment, mockReplyToComment], mode: .collapsedAfterOne)
}
