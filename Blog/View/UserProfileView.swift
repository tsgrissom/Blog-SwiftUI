import SwiftUI

struct UserProfileView: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Environment(\.colorScheme)
    private var systemColorScheme
    
    private let user: UserAccount
    
    init(user: UserAccount) {
        self.user = user
    }
    
    private var isOwnAccount: Bool {
        user.id == accountManager.loggedInUser?.id
    }
    
    private func onPressEditButton() {
        
    }
    
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    FollowerCountView(followers: 0, following: 0)
                        .offset(x: 90, y: -(metrics.size.height*0.55))
                }
                
                ScrollView {
                    ZStack {
                        layerCardBackground
                        layerCardForeground
                            .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Profile")
    }
    
    private var layerCardBackground: some View {
        let bgColor = systemColorScheme == .dark ? Color.black : Color.white
        return bgColor.ignoresSafeArea(edges: [.horizontal, .bottom])
            .frame(height: 1000)
    }
    
    private var layerCardForeground: some View {
        VStack {
            sectionHeader
                .padding(.top)
            Spacer()
        }
    }
    
    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack {
                Text(user.displayName)
                    .font(.title)
                    .bold()
                Text("@\(user.username)")
                    .font(.title2)
            }
            
            HStack {
                userBiography
                Spacer()
            }
            
            sectionControls
                .padding(.top)
        }
    }
    
    private var sectionControls: some View {
        HStack {
            Spacer()
            
            if isOwnAccount {
                Button("Logout") {
                    accountManager.clearUserForSession()
                }
                Button("Edit") {
                    onPressEditButton()
                }
            }
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
            }
            
        }
        .buttonStyle(.bordered)
    }
    
    @ViewBuilder
    private var userBiography: some View {
        let biography = user.biography
        
        if biography.isEmpty {
            Text("This user has not set a biography.")
                .italic()
        } else {
            Text(biography)
        }
    }
}

private var mockUser: UserAccount {
    let user = UserAccount(
        username: "Tyler",
        password: "Password",
        biography: "Lorem ipsum dolor. This is a dummy profile page of which you are reading the bio."
    )
    user.displayName = "A Display Name"
    return user
}

#Preview {
    NavigationStack {
        UserProfileView(user: mockUser)
    }
    .environmentObject(UserAccountManager())
}
