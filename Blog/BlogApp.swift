import SwiftUI
import SwiftData

@main
struct BlogApp: App {
    
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
        .environmentObject(UserAccountManager())
        .environmentObject(PostManager())
    }
}
