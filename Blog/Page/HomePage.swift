import SwiftUI
import SwiftData

struct HomePage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Query
    private var posts: [BlogPost]
    @Query
    private var comments: [BlogComment]
    
    @State
    private var displaySheetCreatePost = false
    
    private func onPressCreateButton() {
        displaySheetCreatePost = true
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if accountManager.loggedInUser == nil {
                    navLinkToAccountManagement
                } else {
                    if posts.count > 0 {
                        Text("Welcome, \(accountManager.loggedInUsernameOrNone)")
                            .padding(.horizontal)
                    }
                    Button(action: onPressCreateButton) {
                        Image(systemName: "plus")
                        Text("New Post")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                    .tint(.blue)
                }
                
                sectionRecentPosts
            }
            .navigationTitle("Feed")
        }
        .sheet(isPresented: $displaySheetCreatePost, content: {
            CreateBlogPostPage()
        })
    }
    
    private var navLinkToAccountManagement: some View {
        NavigationLink(destination: AccountManagementPage()) {
            Text("You are not logged in")
        }
        .tint(.red)
        .padding([.top, .horizontal])
    }
    
    private func getPostAsListRow(_ post: BlogPost) -> some View {
        let createdDate = Date(timeIntervalSince1970: post.createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: createdDate)
        
        let commentsCount = post.getChildComments(allComments: comments).count
        let countStr = if commentsCount == 1 {
            "\(commentsCount) reply"
        } else {
            "\(commentsCount) replies"
        }
        
        return VStack(alignment: .leading) {
            HStack(spacing: 3) {
                NavigationLink(destination: DisplayPostPage(post)) {
                    Text("@\(post.postedBy.username)")
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
    
    private var sectionRecentPosts: some View {
        VStack {
            if posts.isEmpty {
                Text("There are no recent posts")
            } else {
                List {
                    ForEach(posts) { post in
                        getPostAsListRow(post)
                    }
                }
            }
        }
    }
}

#Preview {
    HomePage()
        .environmentObject(UserAccountManager())
}
