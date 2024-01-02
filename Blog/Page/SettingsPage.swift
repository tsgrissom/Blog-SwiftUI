import SwiftUI
import SwiftData

struct SettingsPage: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Query
    private var posts: [BlogPost]
    @Query
    private var comments: [BlogComment]
    @Query
    private var users: [UserAccount]
    
    private func onPressResetUsers() {
        for account in users {
            modelContext.delete(account)
        }
        try? modelContext.save()
    }
    
    private func onPressResetPosts() {
        for post in posts {
            modelContext.delete(post)
        }
        try? modelContext.save()
    }
    
    private func onPressResetComments() {
        for comment in comments {
            modelContext.delete(comment)
        }
        try? modelContext.save()
    }
    
    var body: some View {
        NavigationStack {
            layerForeground
                .navigationTitle("Settings")
        }
    }
    
    private func getViewForRegisteredUser(_ user: UserAccount) -> some View {
        let createdDate = Date(timeIntervalSince1970: user.createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: createdDate)
        
        let associatedPosts = user.getAssociatedPosts(allPosts: posts)
        let associatedComments = user.getAssociatedComments(allComments: comments)
        
        return HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text("Username: \(user.username)")
                Text("Joined: \(createdFmt)")
                Text("Posts made: \(associatedPosts.count)")
                Text("Comments made: \(associatedComments.count)")
            }
            Spacer()
        }
    }
    
    private var layerForeground: some View {
        VStack(alignment: .leading) {
            if users.isEmpty {
                Text("No registered users")
            } else {
                List {
                    Section("Registered Users (\(users.count))") {
                        ForEach(users) { user in
                            getViewForRegisteredUser(user)
                        }
                    }
                    Section("Developer Controls") {
                        HStack {
                            Button("Reset Users (\(users.count))", systemImage: "eraser") {
                                onPressResetUsers()
                            }
                            .foregroundStyle(.red)
                        }
                        HStack {
                            Button("Reset Posts (\(posts.count))", systemImage: "eraser") {
                                onPressResetPosts()
                            }
                            .foregroundStyle(.red)
                        }
                        HStack {
                            Button("Reset Replies (\(comments.count))", systemImage: "eraser") {
                                onPressResetComments()
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .listStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    SettingsPage()
        .environmentObject(UserAccountManager())
}
