import Foundation

import CoreServices

struct FileDescriptorEvent {
    
    let eventPayload: Payload
}

extension FileDescriptorEvent {
    
    enum Payload {
        case directory(contents: [FileDescriptor], fileSystemEvent: DispatchSource.FileSystemEvent)
        case file(fileDescription: FileDescriptor, fileSystemEvent: DispatchSource.FileSystemEvent)
    }
}
