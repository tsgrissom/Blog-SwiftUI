import SwiftUI
import SwiftData

@main
struct BlogApp: App {
    
    @StateObject
    private var settings = SettingsManager()
    @StateObject
    private var accounts = UserAccountManager()
    @StateObject
    private var posts = PostManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserAccount.self,
            Post.self,
            PostComment.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(accounts)
        .environmentObject(posts)
        .environmentObject(settings)
    }
}
