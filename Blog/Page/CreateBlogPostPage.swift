import SwiftUI
import SwiftData

struct CreateBlogPostPage: View {
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @State
    private var alertBoxDisplay = false
    @State
    private var alertBoxBgColor = Color.red
    @State
    private var alertBoxText = "Not prepared for submission"
    
    @State
    private var fieldBodyContents = ""
    
    private func flashAlert(
        text: String,
        bgColor: Color = .red
    ) {
        alertBoxBgColor = bgColor
        alertBoxText = text
        alertBoxDisplay = true
    }
    
    private func onPressSubmit() {
        let trimmedBody = fieldBodyContents.trimmed
        
        if trimmedBody.isEmpty {
            flashAlert(text: "Your new post cannot be empty")
            return
        }
        
        if accountManager.loggedInUser == nil {
            flashAlert(text: "You must be logged in to post")
            // TODO Alert
            return
        }
        
        let newPost = BlogPost(body: trimmedBody, postedBy: accountManager.loggedInUser!)
        modelContext.insert(newPost)
        
        flashAlert(text: "Your new post has been submitted", bgColor: .green)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                if alertBoxDisplay {
                    sectionAlertBox
                        .padding(.horizontal)
                }
                
                if accountManager.isLoggedIn {
                    sectionCreateNewPost
                        .padding(.horizontal)
                } else {
                    sectionNotLoggedIn
                }
            }
            .navigationTitle("New Post")
        }
    }
    
    private var sectionAlertBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(alertBoxBgColor)
                .frame(minHeight: 35)
            VStack(alignment: .leading, spacing: 1) {
                Text(alertBoxText)
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
    
    private var sectionCreateNewPost: some View {
        VStack {
            TextField(text: $fieldBodyContents, prompt: Text("Enter the body of your new post...")) {
                Text("Enter the body of your new post")
            }
            .textFieldStyle(.roundedBorder)
            
            HStack {
                Button(action: onPressSubmit) {
                    Text("Submit")
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                Spacer()
            }
        }
    }
    
    private var sectionNotLoggedIn: some View {
        VStack {
            Spacer()
            Text("You must be logged in to create a new post.")
                .padding(.vertical)
            NavigationLink(destination: RegisterUserAccountPage()) {
                Text("Create new account")
            }
            NavigationLink(destination: LoginUserAccountPage()) {
                Text("Log in to existing account")
            }
            Spacer()
        }
    }
}

#Preview {
    CreateBlogPostPage()
        .environmentObject(UserAccountManager())
}
