import LoremSwiftum
import SwiftUI
import SwiftData

struct DisplayUserProfilePage: View {
    
    // MARK: Environment
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Environment(\.colorScheme)
    private var systemColorScheme
    
    // MARK: SwiftData Queries
    @Query(sort: \Post.createdAt, order: .reverse)
    private var posts: [Post]
    @Query
    private var comments: [PostComment]
    
    // MARK: Initialization
    private let user: UserAccount
    
    init(_ user: UserAccount) {
        self.user = user
    }
    
    // MARK: Helpers
    private var isOwnAccount: Bool {
        user.id == accountManager.loggedInUser?.id
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        GeometryReader { metrics in
            ZStack {
                ZStack {
                    layerPageBackground
                    FollowerCountView(user: user, followers: 0, following: 0)
                        .offset(x: 75, y: -(metrics.size.height*0.56))
                }
                
                ScrollView {
                    ZStack {
                        layerCardBackground
                        layerCardForeground
                            .padding(.top)
                    }
                }
            }
        }
        .navigationTitle("Profile")
    }
    
    // MARK: Layer Views
    private var layerPageBackground: some View {
        let systemPageBackground = systemColorScheme == .dark ? Color.black : Color.white
        return VStack(spacing: 0) {
            Color.blue.ignoresSafeArea()
            systemPageBackground.ignoresSafeArea()
        }
    }
    
    private var layerCardBackground: some View {
        let bgColor = systemColorScheme == .dark ? Color.black : Color.white
        return bgColor.ignoresSafeArea(edges: [.horizontal, .bottom])
            .frame(height: 1000)
    }
    
    private var layerCardForeground: some View {
        VStack {
            UserProfileHeaderView(user)
                .padding(.horizontal)
            sectionControls
                .padding(.top)
                .padding(.horizontal)
            
            listRecentPosts
            
            Spacer()
        }
    }
}

// MARK: Smaller Views
extension DisplayUserProfilePage {
    
    private var listRecentPosts: some View {
        let recentPosts = user.getAllPosts(allPosts: posts)
        
        return List {
            ForEach(recentPosts) { post in
                NavigationLink(destination: DisplayPostPage(post)) {
                    PostPreviewView(post)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var sectionControls: some View {
        HStack {
            Spacer()
            
            if isOwnAccount {
                Button("Logout") {
                    accountManager.clearUserForSession()
                }
            }
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
            }
            
        }
        .buttonStyle(.bordered)
    }
}

// MARK: Previews
#Preview {
    let biography = LoremSwiftum.Lorem.shortTweet
    let mockUser = MockupUtilities.getMockUser()
    mockUser.biography = biography
    
    return NavigationStack {
        DisplayUserProfilePage(mockUser)
    }
    .environmentObject(UserAccountManager())
}
