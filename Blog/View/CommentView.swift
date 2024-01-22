import LoremSwiftum
import SwiftUI
import SwiftData

struct CommentView: View {
    
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
    private var isPresentingConfirmDeleteComment = false
    
    // MARK: Helpers
    private var isOwnedByCurrentUser: Bool {
        let current = accountManager.loggedInUser
        
        if current != nil {
            return comment.postedBy == current!.id
        }
        
        return false
    }
    
    // MARK: Layout Declaration
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
        .confirmationDialog(
            "Are you sure you want to delete your comment?",
            isPresented: $isPresentingConfirmDeleteComment,
            titleVisibility: .visible
        ) {
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
}

// MARK: Views
extension CommentView {
    
    // MARK: Buttons
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
        
        return Button(
            "Delete",
            systemImage: "trash",
            role: .destructive,
            action: onPress
        )
    }
    
    // MARK: Text
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

// MARK: Previews
#Preview {
    func generateViewForMockComment() -> some View {
        let mockUser    = MockupUtilities.getMockUser()
        let mockPost    = MockupUtilities.getMockPost(by: mockUser)
        let mockComment = MockupUtilities.getMockComment(by: mockUser, to: mockPost)
        
        return CommentView(mockComment)
    }
    
    return VStack {
        ForEach(1...10, id: \.self) { _ in
            generateViewForMockComment()
        }
    }
    .environmentObject(UserAccountManager())
}
