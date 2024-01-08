import SwiftUI
import SwiftData

struct RecentPostsFeedPage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Query
    private var posts: [Post]
    @Query
    private var comments: [PostComment]
    @Query
    private var users: [UserAccount]
    
    @State
    private var displaySheetCreatePost = false
    
    private func onPressCreateButton() {
        displaySheetCreatePost = true
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                if accountManager.loggedInUser == nil {
                    NotLoggedInView()
                        .padding(.bottom, 5)
                } else {
                    Text("Welcome, \(accountManager.loggedInUsernameOrNone)")
                        .padding(.horizontal)

                    buttonCreate
                        .padding(.horizontal)
                        .padding(.top, 5)
                        .padding(.bottom, 8)
                }
                
                if posts.isEmpty {
                    Text("No recent posts")
                        .font(.headline)
                        .padding(.top, 10)
                } else {
                    List {
                        ForEach(posts) { post in
                            getPostAsListRow(post)
                        }
                    }
                }
            }
            .navigationTitle("Feed")
        }
        .sheet(isPresented: $displaySheetCreatePost, content: {
            CreatePostView()
        })
    }
    
    private var buttonCreate: some View {
        Button(action: onPressCreateButton) {
            Image(systemName: "plus")
                .imageScale(.large)
            Text("New Post")
                .font(.title3)
                .frame(height: 25)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
    }
    
    private func getPostAsListRow(_ post: Post) -> some View {
        let createdDate = Date(timeIntervalSince1970: post.createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: createdDate)
        
        let commentsCount = post.getAttachedComments(allComments: comments).count
        let countStr = if commentsCount == 1 {
            "\(commentsCount) reply"
        } else {
            "\(commentsCount) replies"
        }
        
        let user: UserAccount? = users.first { that in
            that.id == post.postedBy
        }
        let username = user?.username ?? "Unknown"
        
        return VStack(alignment: .leading) {
            HStack(spacing: 3) {
                NavigationLink(destination: DisplayPostPage(post)) {
                    Text("@\(username)")
                        .foregroundStyle(.blue)
                }
            }
            .font(.caption)
            
            Text("at \(createdFmt)")
                .font(.caption)
            
            Text(post.body)
            
            if commentsCount > 0 {
                Text(countStr)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    RecentPostsFeedPage()
        .environmentObject(UserAccountManager())
}
