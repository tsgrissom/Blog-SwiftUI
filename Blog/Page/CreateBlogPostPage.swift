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
    private var alertBoxVisible = false
    @State
    private var alertBoxColor = Color.red
    @State
    private var alertBoxDebounce = false
    @State
    private var alertBoxText = "Not prepared for submission"
    
    @State
    private var buttonSubmitAnimate = 0
    
    @State
    private var fieldBodyContents = ""
    
    private func flashAlert(
        _ text: String,
        color: Color = .red
    ) {
        // TODO Haptics
        if alertBoxDebounce {
            return
        }
        
        alertBoxDebounce = true
        alertBoxText = text
        alertBoxColor = color
        withAnimation {
            alertBoxVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                alertBoxVisible = false
            }
            alertBoxText = "Alert Box"
            alertBoxColor = .red
            alertBoxDebounce = false
        }
    }
    
    // MARK: Button Handlers
    private func onPressSubmit() {
        let trimmedBody = fieldBodyContents.trimmed
        
        if trimmedBody.isEmpty {
            flashAlert("Your new post cannot be empty")
            buttonSubmitAnimate = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                buttonSubmitAnimate = 0
            }
            return
        }
        
        if accountManager.loggedInUser == nil {
            flashAlert("You must be logged in to post")
            buttonSubmitAnimate = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                buttonSubmitAnimate = 0
            }
            return
        }
        
        let newPost = Post(body: trimmedBody, postedBy: accountManager.loggedInUser!)
        modelContext.insert(newPost)
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        flashAlert("Your new post has been submitted", color: .green)
        buttonSubmitAnimate = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            buttonSubmitAnimate = 0
            dismiss()
        }
    }
    
    private func onPressErase() {
        if fieldBodyContents.isEmpty {
            flashAlert("You must enter something to erase")
            return
        }
        
        fieldBodyContents = ""
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private var buttonSubmit: some View {
        let stateColor: Color = switch buttonSubmitAnimate {
        case 1: .red
        case 2: .green
        default: .blue
        }
        let color: Color = fieldBodyContents.isEmpty ? .gray : stateColor
        let symbol = buttonSubmitAnimate==1 ? "xmark" : "checkmark"
        
        return Button(action: onPressSubmit) {
            Image(systemName: symbol)
                .imageScale(.large)
                .frame(height: 30)
        }
        .tint(color)
    }
    
    private var buttonErase: some View {
        return Button(action: onPressErase) {
            Image(systemName: "eraser")
                .imageScale(.large)
                .frame(height: 30)
        }
        .tint(fieldBodyContents.isEmpty ? .gray : .red)
    }
    
    private var fieldPostBody: some View {
        return TextField(text: $fieldBodyContents, prompt: Text("Enter the body of your new post...")) {
            Text("Enter the body of your new post")
        }
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                if accountManager.isNotLoggedIn {
                    NotLoggedInView()
                } else {
                    VStack { // Form container
                        fieldPostBody
                        
                        HStack { // Controls row container
                            buttonSubmit
                            buttonErase
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .buttonStyle(.bordered)
                    .textFieldStyle(.roundedBorder)
                }
                
                if alertBoxVisible { // Alert box
                    sectionAlertBox
                        .transition(.scale)
                        .padding(.top, 8)
                        .onTapGesture {
                            withAnimation {
                                alertBoxVisible = false
                            }
                        }
                }
                
                Spacer()
            }
            .navigationTitle("New Post")
        }
    }
    
    private var sectionAlertBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(alertBoxColor)
                .frame(minHeight: 35, maxHeight: 55)
                .padding(.horizontal)
            VStack {
                Text(alertBoxText)
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct NotLoggedInView: View {
    public var body: some View {
        VStack {
            Text("You must be logged in to create a new post.")
                .padding(.vertical)
            NavigationLink(destination: CreateAccountPage()) {
                Text("Create new account")
            }
            NavigationLink(destination: LoginAccountPage()) {
                Text("Log in to existing account")
            }
            Spacer()
        }
    }
}

#Preview("CreateBlogPostPage") {
    CreateBlogPostPage()
        .environmentObject(UserAccountManager())
}

#Preview("NotLoggedInView") {
    NotLoggedInView()
}
