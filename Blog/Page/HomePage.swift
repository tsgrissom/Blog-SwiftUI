import SwiftUI
import SwiftData

struct HomePage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Query
    private var blogPosts: [BlogPost]
    
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
                    Text("Welcome, \(accountManager.loggedInUsernameOrNone)")
                    .padding(.horizontal)
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
        .padding(.top)
    }
    
    private var sectionRecentPosts: some View {
        VStack {
            if blogPosts.isEmpty {
                Text("There are no recent posts")
            } else {
                List {
                    ForEach(blogPosts) { post in
                        VStack(alignment: .leading) {
                            HStack(spacing: 3) {
                                Text("from")
                                NavigationLink(destination: Text("User profile")) {
                                    Text("@\(post.postedBy.username)")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .font(.caption)
                            
                            Text(post.body)
                        }
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
