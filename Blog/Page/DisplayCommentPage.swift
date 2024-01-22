import LoremSwiftum
import SwiftUI
import SwiftData

struct DisplayCommentPage: View {
    
    // MARK: Environment
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: SwiftData Queries
    @Query
    private var comments: [PostComment]
    @Query
    private var posts: [Post]
    @Query
    private var users: [UserAccount]
    
    // MARK: Initialization
    private let comment: PostComment
    
    init(_ comment: PostComment) {
        self.comment = comment
    }
    
    // MARK: State
    @State
    private var fieldNewReplyContents = ""
    
    // MARK: Button Handlers
    private func onSubmitNewReply() {
        let body = fieldNewReplyContents.trimmed
        
        if body.isEmpty {
            return
        }
        
        let postedBy = accountManager.loggedInUser
        
        if accountManager.loggedInUser == nil {
            return
        }
        
        let attachedTo = posts.first { $0.id == comment.attachedTo }
        
        if attachedTo == nil {
            return
        }
        
        let parentComment = comments.first { $0.id == comment.id }
        
        fieldNewReplyContents = ""
        let new = PostComment(
            body: body,
            postedBy: postedBy!,
            attachedTo: attachedTo!,
            parentComment: parentComment
        )
        
        modelContext.insert(new)
        try? modelContext.save()
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        let postedBy = users.first { $0.id == comment.postedBy }
        let title = "Comment by \(postedBy.getUsername())"
        
        return HStack {
            VStack {
                sectionCommentTree
                sectionAddReply
                Spacer()
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle(title)
    }
}

extension DisplayCommentPage {
    
    // MARK: Section Views
    private var sectionCommentTree: some View {
        let children = self.comment.getChildComments(allComments: comments)
        return CommentTreeView(comment, children: children)
    }
    
    private var sectionAddReply: some View {
        let replyingTo = users.first { $0.id == self.comment.postedBy }
        
        return HStack {
            TextField(
                text: $fieldNewReplyContents,
                prompt: Text("Your reply to \(replyingTo.getUsername())'s comment")
            ) {
                Text("Reply to \(replyingTo.getUsername())'s comment")
            }
            .textFieldStyle(.roundedBorder)
            
            Button("Reply", action: onSubmitNewReply)
        }
    }
}

// MARK: Previews
#Preview {
    let mockUser = MockupUtilities.getMockUser()
    let mockPost = MockupUtilities.getMockPost(by: mockUser)
    let mockComment = MockupUtilities.getMockComment(by: mockUser, to: mockPost)
    
    return NavigationStack {
        DisplayCommentPage(mockComment)
    }
    .environmentObject(PostManager())
    .environmentObject(UserAccountManager())
}
