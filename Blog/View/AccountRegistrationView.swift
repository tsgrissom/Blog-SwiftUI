import CryptoKit
import SwiftUI
import SwiftData

struct AccountRegistrationView: View {
    
    // MARK: Environment
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: SwiftData Queries
    @Query
    private let users: [UserAccount]
    
    // MARK: Alert State
    @State
    private var alertVisible = false
    @State
    private var alertDisplayUsernameText = false
    @State
    private var alertDisplayPasswordText = false
    @State
    private var alertDisplayConfirmPasswordText = false
    @State
    private var alertColor = Color.red
    @State
    private var alertText = "Not prepared for submission"
    
    // MARK: Text Field State
    @State
    private var fieldUsernameContents = ""
    @State
    private var fieldPasswordContents = ""
    @State
    private var fieldConfirmPasswordContents = ""
    
    // MARK: Helpers
    private var isFormPreparedForSubmission: Bool {
        fieldUsernameContents.trimmed.isNotEmpty &&
        fieldPasswordContents.trimmed.isNotEmpty &&
        fieldConfirmPasswordContents.trimmed.isNotEmpty
    }
    
    private func flashAlert(text: String, bgColor: Color = .red) {
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
        alertDisplayConfirmPasswordText = fieldConfirmPasswordContents.trimmed.isEmpty
        
        if !isFormPreparedForSubmission {
            if !alertVisible {
                flashAlert(text: "Please fill out all fields")
            }
            
            return
        }
        
        if fieldUsernameContents.contains(" ") {
            flashAlert(text: "Your username cannot contain spaces")
            return
        }
        
        if fieldPasswordContents.contains(" ") {
            flashAlert(text: "Your password cannot contain spaces")
            return
        }
        
        let fetchAccount = users.first(where: { acc in
            acc.username == fieldUsernameContents
        })
        
        if fetchAccount != nil {
            flashAlert(text: "User \"\(fieldUsernameContents)\" already exists")
            return
        }
        
        if fieldPasswordContents != fieldConfirmPasswordContents {
            flashAlert(text: "Your passwords do not match")
            return
        }
        
        let data = Data(fieldPasswordContents.utf8)
        let sha256 = SHA256.hash(data: data)
        let hashString = sha256.compactMap { String(format: "%02x", $0) }.joined()
        
        let permissionLevel = users.count<=0 ? 4 : 0 // If this is the first user registered, ->Superuser
        let new = UserAccount(
            username: fieldUsernameContents,
            password: hashString,
            permissionLevel: permissionLevel
        )
        modelContext.insert(new)
        try? modelContext.save()
        
        accountManager.setUserForSession(new)
        
        flashAlert(text: "Registered account for user \"\(fieldUsernameContents)\"", bgColor: .green)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            dismiss()
        }
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    fieldUsername
                    fieldPassword
                    fieldConfirmPassword
                    
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
            .navigationTitle("Register Account")
        }
    }
}

// MARK: Views
extension AccountRegistrationView {
    
    // MARK: Text Fields
    private var fieldUsername: some View {
        TextField(text: $fieldUsernameContents, prompt: Text("Username")) {
            Text("Enter your username")
        }
    }
    
    private var fieldPassword: some View {
        SecureField(text: $fieldPasswordContents, prompt: Text("Password")) {
            Text("Enter your password")
        }
    }
    
    private var fieldConfirmPassword: some View {
        SecureField(text: $fieldConfirmPasswordContents, prompt: Text("Re-enter password")) {
            Text("Re-enter your password")
        }
    }
    
    // MARK: Rows + Sections
    private var rowFormControls: some View {
        let tintColor = isFormPreparedForSubmission ? Color.green : Color.gray
        return HStack {
            Button("Submit") {
                onPressSubmit()
            }
            .buttonStyle(.bordered)
            .tint(tintColor)
            
            NavigationLink(destination: AccountLoginView()) {
                Text("Already have an account?")
            }
            
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
                    if alertDisplayConfirmPasswordText {
                        Text("• Fill in the password confirmation field")
                    }
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
}

#Preview {
    AccountRegistrationView()
        .environmentObject(UserAccountManager())
}
