import Foundation

enum PermissionLevel: Int, CaseIterable {
    
    static func valueOf(_ permissionLevel: Int) -> PermissionLevel {
        return PermissionLevel(rawValue: permissionLevel) ?? .Default
    }
    
    case Default    = 0
    case Subscriber = 1
    case Moderator  = 2
    case Operator   = 3
    case Superuser  = 4
    
    public var permissionLevel: Int {
        return self.rawValue
    }
    
    func getRank() -> String {
        return switch permissionLevel {
            case 1: "Subscriber"
            case 2: "Moderator"
            case 3: "Operator"
            case 4: "Superuser"
            default: "Default"
        }
    }
    
    public func isPublic() -> Bool {
        return permissionLevel <= 1
    }
    
    public func isSubscriber() -> Bool {
        return permissionLevel >= 1
    }
    
    public func isModerator() -> Bool {
        return permissionLevel >= 2
    }
    
    public func isOperator() -> Bool {
        return permissionLevel >= 3
    }
    
    public func isSuperUser() -> Bool {
        return permissionLevel == 4
    }
    
    public func isSuperiorTo(_ that: PermissionLevel) -> Bool {
        let thisLevel = self.permissionLevel
        let thatLevel = that.permissionLevel
        
        if thisLevel == 4 {
            return true
        } else if thisLevel == 3 && thatLevel < 4 {
            return false
        }
        
        return thisLevel > thatLevel
    }
    
    public func isInferiorTo(_ that: PermissionLevel) -> Bool {
        return !self.isSuperiorTo(that)
    }
}
