import LoremSwiftum
import SwiftUI
import SwiftData

struct CommentView: View {
    
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
    private var isPresentingConfirmDeleteComment = false
    
    private var isOwnedByCurrentUser: Bool {
        let current = accountManager.loggedInUser
        
        if current != nil {
            return comment.postedBy == current!.id
        }
        
        return false
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 3) {
                textUsername
                textCreatedAt
                
                Spacer()
            }
            .font(.caption)
            
            textCommentBody
        }
        .confirmationDialog("Are you sure you want to delete your comment?", isPresented: $isPresentingConfirmDeleteComment, titleVisibility: .visible) {
            Button(role: .destructive, action: {
                modelContext.delete(comment)
                try? modelContext.save()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                Text("Delete Comment")
            }
            Button(role: .cancel, action: {}) {
                Text("Cancel")
            }
        }
        .contextMenu(menuItems: {
            if isOwnedByCurrentUser {
                buttonDelete
                buttonEdit
            }
            
            buttonShare
        })
    }
    
    private var buttonEdit: some View {
        return Button(action: {}) {
            Image(systemName: "pencil")
            Text("Edit")
        }
    }
    
    private var buttonShare: some View {
        return Button(action: {}) {
            Image(systemName: "square.and.arrow.up")
            Text("Share")
        }
    }
    
    private var buttonDelete: some View {
        func onPress() {
            isPresentingConfirmDeleteComment = true
        }
        
        return Button("Delete", systemImage: "trash", role: .destructive, action: onPress)
            
    }
    
    private var textCommentBody: some View {
        return Text("\"\(comment.body)\"")
    }
    
    private var textCreatedAt: some View {
        let formatter = DateFormatter()
        let createdDate = Date(timeIntervalSince1970: comment.createdAt)
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: createdDate)
        
        return Text("at \(createdFmt)")
    }
    
    private var textUsername: some View {
        let user = users.first { $0.id == comment.postedBy }
        
        return Text("@\(user.getUsername())")
            .foregroundStyle(.blue)
    }
}

#Preview {
    func generateViewForMockComment() -> some View {
        let firstName  = LoremSwiftum.Lorem.firstName
        let lastName   = LoremSwiftum.Lorem.lastName
        let tweet      = LoremSwiftum.Lorem.tweet
        
        let mockUser = UserAccount(username: firstName, password: "Password")
        mockUser.displayName = "\(firstName)\(lastName)"
        let mockPost = Post(body: tweet, postedBy: mockUser)
        let mockComment = PostComment(body: "String", postedBy: mockUser, attachedTo: mockPost)
        
        return CommentView(mockComment)
    }
    
    return VStack {
        ForEach(1...10, id: \.self) { _ in
            generateViewForMockComment()
        }
    }
    .environmentObject(UserAccountManager())
}
