import SwiftUI

struct AccountManagementPage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    private var loggedInStatus: some View {
        let isLoggedIn = accountManager.isLoggedIn
        let username   = accountManager.loggedInUsernameOrNone
        return Text(isLoggedIn ? "Logged in as \(username)" : "Not logged in")
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    layerForeground
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Your Account")
        }
    }
    
    private var buttonLogOut: some View {
        Button("Logout") {
            accountManager.clearUserForSession()
        }
    }
    
    private var layerForeground: some View {
        VStack(alignment: .leading) {
            loggedInStatus
            if accountManager.isLoggedIn {
                buttonLogOut
            } else {
                rowNotLoggedIn
            }
        }
    }
    
    private var rowNotLoggedIn: some View {
        HStack {
            NavigationLink(destination: RegisterUserAccountPage()) {
                Text("Register")
            }
            NavigationLink(destination: LoginUserAccountPage()) {
                Text("Login")
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    AccountManagementPage()
        .environmentObject(UserAccountManager())
}
