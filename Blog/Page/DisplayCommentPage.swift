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
        let reply = PostComment(body: body, postedBy: postedBy!, attachedTo: attachedTo!, parentComment: parentComment)
        
        modelContext.insert(reply)
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
    
    // MARK: Section Views
    private var sectionCommentTree: some View {
        let children = self.comment.getChildComments(allComments: comments)
        return CommentTreeView(comment, children: children)
    }
    
    private var sectionAddReply: some View {
        let replyingTo = users.first { $0.id == self.comment.postedBy }
        
        return HStack {
            TextField(text: $fieldNewReplyContents, prompt: Text("Your reply to \(replyingTo.getUsername())'s comment")) {
                Text("Reply to \(replyingTo.getUsername())'s comment")
            }
            .textFieldStyle(.roundedBorder)
            
            Button("Reply", action: onSubmitNewReply)
        }
    }
}

// MARK: Previews
#Preview {
    let tweet = LoremSwiftum.Lorem.tweet
    let shortTweet = LoremSwiftum.Lorem.shortTweet
    let firstName = LoremSwiftum.Lorem.firstName
    
    let mockUser = UserAccount(username: firstName, password: "Password")
    let mockPost = Post(body: tweet, postedBy: mockUser)
    let mockComment = PostComment(body: shortTweet, postedBy: mockUser, attachedTo: mockPost)
    
    return NavigationStack {
        DisplayCommentPage(mockComment)
    }
    .environmentObject(PostManager())
    .environmentObject(UserAccountManager())
}
