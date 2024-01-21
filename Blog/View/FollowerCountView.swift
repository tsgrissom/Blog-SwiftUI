import LoremSwiftum
import SwiftUI

private func shortenFollowerCount(_ n: Int) -> String {
    if n <= 999 {
        return "\(n)"
    }
    
    let nd  = Double(n) / 1000.0
    let fmt = String(format: "%.1f", nd)
    return "\(fmt)K"
}

struct FollowerCountView: View {
    
    // MARK: Initialization
    private let user: UserAccount
    private let followers: Int
    private let following: Int
    
    init(user: UserAccount, followers: Int, following: Int) {
        self.user = user
        self.followers = followers
        self.following = following
    }
    
    // MARK: State
    @State
    private var isSectionLeadingPressed = false
    @State
    private var isSectionTrailingPressed = false
    
    // MARK: Layout Declaration
    public var body: some View {
        return HStack(spacing: 1) {
            sectionLeading
            sectionTrailing
        }
        .frame(minHeight: 45)
        .frame(maxWidth: 200, maxHeight: 55)
    }
}

// MARK: Views
extension FollowerCountView {
    
    // MARK: Sections
    private var sectionLeading: some View {
        return NavigationLink(destination: Text("\(user.username)'s followers page")) {
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .circular)
                    .fill(Material.ultraThin)
                VStack {
                    Text("Followers")
                        .fontWeight(.semibold)
                    Text("\(shortenFollowerCount(followers))")
                }
                .padding(.vertical, 5)
                .allowsHitTesting(false)
            }
        }
        .foregroundStyle(.primary)
    }
    
    private var sectionTrailing: some View {
        // TODO Proper navigation destination
        return NavigationLink(destination: Text("\(user.username)'s following page")) {
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 8, topTrailingRadius: 8, style: .circular)
                    .fill(Material.ultraThin)
                    .frame(minHeight: 45)
                VStack {
                    Text("Following")
                        .fontWeight(.semibold)
                    Text("\(shortenFollowerCount(following))")
                }
                .padding(.vertical, 5)
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    let mockUser = MockupUtilities.getMockUser()
    
    return NavigationStack {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack {
                    FollowerCountView(user: mockUser, followers: 100, following: 1000)
                    FollowerCountView(user: mockUser, followers: 0, following: 10)
                    FollowerCountView(user: mockUser, followers: 69555, following: 5678)
                }
            }
        }
    }
}
