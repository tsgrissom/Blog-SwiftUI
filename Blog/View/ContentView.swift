import SwiftUI
import SwiftData

struct ContentView: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Query
    private var userAccounts: [UserAccount]

    private func handleAutomaticLogin() {
        let savedUser = UserDefaults.standard.string(forKey: "LoggedInUser") ?? "None"
        if savedUser != "None" {
            let fetchUser = userAccounts.first(where: { acc in
                acc.username == savedUser
            })
            
            if fetchUser != nil {
                accountManager.loggedInUser = fetchUser
                print("Automatically logged in as \"\(savedUser)\"")
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
