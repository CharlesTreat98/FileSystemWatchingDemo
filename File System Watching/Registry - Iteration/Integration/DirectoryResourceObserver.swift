import Foundation
import AsyncAlgorithms
import UniformTypeIdentifiers

public final class DirectoryResourceObserver: @unchecked Sendable {
    
    // Exposed for testing
    internal let queue = DispatchQueue(label: "DirectoryWatcher-\(UUID().uuidString)")
    
    // Option 1: Delegates
    private(set) var delegates: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()
    
    private(set) lazy var fileManager = lazyFileManager()
    
    private let channel: AsyncThrowingChannel<Any, Error>
    private let dispatchSource: DispatchSourceFileSystemObject
    private let fileResource: FileResource
    
    /// Should only be accessed via `queue`.
    private var currentFiles: [FileDescriptor] = []
    
    init(fileResource: FileResource) {
        let fileDescriptor = open((fileResource.url.path as NSString).fileSystemRepresentation, O_EVTONLY)
        
        self.fileResource = fileResource
        self.channel = AsyncThrowingChannel()
        self.dispatchSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .all,
            queue: queue
        )

        initSelf()
    }
}

// MARK: Life Cycle

extension DirectoryResourceObserver {
    
    private func initSelf() {
        dispatchSource.setEventHandler(qos: .userInteractive, handler: { [unowned self] in
            self.fileEvent()
        })
        
        queue.async { [self] in
            self.currentFiles = self.collectCurrentFiles()
        }
        
        dispatchSource.resume()
    }
    
    func tearDown() {
        for delegate in allDelegates() {
            delegates.remove(delegate)
        }
        
        dispatchSource.cancel()
        
        queue.sync {
        }
    }
}

// MARK: Delegate

extension DirectoryResourceObserver {
    
    public func add(_ delegate: DirectoryResourceObserverDelegate, joinInProgress: Bool = false) {
        queue.async {
            self.delegates.add(delegate)
        }
        
        if joinInProgress {
            self.joinInProgress(for: delegate)
        }
    }
    
    public func remove(_ delegate: DirectoryResourceObserverDelegate) {
        queue.async {
            self.delegates.remove(delegate)
        }
    }
}

// MARK: Current Files

extension DirectoryResourceObserver {
    
    /// Called on `queue` via the `DispatchSourceWorkItem`.
    private func collectCurrentFiles() -> [FileDescriptor] {
        guard let enumerator = fileManager.enumerator(atPath: fileResource.url.path) else {
            return []
        }
        
        var fileDescriptors: [FileDescriptor] = []
        while let nextObject = enumerator.nextObject() {
            guard
                let fileAttributes = enumerator.fileAttributes,
                let fileDescriptor = createFileDescriptor(
                    from: fileAttributes,
                    name: (nextObject as? String),
                    directoryURL: fileResource.url
                )
            else {
                continue
            }
            
            fileDescriptors.append(fileDescriptor)
        }
        
        return fileDescriptors
    }
    
    private func createFileDescriptor(
        from fileAttributes: [FileAttributeKey: Any],
        name: String?,
        directoryURL: URL
    ) -> FileDescriptor? {
        guard
            let fileSize = fileAttributes[FileAttributeKey.size] as? Int,
            let name = name
        else {
            return nil
        }
        
        return FileDescriptor(
            name: name,
            type: UTType.makeType(from: name),
            size: fileSize,
            attributes: fileAttributes,
            url: directoryURL.appending(path: name)
        )
    }
}

// MARK: Event

extension DirectoryResourceObserver {
    
    private func fileEvent() {
        
        let currentFileSet = Set(currentFiles)
        let newFiles = Set(collectCurrentFiles())
        
        // Save the new files
        defer { self.currentFiles = [FileDescriptor](newFiles) }
        
        if currentFileSet == newFiles {
            createUpdateEvent(forOldFiles: currentFileSet, againstNewFiles: newFiles)
        } else if let newFile = newFiles.subtracting(currentFileSet).first {
            let insertEvent = FileInsertEvent(affectedFile: newFile)
            
            notifyDelegatesAbout(newFile: insertEvent)
        } else if let deletedFile = currentFileSet.subtracting(newFiles).first  {
            let deleteEvent = FileDeleteEvent(affectedFile: deletedFile)
            
            notifyDelegatesAbout(deleteFile: deleteEvent)
        } else {
            return
        }
    }
    
    private func createUpdateEvent(forOldFiles oldFileSet: Set<FileDescriptor>, againstNewFiles newFileSet: Set<FileDescriptor>) {
        for newFile in newFileSet {
            guard
                let previousFile = oldFileSet.first(where: { $0 == newFile }),
                let attributesChanged = compare(lhs: previousFile.attributes, rhs: newFile.attributes)
            else {
                continue
            }
            
            let updateEvent = FileUpdateEvent(
                affectedFile: newFile,
                contentsChanged: attributesChanged.contains(.size),
                changedAttributes: attributesChanged
            )
            
            notifyDelegatesAbout(update: updateEvent)
        }
        
        return
    }
}

extension DirectoryResourceObserver {
    
    /// Thread safe notification of newly registered delegate about current file contents
    /// Marked as internal to allow the extension to read this method. 
    private func joinInProgress(for delegate: DirectoryResourceObserverDelegate) {
        queue.async { [self] in
            delegate.didReceiveRegister(
                registrationEvent: DirectoryObservationRegistrationEvent(
                    affectedFile: self.observedDirectoryDescriptor(),
                    snapshot: self.currentFiles
                )
            )
        }
    }
}

// MARK: Delegate Notification

extension DirectoryResourceObserver {
    
    private func notifyDelegatesAbout(update: FileUpdateEvent) {
        for delegate in allDelegates() {
            delegate.directoryDidReceive(update: update)
        }
    }
    
    private func notifyDelegatesAbout(newFile: FileInsertEvent) {
        for delegate in allDelegates() {
            delegate.directoryDidReceive(newFile: newFile)
        }
    }
    
    private func notifyDelegatesAbout(deleteFile: FileDeleteEvent) {
        for delegate in allDelegates() {
            delegate.directoryDidReceive(deletedFile: deleteFile)
        }
    }
}

// MARK: Observed Directory File Descriptor

extension DirectoryResourceObserver {
    
    private func observedDirectoryDescriptor() -> FileDescriptor {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileResource.url.path)
            
            return FileDescriptor(
                name: fileResource.url.lastPathComponent,
                type: .directory,
                size: attributes[.size] as? Int ?? .min,
                attributes: attributes,
                url: fileResource.url
            )
        } catch {
            return FileDescriptor(
                name: fileResource.url.lastPathComponent,
                type: .directory,
                size: .min,
                attributes: nil,
                url: fileResource.url
            )
        }
    }
}

extension DirectoryResourceObserver {
    
    private func allDelegates() -> [DirectoryResourceObserverDelegate] {
        return delegates.allObjects as! [DirectoryResourceObserverDelegate]
    }
}

extension DirectoryResourceObserver {
    
    private func lazyFileManager() -> FileManager {
        return FileManager()
    }
}

// MARK: Constants

extension DirectoryResourceObserver {
    
    private enum LocalizedErrors: CustomNSError {
        case directoryOrFileNotFound
        case couldNotGetAttributesForObservedDirectory
        
        var errorUserInfo: [String: Any] {
            switch self {
            case .directoryOrFileNotFound:
                return [
                    NSLocalizedDescriptionKey: "Could not begin observing file/directory as it does not exist."
                ]
            case .couldNotGetAttributesForObservedDirectory:
                return [
                    NSLocalizedDescriptionKey: "Attributes for URL not available."
                ]
            }
        }
    }
}
