import Foundation

final class FileWatcherCoordinator {
    
    /// Need a more efficient way to store these values (???)
    private var strategies: [FileDescriptorEventTransformStrategy] = []
    
    private let observable: FileSystemObservable
    
    private lazy var fileWatcher = lazyFileWatcher()
    
    init(observable: FileSystemObservable) {
        self.observable = observable
    }
}

extension FileWatcherCoordinator {
    
    func start() throws {
        try fileWatcher.start()
    }
    
    func stop() {
        fileWatcher.stop()
    }
}

extension FileWatcherCoordinator: FileDescriptorEventDelegate {
    
    func didReceive(event: FileDescriptorEvent) {
        for strategy in strategies {
            strategy.perform(with: event)
        }
    }
    
    func didReceive(error: Error) {
        print("Coordinator Received the following error: \(error)")
    }
}

extension FileWatcherCoordinator {
    
    func register(_ strategy: FileDescriptorEventTransformStrategy) {
        strategies.append(strategy)
    }
    
    func unregister(_ strategy: FileDescriptorEventTransformStrategy) {
        let index = strategies.firstIndex(where: { savedStrategy in
            return savedStrategy === strategy
        })
        
        guard let index else {
            return
        }
        
        strategies.remove(at: index)
    }
}

extension FileWatcherCoordinator {
    
    private func lazyFileWatcher() -> FileWatcher {
        return FileWatcher(
            fileSystemObservable: observable,
            eventDelegate: self
        )
    }
}
