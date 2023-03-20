import Foundation

// This requires us to expose a lot of information about the underlying files.
// Also ends up exposing the file attributes that are affected..
// Too much set up?
//
// Requires the developer to save the reference to the `Token` which we already were requiring based on the design
// of the `FileResourceRegistry`. However, we will still need a reference to
public protocol DirectoryResourceObserverDelegate: AnyObject {
    
    
    // FileObservedEvents
    func directoryDidReceive(update: FileUpdateEvent)
    
    func directoryDidReceive(newFile: FileObservedEvent)
    
    func directoryDidReceive(deletedFile: FileObservedEvent)
    
    func didReceiveRegister(registrationEvent: DirectoryObservationRegistrationEvent)
    
    
    // Exposes much less of the information for the downstream receivers
    // Most implementations probably just need to know about the names of the new files so they
    // can perform look ups... But they might want more info?
    // More specific information
    func directoryDidUpdate(file fileName: String, updatedAttributes: [FileAttributeKey])
    
    func directoryDidInsert(file fileName: String)
    
    func directoryDidRemove(file fileName: String)
    
    func directoryDidRegister(with snapshot: [FileDescriptor])
}

extension DirectoryResourceObserverDelegate {
    
    func directoryDidUpdate(file fileName: String, updatedAttributes: [FileAttributeKey]) {
        
    }
    
    func directoryDidInsert(file fileName: String) {
        
    }
    
    func directoryDidRemove(file fileName: String) {
        
    }
    
    func directoryDidRegister(with snapshot: [FileDescriptor]) {
        
    }
}
