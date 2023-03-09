import Foundation

final class FileWatcher {
    
    fileprivate enum State {
        case inactive
        case active(DispatchSourceFileSystemObject, DispatchQueue)
    }
    
    fileprivate var state: State = .inactive
    
    private let fileSystemObservable: FileSystemObservable
    
    private var eventDelegate: FileDescriptorEventDelegate
    
    private let eventPropagator = FileSystemEventPropagator()
    
    /// `url` passed in here `must` be an existing file/directory. We validate though!
    init(fileSystemObservable: FileSystemObservable, eventDelegate: FileDescriptorEventDelegate) {
        self.fileSystemObservable = fileSystemObservable
        self.eventDelegate = eventDelegate
    }
}

extension FileWatcher {
    
    func start() throws {
        let fileDescriptor = try urlFileRepresentation()
        
        let queue = DispatchQueue(label: "fileSystemWatchingQueue")
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .all,
            queue: queue
        )
        
        source.setEventHandler(handler: { [unowned self] in
            eventPropagator.sendEvents(
                for: fileSystemObservable,
                delegate: eventDelegate,
                eventType: source.data
            )
            tellMeWhatEventJustHappened(for: source.data)
        })
        
        // Establish initial state.
        eventPropagator.sendEvents(
            for: fileSystemObservable,
            delegate: eventDelegate,
            eventType: source.data
        )
        source.resume()
        
        
        state = .active(source, queue)
    }
    
    func stop() {
        guard case .active(let dispatchSource, let queue) = state else {
            return
        }
        
        dispatchSource.cancel()
        
        queue.sync {
        }
    }
}
    
extension FileWatcher {
    
    private func urlFileRepresentation() throws -> Int32 {
        guard FileManager.default.fileExists(atPath: fileSystemObservable.url.path) else {
            throw LocalizedErrors.directoryOrFileNotFound
        }
        
        let path = fileSystemObservable.url.path as NSString
        let representation = path.fileSystemRepresentation
        return open(representation, O_EVTONLY)
    }
}

extension FileWatcher {
    
    /// Logging
    private func tellMeWhatEventJustHappened(for fileSystemEvent: DispatchSource.FileSystemEvent) {
        switch fileSystemEvent {
        case .all:
            print("all events")
        case .attrib:
            print("attributes changed")
        case .delete:
            print("file was deleted")
        case .extend:
            print("file size changed")
        case .funlock:
            print("there was a funlock")
        case .link:
            print("there was a link")
        case .rename:
            print("file was renamed")
        case .revoke:
            print("revoke thing i guess")
        case .write:
            print("write")
        default:
            print("idk what \(fileSystemEvent.rawValue) represents")
        }
    }
}

extension FileWatcher {
    
    private enum LocalizedErrors: CustomNSError {
        case directoryOrFileNotFound
        
        var errorUserInfo: [String: Any] {
            switch self {
            case .directoryOrFileNotFound:
                return [
                    NSLocalizedDescriptionKey: "Could not begin observing file/directory as it does not exist."
                ]
            }
        }
    }
}
