import Foundation

extension String {
    
    public var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var isNotEmpty: Bool {
        !self.isEmpty
    }
}
