import LoremSwiftum
import SwiftUI
import SwiftData

struct SettingsPage: View {
    
    // MARK: Environment
    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.dismiss)
    private var dismiss
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: SwiftData Queries
    @Query
    private var posts: [Post]
    @Query
    private var comments: [PostComment]
    @Query
    private var users: [UserAccount]
    @Query(sort: \UserAccount.permissionLevel, order: .reverse)
    private var usersByPermissionLevel: [UserAccount]
    
    // MARK: Confirmation Dialog State
    @State
    private var isPresentingConfirmResetComments = false
    @State
    private var isPresentingConfirmResetPosts = false
    @State
    private var isPresentingConfirmResetUsers = false
    @State
    private var isPresentingConfirmCreateMockUsers = false
    @State
    private var isPresentingConfirmLogOut = false
    
    // MARK: Sheet State
    @State
    private var isPresentingModifyBiographySheet = false
    @State
    private var isPresentingModifyDisplayNameSheet = false
    @State
    private var isPresentingModifyUsernameSheet = false
    
    // MARK: Helper Functions
    private func resetPosts() {
        for post in posts {
            modelContext.delete(post)
        }
        for comment in comments {
            modelContext.delete(comment)
        }
        try? modelContext.save()
    }
    
    private func resetUsers() {
        for user in users {
            modelContext.delete(user)
        }
        for post in posts {
            modelContext.delete(post)
        }
        for comment in comments {
            modelContext.delete(comment)
        }
        try? modelContext.save()
        
        
        accountManager.loggedInUser = nil
    }
    
    private func resetComments() {
        for comment in comments {
            modelContext.delete(comment)
        }
        try? modelContext.save()
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        return NavigationStack {
            layerForeground
                .navigationTitle("Settings")
        }
    }
    
    private var layerForeground: some View {
        return VStack(alignment: .leading) {
            if users.isEmpty {
                Text("No registered users")
            } else if !accountManager.isLoggedIn {
                AccountNotLoggedInView(verticalNavLinks: true)
            } else {
                sectionUserSettings
            }
        }
    }
    
    private var sectionRegisteredUsers: some View {
        Section("Registered Users (\(users.count))") {
            ForEach(usersByPermissionLevel) { user in
                getViewForRegisteredUser(user)
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

extension SettingsPage {
    
    // MARK: Button Views
    private var buttonResetComments: some View {
        return Button(
            "Reset Replies (\(comments.count))",
            systemImage: "eraser",
            action: {
                isPresentingConfirmResetComments = true
            }
        )
        .foregroundStyle(.red)
        .confirmationDialog(
            "Erase \(comments.count) replies? (Cannot be undone)",
            isPresented: $isPresentingConfirmResetComments,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive, action: resetComments)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private var buttonResetPosts: some View {
        return Button(
            "Reset Posts (\(posts.count))",
            systemImage: "eraser",
            action: {
                isPresentingConfirmResetPosts = true
            }
        )
        .foregroundStyle(.red)
        .confirmationDialog(
            "Erase \(posts.count) posts? (Cannot be undone)",
            isPresented: $isPresentingConfirmResetPosts,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive, action: resetPosts)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private var buttonResetUsers: some View {
        return Button(
            "Reset Users (\(users.count))",
            systemImage: "eraser",
            action: {
                isPresentingConfirmResetUsers = true
            }
        )
        .foregroundStyle(.red)
        .confirmationDialog(
            "Erase \(users.count) users? (Cannot be undone)",
            isPresented: $isPresentingConfirmResetUsers,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive, action: resetUsers)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private var buttonCreateMockUsers: some View {
        func getRandomUsername() -> String {
            var name = LoremSwiftum.Lorem.firstName
            
            if Bool.random() {
                for _ in 1...4 {
                    let random = Int.random(in: 0...9)
                    name += "\(random)"
                }
            }
            
            return name
        }
        
        func onPress() {
            isPresentingConfirmCreateMockUsers = true
        }
        
        func onConfirm() {
            for _ in 1...3 {
                let new = UserAccount(
                    username: getRandomUsername(),
                    password: "Password"
                )
                modelContext.insert(new)
            }
            try? modelContext.save()
        }
        
        return Button("Create Mock Users", systemImage: "list.bullet") {
            onPress()
        }
        .foregroundStyle(.blue)
        .tint(.blue)
        .confirmationDialog(
            "Create three mock users?",
            isPresented: $isPresentingConfirmCreateMockUsers,
            titleVisibility: .visible
        ) {
            Button("Confirm", role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private var buttonLogOut: some View {
        func onPress() {
            isPresentingConfirmLogOut = true
        }
        
        func onConfirm() {
            accountManager.loggedInUser = nil
            dismiss()
        }
        
        let username = accountManager.loggedInUser.getUsername()
        
        return Button(action: onPress) {
            Text("Log Out")
        }
        .tint(.red)
        .confirmationDialog(
            "Log out of your account? (\(username))",
            isPresented: $isPresentingConfirmLogOut,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    // MARK: Section Views
    @ViewBuilder
    private var sectionUserSettings: some View {
        let user = accountManager.loggedInUser
        
        if user == nil {
            EmptyView()
        } else {
            let displayName = user!.displayName
            let username = user!.username
            let permissionLevel = user!.permissionLevel
            
            List {
                // TODO User settings
                Section("User Settings") {
                    Button(action: {
                        isPresentingModifyUsernameSheet.toggle()
                    }) {
                        Text("Username: \(username)")
                    }
                    .foregroundStyle(.primary)
                    .sheet(isPresented: $isPresentingModifyUsernameSheet, content: {
                        UserModifyProfileFieldView(mode: .username)
                    })
                    
                    Button(action: {
                        isPresentingModifyDisplayNameSheet.toggle()
                    }) {
                        Text("Display Name: \(displayName)")
                    }
                    .foregroundStyle(.primary)
                    .sheet(isPresented: $isPresentingModifyDisplayNameSheet, content: {
                        UserModifyProfileFieldView(mode: .displayName)
                    })
                    
                    Button(action: {
                        isPresentingModifyBiographySheet.toggle()
                    }) {
                        Text("User Biography")
                    }
                    .foregroundStyle(.primary)
                    .sheet(isPresented: $isPresentingModifyBiographySheet, content: {
                        UserModifyProfileFieldView(mode: .biography)
                    })
                    
                    HStack {
                        buttonLogOut
                    }
                }
                
                if permissionLevel >= 3 {
                    sectionRegisteredUsers
                    sectionDeveloperControls
                }
            }
        }
    }
    
    private func getViewForRegisteredUser(_ user: UserAccount) -> some View {
        let thisUser = accountManager.loggedInUser
        
        var prefix: some View {
            Text("[\(user.permissionLevel)]")
        }
        
        @ViewBuilder
        var postfix: some View {
            if thisUser != nil {
                if thisUser!.id == user.id {
                    Text("(You)")
                }
            }
            
            EmptyView()
        }
        
        return NavigationLink(destination: DisplayUserAsAdminPage(user)) {
            HStack(spacing: 3) {
                prefix
                Text("@\(user.username)")
                    .foregroundStyle(.blue)
                postfix
            }
        }
        .tint(.primary)
    }
}

// MARK: Previews
#Preview {
    SettingsPage()
        .environmentObject(UserAccountManager())
}
