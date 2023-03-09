import Foundation

public final class FileResourceToken: Sendable {
    
    internal let id: String
    
    public let observer: DirectoryResourceObserver
    
    internal init(id: String, observer: DirectoryResourceObserver) {
        self.id = id
        self.observer = observer
    }
}
