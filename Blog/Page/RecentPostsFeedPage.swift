import SwiftUI
import SwiftData

private struct RecentPostAsListRow: View {
    
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    private let post: Post
    
    init(_ post: Post) {
        self.post = post
    }
    
    @State
    private var isPresentingConfirmDelete = false
    
    private func onConfirmDelete() {
        modelContext.delete(post)
        try? modelContext.save()
    }
    
    public var body: some View {
        NavigationLink(destination: DisplayPostPage(post)) {
            PostPreviewView(post, displayUser: true)
        }
        .confirmationDialog("Delete your post? (cannot be undone)", isPresented: $isPresentingConfirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onConfirmDelete)
            Button("Cancel", role: .cancel, action: {})
        }
        .swipeActions(edge: .trailing) {
            buttonSwipeTrailingEdge
        }
    }
    
    @ViewBuilder
    var buttonSwipeTrailingEdge: some View {
        if post.isOwnedBy(accountManager.loggedInUser) {
            Button("Delete") {
                isPresentingConfirmDelete = true
            }
            .tint(.red)
        } else {
            Button("Reply") {
                
            }
            .tint(.blue)
        }
    }
}

struct RecentPostsFeedPage: View {
    
    // MARK: Environment
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: SwiftData Queries
    @Query
    private var posts: [Post]
    @Query
    private var comments: [PostComment]
    @Query
    private var users: [UserAccount]
    
    // MARK: State
    @State
    private var isPresentingSheetCreatePost = false
    
    // MARK: Layout Declaration
    public var body: some View {
        NavigationStack {
            VStack {
                if accountManager.loggedInUser == nil {
                    AccountNotLoggedInView()
                        .padding(.bottom, 5)
                } else {
                    textWelcome
                        .padding(.horizontal)

                    buttonCreate
                        .padding(.horizontal)
                        .padding(.top, 5)
                        .padding(.bottom, 8)
                }
                
                if posts.isEmpty {
                    textNoPosts
                        .padding(.top, 10)
                } else {
                    listRecentPosts
                }
            }
            .navigationTitle("Feed")
        }
        .sheet(isPresented: $isPresentingSheetCreatePost, content: {
            CreatePostView()
        })
    }
}

extension RecentPostsFeedPage {
    
    // MARK: Button Views
    private var buttonCreate: some View {
        Button(action: {
            isPresentingSheetCreatePost = true
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
            Text("New Post")
                .font(.title3)
                .frame(height: 25)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
    }
    
    // MARK: List Views
    private var listRecentPosts: some View {
        return List {
            ForEach(posts) { post in
                RecentPostAsListRow(post)
            }
        }
    }
    
    // MARK: Text Views
    private var textWelcome: some View {
        let username = accountManager.loggedInUsernameOrNone
        return Text("Welcome, \(username)")
    }
    
    private var textNoPosts: some View {
        return Text("No recent posts")
            .font(.headline)
    }
}

// MARK: Previews
#Preview {
    RecentPostsFeedPage()
        .environmentObject(UserAccountManager())
}
