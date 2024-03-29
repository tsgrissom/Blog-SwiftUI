import LoremSwiftum
import SwiftUI
import SwiftData

struct PostPreviewView: View {
    
    // MARK: Environment
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: SwiftData Queries
    @Query
    private var users: [UserAccount]
    @Query
    private var comments: [PostComment]
    
    // MARK: Initialization
    private let post: Post
    private let displayUser: Bool
    private let displayReplyCount: Bool
    
    init(_ post: Post, displayUser: Bool = false, displayReplyCount: Bool = true) {
        self.post = post
        self.displayUser = displayUser
        self.displayReplyCount = displayReplyCount
    }
    
    // MARK: Helpers
    private var isOwnedByCurrentUser: Bool {
        return post.postedBy == accountManager.loggedInUser?.id
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(post.body)")
                    .truncationMode(.tail)
                    .lineLimit(1)
                rowUserAtTime
                    .font(.caption)
                rowReplyCount
            }
            
            Spacer()
        }
        .contextMenu {
            Button(
                "Reply",
                systemImage: "arrowshape.turn.up.forward",
                action: {}
            )
            Button(
                "Share",
                systemImage: "square.and.arrow.up",
                action: {}
            )
            
            if isOwnedByCurrentUser {
                Button(
                    "Delete",
                    systemImage: "trash",
                    role: .destructive,
                    action: {
                        modelContext.delete(post)
                        try? modelContext.save()
                    }
                )
            }
        }
    }
}

// MARK: Views
extension PostPreviewView {
    
    // MARK: Rows
    @ViewBuilder
    private var rowUserAtTime: some View {
        let createdDate = Date(timeIntervalSince1970: post.createdAt)
        let user = users.first { $0.id == post.postedBy }
        
        if user != nil && displayUser {
            UserAtTimeView(user: user!, at: createdDate, withProfilePicture: false)
        } else {
            rowUserAtTimeNull
        }
    }
    
    @ViewBuilder
    private var rowReplyCount: some View {
        let replies = post.getAttachedComments(allComments: comments)
        let count = replies.count
        let countStr = count==1 ? "reply" : "replies"
        
        if count > 0 && displayReplyCount {
            Text("\(count) \(countStr)")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            EmptyView()
        }
    }
    
    private var rowUserAtTimeNull: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        
        let createdDate = Date(timeIntervalSince1970: post.createdAt)
        let createdFmt = formatter.string(from: createdDate)
        
        return HStack(spacing: 3) {
            Text(createdFmt)
            Spacer()
        }
    }
}

// MARK: Previews
#Preview {
    let mockUser = MockupUtilities.getMockUser()
    let mockPost = MockupUtilities.getMockPost(by: mockUser)
    
    return VStack(spacing: 0) {
        Text("With User")
            .font(.title)
            .bold()
        Divider()
            .frame(width: 200)
        
        PostPreviewView(mockPost, displayUser: true)
        
        Text("Without User")
            .font(.title)
            .bold()
            .padding(.top)
        Divider()
            .frame(width: 200)
        
        PostPreviewView(mockPost, displayUser: false)
    }
    .environmentObject(UserAccountManager())
}
