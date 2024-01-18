import LoremSwiftum
import SwiftUI

enum CommentTreeDisplayMode: CaseIterable {
    case all
    case collapsedAfterOne
}

struct CommentTreeView: View {
    
    private let parentComment: PostComment
    private let childComments: [PostComment]
    private let mode: CommentTreeDisplayMode
    
    init(
        _ parent: PostComment,
        children: [PostComment],
        mode: CommentTreeDisplayMode = .all
    ) {
        self.parentComment = parent
        self.childComments = children
        self.mode = mode
    }
    
    private func getViewForChild(text: String) -> some View {
        return HStack {
            Image(systemName: "arrow.turn.down.right")
            Text(text)
            Spacer()
        }
    }
    
    private func getViewForChildComment(_ child: PostComment) -> some View {
        return getViewForChild(text: child.body)
    }
    
    public var body: some View {
        VStack {
            HStack {
                Text(parentComment.body) // Display parent comment
                Spacer()
            }
            
            switch mode {
                case .all: childrenDisplayModeAll
                case .collapsedAfterOne: childrenDisplayModeCollapsedAfterOne
            }
        }
    }
    
    private var childrenDisplayModeAll: some View {
        ForEach(childComments) { child in
            getViewForChildComment(child)
        }
    }
    
    @ViewBuilder
    private var childrenDisplayModeCollapsedAfterOne: some View {
        if childComments.count > 0 {
            getViewForChildComment(childComments[0])
        }
        
        if childComments.count > 1 {
            getViewForChild(text: "...")
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
