import LoremSwiftum
import SwiftUI

struct UserProfileHeaderView: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    private let user: UserAccount
    
    init(_ user: UserAccount) {
        self.user = user
    }
    
    
    @State
    private var isPresentingConfirmModifyUsername = false
    @State
    private var isPresentingModifyBiographySheet = false
    @State
    private var isPresentingModifyDisplayNameSheet = false
    @State
    private var isPresentingModifyUsernameSheet = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(user.displayName)
                .font(.title)
                .bold()
                .onTapGesture {
                    isPresentingModifyDisplayNameSheet.toggle()
                }
                .sheet(isPresented: $isPresentingModifyDisplayNameSheet, content: {
                    UserModifyProfileFieldView(mode: .displayName)
                })
            Text("@\(user.username)")
                .font(.title3)
                .onTapGesture {
                    isPresentingConfirmModifyUsername.toggle()
                }
                .confirmationDialog("Are you sure you want to change your username? (@username)", isPresented: $isPresentingConfirmModifyUsername, titleVisibility: .visible) {
                    Button(role: .destructive, action: {
                        isPresentingConfirmModifyUsername = false
                        isPresentingModifyUsernameSheet = true
                    }) {
                        Text("Proceed")
                    }
                    Button(role: .cancel, action: {}) {
                        Text("Cancel")
                    }
                }
                .sheet(isPresented: $isPresentingModifyUsernameSheet, content: {
                    UserModifyProfileFieldView(mode: .username)
                })
            
            HStack {
                textBiography
                    .onTapGesture {
                        isPresentingModifyBiographySheet.toggle()
                    }
                    .sheet(isPresented: $isPresentingModifyBiographySheet, content: {
                        UserModifyProfileFieldView(mode: .biography)
                    })
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var textBiography: some View {
        if user.biography.isEmpty {
            Text("This user has not set a biography.")
                .italic()
        } else {
            Text(user.biography)
        }
    }
}

#Preview {
    func generateViewForMockUser() -> some View {
        let firstName = LoremSwiftum.Lorem.firstName
        let lastName  = LoremSwiftum.Lorem.lastName
        let bio = LoremSwiftum.Lorem.shortTweet
        
        let user = UserAccount(username: firstName, password: "Password")
        user.displayName = "\(firstName)\(lastName)"
        user.biography = Bool.random() ? bio : ""
        
        return UserProfileHeaderView(user)
    }
    
    return ScrollView {
        VStack {
            ForEach(1...10, id: \.self) { _ in
                generateViewForMockUser()
            }
        }
        .padding(.horizontal)
    }
    .environmentObject(UserAccountManager())
}
