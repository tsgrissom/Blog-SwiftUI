import SwiftUI
import SwiftData

struct CreatePostView: View {
    
    // MARK: Environment
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: Alert State
    @State
    private var alertVisible = false
    @State
    private var alertColor = Color.red
    @State
    private var alertDebounce = false
    @State
    private var alertText = "Not prepared for submission"
    
    // MARK: Button State
    @State
    private var buttonSubmitAnimate = 0
    
    // MARK: Text Field State
    @State
    private var fieldContents = ""
    @FocusState
    private var fieldIsFocused: Bool
    
    // MARK: Helper Functions
    private func flashAlert(
        _ text: String,
        color: Color = .red
    ) {
        // TODO Haptics
        if alertDebounce {
            return
        }
        
        alertDebounce = true
        alertText = text
        alertColor = color
        withAnimation {
            alertVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                alertVisible = false
            }
            alertText = "Alert Box"
            alertColor = .red
            alertDebounce = false
        }
    }
    
    // MARK: Button Handlers
    private func onPressSubmit() {
        let trimmedBody = fieldContents.trimmed
        
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
        
        let new = Post(body: trimmedBody, postedBy: accountManager.loggedInUser!)
        modelContext.insert(new)
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        flashAlert("Your new post has been submitted", color: .green)
        buttonSubmitAnimate = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            buttonSubmitAnimate = 0
            dismiss()
        }
    }
    
    private func onPressErase() {
        if fieldContents.isEmpty {
            flashAlert("You must enter something to erase")
            return
        }
        
        fieldContents = ""
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        NavigationStack {
            VStack {
                if accountManager.isNotLoggedIn {
                    AccountNotLoggedInView()
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
                
                if alertVisible { // Alert box
                    sectionAlert
                        .transition(.scale)
                        .padding(.top, 8)
                        .onTapGesture {
                            withAnimation {
                                alertVisible = false
                            }
                        }
                }
                
                Spacer()
            }
            .navigationTitle("New Post")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    fieldIsFocused = true
                }
            }
        }
    }
}

// MARK: Views
extension CreatePostView {
    
    // MARK: Buttons
    private var buttonSubmit: some View {
        let stateColor: Color = switch buttonSubmitAnimate {
        case 1: .red
        case 2: .green
        default: .blue
        }
        let color: Color = fieldContents.isEmpty ? .gray : stateColor
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
        .tint(fieldContents.isEmpty ? .gray : .red)
    }
    
    // MARK: Text Fields
    private var fieldPostBody: some View {
        return TextField(text: $fieldContents, prompt: Text("Enter the body of your new post...")) {
            Text("Enter the body of your new post")
        }
        .focused($fieldIsFocused)
    }
    
    // MARK: Sections
    private var sectionAlert: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(alertColor)
                .frame(minHeight: 35, maxHeight: 55)
                .padding(.horizontal)
            VStack {
                Text(alertText)
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: Previews
#Preview("CreateBlogPostPage") {
    CreatePostView()
        .environmentObject(UserAccountManager())
}
