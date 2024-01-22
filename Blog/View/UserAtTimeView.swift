import LoremSwiftum
import SwiftUI

struct UserAtTimeView: View {
    
    // MARK: Initialization
    private let user: UserAccount
    private let time: Date
    private let withProfilePicture: Bool
    private let profilePictureLength: CGFloat
    
    init(
        user: UserAccount,
        at time: Date,
        withProfilePicture: Bool = false,
        profilePictureLength: CGFloat = 20.0
    ) {
        self.user = user
        self.time = time
        self.withProfilePicture = withProfilePicture
        self.profilePictureLength = profilePictureLength
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        HStack(spacing: 3) {
            navLinkUser
            textCreatedAt
            
            Spacer()
        }
        .font(.caption)
    }
}

// MARK: Views
extension UserAtTimeView {
    
    private var navLinkUser: some View {
        HStack(spacing: 3) {
            if withProfilePicture {
                profilePicture
            } else {
                randomBlankProfilePicture
            }
            
            textUsername
        }
    }
    
    private func getBlankProfilePicture(color: Color = .accentColor) -> some View {
        return Circle()
            .fill(color.gradient)
            .frame(width: profilePictureLength, height: profilePictureLength)
    }
    
    private var randomBlankProfilePicture: some View {
        let colors: [Color] = [.blue, .green, .purple, .yellow, .orange, .cyan, .mint]
        let random = colors.randomElement() ?? .red
        return getBlankProfilePicture(color: random)
    }
    
    private var profilePicture: some View {
        let urls = ["https://xsgames.co/randomusers/avatar.php?g=male", "https://xsgames.co/randomusers/avatar.php?g=female"]
        let url = URL(string: urls.randomElement() ?? urls[0])
        return AsyncImage(url: url, scale: 10.0)
            .frame(width: profilePictureLength, height: profilePictureLength)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
    }
    
    private var textUsername: some View {
        return Text("@\(user.username)")
            .foregroundStyle(Color.accentColor)
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    private var textCreatedAt: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: time)
        
        return Text("at \(createdFmt)")
    }
}

// MARK: Previews
#Preview {
    func generateViewForMockUser() -> some View {
        let now = Date()
        let mockUser = MockupUtilities.getMockUser()
        
        return UserAtTimeView(user: mockUser, at: now, withProfilePicture: Bool.random())
    }
    
    return NavigationStack {
        VStack {
            ForEach(1...10, id: \.self) { _ in
                generateViewForMockUser()
            }
        }
    }
}
