import CryptoKit
import SwiftUI
import SwiftData

struct LoginUserAccountPage: View {
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    @Query
    private var userAccounts: [UserAccount]
    
    @State
    private var alertBoxDisplay = false
    @State
    private var alertBoxDisplayUsernameText = false
    @State
    private var alertBoxDisplayPasswordText = false
    @State
    private var alertBoxBgColor = Color.red
    @State
    private var alertBoxText = "Not prepared for submission"
    
    @State
    private var fieldUsernameContents = ""
    @State
    private var fieldPasswordContents = ""
    
    private var isFormPreparedForSubmission: Bool {
        fieldUsernameContents.trimmed.isNotEmpty && fieldPasswordContents.trimmed.isNotEmpty
    }
    
    private func flashAlert(
        text: String,
        bgColor: Color = .red
    ) {
        alertBoxBgColor = bgColor
        alertBoxText = text
        alertBoxDisplay = true
    }
    
    private func onPressSubmit() {
        alertBoxDisplayUsernameText = fieldUsernameContents.trimmed.isEmpty
        alertBoxDisplayPasswordText = fieldPasswordContents.trimmed.isEmpty
        
        if !isFormPreparedForSubmission {
            if !alertBoxDisplay {
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
        
        let account = userAccounts.first { acc in
            acc.username == fieldUsernameContents
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
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    fieldUsername
                    fieldPassword
                    
                    rowFormControls
                    
                    if alertBoxDisplay {
                        sectionAlertBox
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
            Button("Submit") {
                onPressSubmit()
            }
            .buttonStyle(.bordered)
            .tint(isFormPreparedForSubmission ? .green : .gray)
            
            NavigationLink(destination: RegisterUserAccountPage()) {
                Text("Create account")
            }
            
            Spacer()
        }
    }
    
    private var sectionAlertBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(alertBoxBgColor)
                .frame(minHeight: 35)
            VStack(alignment: .leading, spacing: 1) {
                Text(alertBoxText)
                if alertBoxDisplayUsernameText {
                    Text("• Fill in the username field")
                }
                if alertBoxDisplayPasswordText {
                    Text("• Fill in the password field")
                }
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
}

#Preview {
    LoginUserAccountPage()
        .environmentObject(UserAccountManager())
}
