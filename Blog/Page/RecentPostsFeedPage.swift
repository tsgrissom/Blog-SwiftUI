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
    private var isPresentingSheetCreatePost = false
    
    public var body: some View {
        NavigationStack {
            VStack {
                if accountManager.loggedInUser == nil {
                    AccountNotLoggedInView()
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
                            NavigationLink(destination: DisplayPostPage(post)) {
                                PostPreviewView(post, displayUser: true)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Feed")
        }
        .sheet(isPresented: $isPresentingSheetCreatePost, content: {
            CreatePostView()
        })
    }
    
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
}

#Preview {
    RecentPostsFeedPage()
        .environmentObject(UserAccountManager())
}
