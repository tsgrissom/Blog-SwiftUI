import Foundation
import Combine

final class SettingsManager: ObservableObject {
    
    private enum Keys {
        // Behavior
        static let autoLikeOwnPosts = "BehaviorAutoLikeOwnPosts"
    }
    
    private let cancellable: Cancellable
    private let defaults: UserDefaults
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        defaults.register(defaults: [
            // Behavior
            Keys.autoLikeOwnPosts: false
        ])
        
        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }
    
    var shouldAutoLikeOwnPosts: Bool {
        set { defaults.set(newValue, forKey: Keys.autoLikeOwnPosts) }
        get { defaults.bool(forKey: Keys.autoLikeOwnPosts) }
    }
}
