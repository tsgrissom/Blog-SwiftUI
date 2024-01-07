import LoremSwiftum
import SwiftUI

struct UserProfileHeaderView: View {
    
    private let user: UserAccount
    
    init(_ user: UserAccount) {
        self.user = user
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(user.displayName)
                .font(.title)
                .bold()
            Text("@\(user.username)")
                .font(.title3)
            
            HStack {
                if user.biography.isEmpty {
                    Text("This user has not set a biography.")
                        .italic()
                } else {
                    Text(user.biography)
                }
                
                Spacer()
            }
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
}
