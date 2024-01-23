import LoremSwiftum
import SwiftUI
import SwiftData

private struct CommentAsListRow: View {
    
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Query
    private var comments: [PostComment]
    
    private let comment: PostComment
    private let descendant: Bool
    
    init(_ comment: PostComment, descendant: Bool = false) {
        self.comment = comment
        self.descendant = descendant
    }
    
    private var children: [PostComment] {
        return comment.getChildComments(allComments: comments)
    }
    
    public var body: some View {
        NavigationLink(destination: DisplayCommentPage(comment)) {
            HStack(spacing: 3) {
                if descendant {
                    Image(systemName: "arrow.turn.down.right")
                    CommentTreeView(comment, children: children, mode: .collapseAll)
                } else {
                    CommentView(comment)
                }
            }
        }
    }
}

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
    
    private var children: [PostComment] {
        return self.comment.getChildComments(allComments: comments)
    }
    
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
        
        return VStack {
            if children.isEmpty {
                CommentView(comment)
                    .padding(.horizontal, 25)
                Spacer()
                sectionAddReply
                    .padding(.horizontal)
            } else {
                sectionCommentTreeAsList
                sectionAddReply
                    .padding([.horizontal, .top])
                Spacer()
            }
        }
        .buttonStyle(.bordered)
        .navigationTitle(title)
    }
}

extension DisplayCommentPage {
    
    @ViewBuilder
    private func getSwipeActionsForComment(_ that: PostComment) -> some View {
        if that.isOwnedBy(accountManager.loggedInUser) {
            Button("Delete") {
                modelContext.delete(comment)
                try? modelContext.save()
            }
            .tint(.red)
        }
        
        Button("Reply") {
            print("Reply screen") // TODO
        }
        .tint(.blue)
    }
    
    // MARK: Section Views
    private var sectionCommentTreeAsList: some View {
        List {
            CommentAsListRow(comment)
                .swipeActions(edge: .trailing, content: {
                    getSwipeActionsForComment(comment)
                })
            ForEach(children) { child in
                CommentAsListRow(child, descendant: true)
                    .swipeActions(edge: .trailing, content: {
                        getSwipeActionsForComment(child)
                    })
            }
        }
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
            .onSubmit {
                onSubmitNewReply()
            }
            
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
