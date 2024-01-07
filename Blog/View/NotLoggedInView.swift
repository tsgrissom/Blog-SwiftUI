import SwiftUI

struct NotLoggedInView: View {
    
    private let withText: Bool
    private let verticalNavLinks: Bool
    
    init(withText: Bool = true, verticalNavLinks: Bool = false) {
        self.withText = withText
        self.verticalNavLinks = verticalNavLinks
    }
    
    public var body: some View {
        VStack {
            if withText {
                Text("You are not logged in")
            }
            
            sectionNavLinks
                .buttonStyle(.bordered)
        }
    }
    
    private var navLinkRegister: some View {
        NavigationLink(destination: CreateAccountPage()) {
            Text("Register")
        }
    }
    
    private var navLinkLogin: some View {
        NavigationLink(destination: LoginAccountPage()) {
            Text("Log In")
        }
    }
    
    @ViewBuilder
    private var sectionNavLinks: some View {
        if verticalNavLinks {
            VStack {
                navLinkRegister
                navLinkLogin
            }
        } else {
            HStack {
                navLinkRegister
                navLinkLogin
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            Text("Vertical Buttons w/ Text")
                .font(.title3)
                .bold()
            Divider()
                .frame(width: 250)
            NotLoggedInView(withText: true, verticalNavLinks: true)
            
            Text("Vertical Buttons w/o Text")
                .font(.title3)
                .bold()
            Divider()
                .frame(width: 250)
            NotLoggedInView(withText: false, verticalNavLinks: true)
            
            Text("Horizontal Buttons w/ Text")
                .font(.title3)
                .bold()
            Divider()
                .frame(width: 250)
            NotLoggedInView(withText: true, verticalNavLinks: false)
            
            Text("Vertical Buttons w/o Text")
                .font(.title3)
                .bold()
            Divider()
                .frame(width: 250)
            NotLoggedInView(withText: false, verticalNavLinks: false)
        }
    }
}
