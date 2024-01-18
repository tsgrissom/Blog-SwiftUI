import LoremSwiftum
import SwiftUI
import SwiftData

struct DisplayCommentPage: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Query
    private var comments: [PostComment]
    @Query
    private var posts: [Post]
    @Query
    private var users: [UserAccount]
    
    private let comment: PostComment
    
    init(_ comment: PostComment) {
        self.comment = comment
    }
    
    @State
    private var fieldNewReplyContents = ""
    
    public var body: some View {
        HStack {
            VStack {
                HStack {
                    buttonReturnToPost
                    Spacer()
                }
                sectionCommentTree
                sectionAddReply
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
    }
    
    private var buttonReturnToPost: some View {
        let attachedTo = posts.first {
            $0.id == self.comment.postedBy
        }
        
        return NavigationLink(destination: {
            if attachedTo != nil {
                DisplayPostPage(attachedTo!)
            } else {
                Text("Could not load post")
            }
        }) {
            Text("Return to Post")
                .font(.subheadline)
        }
    }
    
    private var sectionCommentTree: some View {
        let children = self.comment.getChildComments(allComments: comments)
        return CommentTreeView(comment, children: children)
    }
    
    private var sectionAddReply: some View {
        let replyingTo = users.first { $0.id == self.comment.postedBy }
        let replyingToUsername = replyingTo != nil ? replyingTo!.username : "Unknown"
        
        func onSubmit() {
            let text = fieldNewReplyContents.trimmed
            
            if text.isEmpty {
                return
            }
            
            if accountManager.loggedInUser == nil {
                return
            }
            
            let post = posts.first { $0.id == comment.attachedTo }
            
            if post == nil {
                return
            }
            
            let commentReplyingTo = comments.first { $0.id == comment.id }
            
            let reply = PostComment(body: text, postedBy: accountManager.loggedInUser!, attachedTo: post!, parentComment: commentReplyingTo)
            
            modelContext.insert(reply)
            try? modelContext.save()
        }
        
        return HStack {
            TextField(text: $fieldNewReplyContents, prompt: Text("Your reply to \(replyingToUsername)'s comment")) {
                Text("Reply to \(replyingToUsername)'s comment")
            }
            .textFieldStyle(.roundedBorder)
            
            Button(action: onSubmit, label: {
                Text("Reply")
            })
        }
    }
}

#Preview {
    let tweet = LoremSwiftum.Lorem.tweet
    let shortTweet = LoremSwiftum.Lorem.shortTweet
    let firstName = LoremSwiftum.Lorem.firstName
    
    let mockUser = UserAccount(username: firstName, password: "Password")
    let mockPost = Post(body: tweet, postedBy: mockUser)
    let mockComment = PostComment(body: shortTweet, postedBy: mockUser, attachedTo: mockPost)
    
    return DisplayCommentPage(mockComment)
        .environmentObject(PostManager())
        .environmentObject(UserAccountManager())
}
