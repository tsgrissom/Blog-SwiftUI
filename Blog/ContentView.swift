import SwiftUI
import SwiftData

struct ContentView: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Query
    private var users: [UserAccount]

    private func handleAutomaticLogin() {
        let savedUser = UserDefaults.standard.string(forKey: "LoggedInUser")
        if savedUser != nil {
            let fetchUser = users.first { $0.id == savedUser }
            
            if fetchUser != nil {
                accountManager.setUserForSession(fetchUser)
                print("Automatically logged in as \"\(fetchUser!.username)\"")
            }
        }
    }
    
    public var body: some View {
        TabView {
            RecentPostsFeedPage()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Home")
                }
            
            AccountManagementPage()
                .tabItem {
                    Image(systemName: "person")
                    Text("Account")
                }
            
            SettingsPage()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onAppear(perform: handleAutomaticLogin) // Auto-login logic
    }
}

#Preview {
    ContentView()
        .environmentObject(UserAccountManager())
}
