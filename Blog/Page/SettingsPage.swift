import SwiftUI
import SwiftData

struct SettingsPage: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Query
    private var posts: [Post]
    @Query
    private var comments: [PostComment]
    @Query
    private var users: [UserAccount]
    
    @State
    private var isPresentingConfirmResetComments = false
    @State
    private var isPresentingConfirmResetPosts = false
    @State
    private var isPresentingConfirmResetUsers = false
    
    private var buttonResetComments: some View {
        func onPress() {
            isPresentingConfirmResetComments = true
        }
        
        func onConfirm() {
            for comment in comments {
                modelContext.delete(comment)
            }
            try? modelContext.save()
        }
        
        let count = comments.count
        
        return Button("Reset Replies (\(count))", systemImage: "eraser") {
            onPress()
        }
        .foregroundStyle(.red)
        .confirmationDialog("Erase \(count) replies? (Cannot be undone)", isPresented: $isPresentingConfirmResetComments) {
            Button("Confirm", role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private var buttonResetPosts: some View {
        func onPress() {
            isPresentingConfirmResetPosts = true
        }
        
        func onConfirm() {
            for post in posts {
                modelContext.delete(post)
            }
            try? modelContext.save()
        }
        
        let count = posts.count
        
        return Button("Reset Posts (\(count))", systemImage: "eraser") {
            onPress()
        }
        .foregroundStyle(.red)
        .confirmationDialog("Erase \(count) posts? (Cannot be undone)", isPresented: $isPresentingConfirmResetPosts) {
            Button("Confirm", role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private var buttonResetUsers: some View {
        func onPress() {
            isPresentingConfirmResetUsers = true
        }
        
        func onConfirm() {
            for account in users {
                modelContext.delete(account)
            }
            try? modelContext.save()
        }
        
        let count = users.count
        
        return Button("Reset Users (\(users.count))", systemImage: "eraser") {
            onPress()
        }
        .foregroundStyle(.red)
        .confirmationDialog("Erase \(count) users? (Cannot be undone)", isPresented: $isPresentingConfirmResetUsers) {
            Button("Confirm", role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private func randomMockUsername() -> String {
        let firstNames = ["George", "James", "Bill", "Jimmy", "Richard", "John", "Dwight", "Harry", "Franklin", "Calvin"]
        var name = firstNames.randomElement() ?? "George"
        
        for _ in 1...4 {
            let random = Int.random(in: 0...9)
            name += "\(random)"
        }
        
        return name
    }
    
    private var buttonCreateMockUsers: some View {
        func onPress() {
            for _ in 1...3 {
                let randomName = randomMockUsername()
                let new = UserAccount(username: randomName, password: "Password")
                modelContext.insert(new)
            }
            try? modelContext.save()
        }
        
        return Button("Create Mock Users", systemImage: "list.bullet") {
            onPress()
        }
        .foregroundStyle(.blue)
        .tint(.blue)
    }
    
    var body: some View {
        NavigationStack {
            layerForeground
                .navigationTitle("Settings")
        }
    }
    
    private var layerForeground: some View {
        let permissionLevel = accountManager.loggedInUser?.permissionLevel ?? 0
        
        return VStack(alignment: .leading) {
            if users.isEmpty {
                Text("No registered users")
            } else if !accountManager.isLoggedIn {
                Text("You are not logged in")
            } else {
                List {
                    // TODO User settings
                    Section("User Settings") {
                        Text("Options")
                        Text("Go here")
                    }
                    
                    if permissionLevel >= 3 {
                        sectionRegisteredUsers
                        sectionDeveloperControls
                    }
                }
            }
        }
    }
    
    private var sectionRegisteredUsers: some View {
        Section("Registered Users (\(users.count))") {
            ForEach(users) { user in
                NavigationLink(destination: UserProfileAsAdminView(user)) {
                    Text("@\(user.username)")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var sectionDeveloperControls: some View {
        Section("Developer Controls") {
            ScrollView(.horizontal) {
                HStack {
                    buttonResetUsers
                    buttonCreateMockUsers
                }
            }
            
            ScrollView(.horizontal) {
                HStack {
                    buttonResetPosts
                }
            }
            
            ScrollView(.horizontal) {
                HStack {
                    buttonResetComments
                }
            }
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .listStyle(.plain)
    }
}

#Preview {
    SettingsPage()
        .environmentObject(UserAccountManager())
}
