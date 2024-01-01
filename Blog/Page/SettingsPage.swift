import SwiftUI
import SwiftData

struct SettingsPage: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Query
    private var blogPosts: [BlogPost]
    @Query
    private var userAccounts: [UserAccount]
    
    private func onPressResetUsers() {
        for account in userAccounts {
            modelContext.delete(account)
        }
        try? modelContext.save()
    }
    
    private func onPressResetPosts() {
        for post in blogPosts {
            modelContext.delete(post)
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
        VStack {
            HStack {
                Button("Reset Users") {
                    onPressResetUsers()
                }
                Button("Reset Posts") {
                    onPressResetPosts()
                }
                Spacer()
            }
            .padding(.horizontal)
            .buttonStyle(.bordered)
            .tint(.red)
            
            if userAccounts.isEmpty {
                Text("No registered users")
            } else {
                List {
                    Section("Registered Users (\(userAccounts.count))") {
                        ForEach(userAccounts) { account in
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Username: \(account.username)")
                                Text("Password: \(account.password)")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsPage()
        .environmentObject(UserAccountManager())
}
