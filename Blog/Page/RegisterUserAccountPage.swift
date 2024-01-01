import SwiftUI
import SwiftData

struct RegisterUserAccountPage: View {
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Query
    private let userAccounts: [UserAccount]
    
    @State
    private var alertBoxDisplay = false
    @State
    private var alertBoxDisplayUsernameText = false
    @State
    private var alertBoxDisplayPasswordText = false
    @State
    private var alertBoxDisplayConfirmPasswordText = false
    @State
    private var alertBoxBgColor = Color.red
    @State
    private var alertBoxText = "Not prepared for submission"
    
    @State
    private var fieldUsernameContents = ""
    @State
    private var fieldPasswordContents = ""
    @State
    private var fieldConfirmPasswordContents = ""
    
    private var isFormPreparedForSubmission: Bool {
        fieldUsernameContents.trimmed.isNotEmpty && fieldPasswordContents.trimmed.isNotEmpty && fieldConfirmPasswordContents.trimmed.isNotEmpty
    }
    
    private func flashAlert(text: String, bgColor: Color = .red) {
        alertBoxBgColor = bgColor
        alertBoxText = text
        alertBoxDisplay = true
    }
    
    private func onPressSubmit() {
        alertBoxDisplayUsernameText = fieldUsernameContents.trimmed.isEmpty
        alertBoxDisplayPasswordText = fieldPasswordContents.trimmed.isEmpty
        alertBoxDisplayConfirmPasswordText = fieldConfirmPasswordContents.trimmed.isEmpty
        
        if !isFormPreparedForSubmission {
            if !alertBoxDisplay {
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
        
        let fetchAccount = userAccounts.first(where: { acc in
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
        
        let newAccount = UserAccount(username: fieldUsernameContents, password: fieldPasswordContents)
        modelContext.insert(newAccount)
        try? modelContext.save()
        
        accountManager.setUserForSession(newAccount)
        
        flashAlert(text: "Registered account for user \"\(fieldUsernameContents)\"", bgColor: .green)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    private var fieldUsername: some View {
        TextField(text: $fieldUsernameContents, prompt: Text("Username")) {
            Text("Enter your username")
        }
    }
    
    private var fieldPassword: some View {
        TextField(text: $fieldPasswordContents, prompt: Text("Password")) {
            Text("Enter your password")
        }
    }
    
    private var fieldConfirmPassword: some View {
        TextField(text: $fieldConfirmPasswordContents, prompt: Text("Re-enter password")) {
            Text("Re-enter your password")
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if alertBoxDisplay {
                        sectionAlertBox
                    }
                    
                    fieldUsername
                    fieldPassword
                    fieldConfirmPassword
                    
                    rowFormControls
                    
                    Spacer()
                }
                .padding()
            }
            .textFieldStyle(.roundedBorder)
            .navigationTitle("Register Account")
        }
    }
    
    private var rowFormControls: some View {
        let tintColor = isFormPreparedForSubmission ? Color.green : Color.gray
        return HStack {
            Button("Submit") {
                onPressSubmit()
            }
            .buttonStyle(.bordered)
            .tint(tintColor)
            
            NavigationLink(destination: LoginUserAccountPage()) {
                Text("Already have an account?")
            }
            
            Spacer()
        }
    }
    
    private var sectionAlertBox: some View {
        return ZStack {
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
                if alertBoxDisplayConfirmPasswordText {
                    Text("• Fill in the password confirmation field")
                }
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
}

#Preview {
    RegisterUserAccountPage()
        .environmentObject(UserAccountManager())
}
