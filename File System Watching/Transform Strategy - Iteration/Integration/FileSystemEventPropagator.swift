import Foundation
import UniformTypeIdentifiers

struct FileSystemEventPropagator {
    
    func sendEvents(
        for observable: FileSystemObservable,
        delegate: FileDescriptorEventDelegate?,
        eventType: DispatchSource.FileSystemEvent
    ) {
        
        var unsafeBool = ObjCBool(true)
        if FileManager.default.fileExists(atPath: observable.url.path, isDirectory: &unsafeBool) {
            if unsafeBool.boolValue {
                handleEventsForDirectory(
                    observedURL: observable.url,
                    with: delegate,
                    eventType: eventType
                )
            } else {
                handleEventForFile(
                    observedURL: observable.url,
                    with: delegate,
                    eventType: eventType
                )
            }
        } else {
            delegate?.didReceive(error: LocalizedErrors.urlNoLongerExists(path: observable.url.path))
        }
    }
}

extension FileSystemEventPropagator {
    
    private func handleEventForFile(
        observedURL: URL,
        with delegate: FileDescriptorEventDelegate?,
        eventType: DispatchSource.FileSystemEvent
    ) {
        do {
            let fileName = FileManager.default.displayName(atPath: observedURL.path)
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: observedURL.path)
            
            guard
                let fileSize = fileAttributes[FileAttributeKey.size] as? Int
            else {
                return
            }
            
            let newFileDescriptor = FileDescriptor(
                name: fileName,
                type: UTType.makeType(from: observedURL.lastPathComponent),
                size: fileSize,
                attributes: fileAttributes,
                url: observedURL
            )
            
            delegate?.didReceive(
                event: FileDescriptorEvent(
                    eventPayload: .file(
                        fileDescription: newFileDescriptor,
                        fileSystemEvent: eventType
                    )
                )
            )
        } catch {
            
        }
    }
}

extension FileSystemEventPropagator {
    
    private func handleEventsForDirectory(
        observedURL: URL,
        with delegate: FileDescriptorEventDelegate?,
        eventType: DispatchSource.FileSystemEvent
    ) {
        guard let enumerator = FileManager.default.enumerator(atPath: observedURL.path) else {
            return
        }

        var fileDescriptors: [FileDescriptor] = []
        while let nextObject = enumerator.nextObject() {
            guard
                let fileAttributes = enumerator.fileAttributes,
                let fileDescriptor = createFileDescriptor(
                    from: fileAttributes,
                    name: (nextObject as? String),
                    directoryURL: observedURL
                )
            else {
                continue
            }
            
            fileDescriptors.append(fileDescriptor)
        }
        
        delegate?.didReceive(
            event: FileDescriptorEvent(
                eventPayload: .directory(
                    contents: fileDescriptors,
                    fileSystemEvent: eventType
                )
            )
        )
    }
}

extension FileSystemEventPropagator {
    
    private func createFileDescriptor(
        from enumeratedFile: [FileAttributeKey: Any],
        name: String?,
        directoryURL: URL
    ) -> FileDescriptor? {
        guard
            let fileSize = enumeratedFile[FileAttributeKey.size] as? Int,
            let name = name
        else {
            return nil
        }
        
        return FileDescriptor(
            name: name,
            type: UTType.makeType(from: name),
            size: fileSize,
            attributes: enumeratedFile,
            url: directoryURL.appending(path: name)
        )
    }
}

extension FileSystemEventPropagator {
    
    private enum LocalizedErrors: CustomNSError {
        case urlNoLongerExists(path: String)
        
        var errorUserInfo: [String: Any] {
            switch self {
            case .urlNoLongerExists(let path):
                return [
                    NSLocalizedDescriptionKey: "The following URL does not point to an existing file or directory but did receive events: \(path)"
                ]
            }
        }
    }
}
