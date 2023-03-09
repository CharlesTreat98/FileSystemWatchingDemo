import Foundation

protocol FileResourceRegistry {
    
    func register(_ fileResource: FileResource) -> FileResourceToken
    
    func unregister(_ token: FileResourceToken)
}

final class DefaultFileResourceRegistry: FileResourceRegistry {
    
    private var cache: [FileResource: DirectoryResourceObserver] = [:]
    
    init(cache: [FileResource: DirectoryResourceObserver] = [:]) {
        self.cache = cache
    }
    
    // Not currently thread safe -- Could be protected through implementation or by usage. 
    func register(_ fileResource: FileResource) -> FileResourceToken {
        if let cachedEntry = cache[fileResource] {
            return FileResourceToken(id: UUID().uuidString, observer: cachedEntry)
        } else {
            let observer = DirectoryResourceObserver(fileResource: fileResource)
            
            cache[fileResource] = observer
            return FileResourceToken(id: UUID().uuidString, observer: observer)
        }
    }
    
    func unregister(_ token: FileResourceToken) {
        // TODO
    }
}
