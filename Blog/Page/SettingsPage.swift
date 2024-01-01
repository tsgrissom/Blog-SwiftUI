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
    
    private var layerForeground: some View {
        VStack(alignment: .leading) {
            if users.isEmpty {
                Text("No registered users")
            } else {
                List {
                    Section("Registered Users (\(users.count))") {
                        ForEach(users) { account in
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Username: \(account.username)")
                                Text("Password: \(account.password)")
                            }
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
