import CryptoKit
import SwiftUI
import SwiftData

struct AccountLoginView: View {
    
    // MARK: Environment
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: SwiftData Queries
    @Query
    private var users: [UserAccount]
    
    // MARK: Alert State
    @State
    private var alertVisible = false
    @State
    private var alertDisplayUsernameText = false
    @State
    private var alertDisplayPasswordText = false
    @State
    private var alertColor = Color.red
    @State
    private var alertText = "Not prepared for submission"
    
    // MARK: Text Field State
    @State
    private var fieldUsernameContents = ""
    @State
    private var fieldPasswordContents = ""
    
    // MARK: Helpers
    private var isFormPreparedForSubmission: Bool {
        fieldUsernameContents.trimmed.isNotEmpty && fieldPasswordContents.trimmed.isNotEmpty
    }
    
    private func flashAlert(
        text: String,
        bgColor: Color = .red
    ) {
        alertColor = bgColor
        alertText = text
        withAnimation {
            alertVisible = true
        }
    }
    
    // MARK: Button Handlers
    private func onPressSubmit() {
        alertDisplayUsernameText = fieldUsernameContents.trimmed.isEmpty
        alertDisplayPasswordText = fieldPasswordContents.trimmed.isEmpty
        
        if !isFormPreparedForSubmission {
            if !alertVisible {
                flashAlert(text: "Please fill out all fields")
            }
            
            return
        }
        
        print("Submit login success")
        // TODO
        
        if fieldUsernameContents.contains(" ") {
            flashAlert(text: "Your username cannot contain spaces")
            return
        }
        
        if fieldPasswordContents.contains(" ") {
            flashAlert(text: "Your password cannot contain spaces")
            return
        }
        
        let account = users.first {
            $0.username == fieldUsernameContents
        }
        
        if account == nil {
            flashAlert(text: "User \"\(fieldUsernameContents)\" does not exist")
            return
        }
        
        let passwordToMatch = account?.password
        let data = Data(fieldPasswordContents.utf8)
        let sha256 = SHA256.hash(data: data)
        let hashString = sha256.compactMap { String(format: "%02x", $0) }.joined()
        
        if hashString != passwordToMatch {
            flashAlert(text: "Invalid username/password combination")
            return
        }
        
        accountManager.setUserForSession(account!)
        flashAlert(text: "Logged in as \"\(fieldUsernameContents)\"", bgColor: .green)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    fieldUsername
                    fieldPassword
                    
                    rowFormControls
                    
                    if alertVisible {
                        sectionAlertBox
                            .transition(.scale)
                            .onTapGesture {
                                withAnimation {
                                    alertVisible = false
                                }
                            }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .textFieldStyle(.roundedBorder)
            .navigationTitle("Log In")
        }
    }
    
    private var rowFormControls: some View {
        HStack {
            buttonSubmit
            navLinkRegister
            
            Spacer()
        }
    }
    
    private var sectionAlertBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(alertColor)
                .frame(minHeight: 35)
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(alertText)
                    if alertDisplayUsernameText {
                        Text("• Fill in the username field")
                    }
                    if alertDisplayPasswordText {
                        Text("• Fill in the password field")
                    }
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
}

// MARK: Views
extension AccountLoginView {
    
    private var buttonSubmit: some View {
        return Button("Submit") {
            onPressSubmit()
        }
        .buttonStyle(.bordered)
        .tint(isFormPreparedForSubmission ? .green : .gray)
    }
    
    private var navLinkRegister: some View {
        return NavigationLink(destination: AccountRegistrationView()) {
            Text("Create account")
        }
    }
    
    // MARK: Text Fields
    private var fieldUsername: some View {
        let prompt = Text("Username")
        let label  = Text("Enter your username")
        return TextField(text: $fieldUsernameContents, prompt: prompt) {
            label
        }
    }
    
    private var fieldPassword: some View {
        let prompt = Text("Password")
        let label  = Text("Enter your password")
        return SecureField(text: $fieldPasswordContents, prompt: prompt) {
            label
        }
    }
}

#Preview {
    AccountLoginView()
        .environmentObject(UserAccountManager())
}
