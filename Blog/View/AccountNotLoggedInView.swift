import SwiftUI

struct AccountNotLoggedInView: View {

    // MARK: Initialization
    private let withText: Bool
    private let verticalNavLinks: Bool
    
    init(withText: Bool = true, verticalNavLinks: Bool = false) {
        self.withText = withText
        self.verticalNavLinks = verticalNavLinks
    }
    
    // MARK: Sheet State
    @State
    private var isPresentingRegisterSheet = false
    @State
    private var isPresentingLoginSheet = false
    
    // MARK: Layout Declarations
    public var body: some View {
        VStack {
            if withText {
                Text("You are not logged in")
            }
            
            sectionNavLinks
                .buttonStyle(.bordered)
        }
    }
}

extension AccountNotLoggedInView {
    
    // MARK: Navigation Link Views
    private var navLinkRegister: some View {
        func onPress() {
            isPresentingRegisterSheet.toggle()
        }
        
        let text = Text("Register")
        
        return Button(action: onPress) {
            if verticalNavLinks {
                text
                    .frame(width: 75)
            } else {
                text
            }
        }
        .sheet(isPresented: $isPresentingRegisterSheet) {
            AccountRegistrationView()
        }
    }
    
    private var navLinkLogin: some View {
        func onPress() {
            isPresentingLoginSheet.toggle()
        }
        
        let text = Text("Log In")
        
        return Button(action: onPress) {
            if verticalNavLinks {
                text
                    .frame(width: 75)
            } else {
                text
            }
        }
        .sheet(isPresented: $isPresentingLoginSheet) {
            AccountLoginView()
        }
    }
    
    // MARK: Section Views
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

// MARK: Previews
#Preview {
    ScrollView {
        VStack {
            Text("Vertical Buttons w/ Text")
                .font(.title3)
                .bold()
            Divider()
                .frame(width: 250)
            AccountNotLoggedInView(withText: true, verticalNavLinks: true)
            
            Text("Vertical Buttons w/o Text")
                .font(.title3)
                .bold()
            Divider()
                .frame(width: 250)
            AccountNotLoggedInView(withText: false, verticalNavLinks: true)
            
            Text("Horizontal Buttons w/ Text")
                .font(.title3)
                .bold()
            Divider()
                .frame(width: 250)
            AccountNotLoggedInView(withText: true, verticalNavLinks: false)
            
            Text("Vertical Buttons w/o Text")
                .font(.title3)
                .bold()
            Divider()
                .frame(width: 250)
            AccountNotLoggedInView(withText: false, verticalNavLinks: false)
        }
    }
}
