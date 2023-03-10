import Foundation

public protocol FileObservedEvent {
    
    var affectedFile: FileDescriptor { get }
}

public struct FileUpdateEvent: FileObservedEvent {
    
    public let affectedFile: FileDescriptor
    let contentsChanged: Bool
    let changedAttributes: [FileAttributeKey]?
}

public struct FileInsertEvent: FileObservedEvent {
    
    public let affectedFile: FileDescriptor
}

public struct FileDeleteEvent: FileObservedEvent {
    
    public let affectedFile: FileDescriptor
}

public struct FileRenameEvent: FileObservedEvent {
    
    public let affectedFile: FileDescriptor
    
    public let previousFile: FileDescriptor
}

public struct DirectoryObservationRegistrationEvent: FileObservedEvent {
    
    /// Information about the observed directory
    public let affectedFile: FileDescriptor
    
    /// The underlying files for the directory. 
    public let snapshot: [FileDescriptor]
}
