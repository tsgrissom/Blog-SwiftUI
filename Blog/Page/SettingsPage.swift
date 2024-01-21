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
}

extension SettingsPage {
    
    // MARK: Button Views
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
        .confirmationDialog("Erase \(count) replies? (Cannot be undone)", isPresented: $isPresentingConfirmResetComments, titleVisibility: .visible) {
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
        .confirmationDialog("Erase \(count) posts? (Cannot be undone)", isPresented: $isPresentingConfirmResetPosts, titleVisibility: .visible) {
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
        .confirmationDialog("Erase \(count) users? (Cannot be undone)", isPresented: $isPresentingConfirmResetUsers, titleVisibility: .visible) {
            Button("Confirm", role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private func randomUsername() -> String {
        var name = LoremSwiftum.Lorem.firstName
        
        for _ in 1...4 {
            let random = Int.random(in: 0...9)
            name += "\(random)"
        }
        
        return name
    }
    
    private var buttonCreateMockUsers: some View {
        func onPress() {
            isPresentingConfirmCreateMockUsers = true
        }
        
        func onConfirm() {
            for _ in 1...3 {
                let randomName = randomUsername()
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
        .confirmationDialog("Create three mock users?", isPresented: $isPresentingConfirmCreateMockUsers, titleVisibility: .visible) {
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
        .confirmationDialog("Log out of your account? (\(username))", isPresented: $isPresentingConfirmLogOut, titleVisibility: .visible) {
            Button("Confirm", role: .destructive, action: onConfirm)
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
        
        @ViewBuilder
        var tag: some View {
            if thisUser != nil {
                if thisUser!.id == user.id {
                    Text("(You)")
                }
            }
            
            EmptyView()
        }
        
        return NavigationLink(destination: DisplayUserAsAdminPage(user)) {
            HStack(spacing: 3) {
                Text("@\(user.username)")
                    .foregroundStyle(.blue)
                tag
            }
        }
        .tint(.primary)
    }
    
    private var sectionRegisteredUsers: some View {
        Section("Registered Users (\(users.count))") {
            ForEach(users) { user in
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

// MARK: Previews
#Preview {
    SettingsPage()
        .environmentObject(UserAccountManager())
}
