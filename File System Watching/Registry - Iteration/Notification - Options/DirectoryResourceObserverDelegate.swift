import Foundation

// This requires us to expose a lot of information about the underlying files.
// Also ends up exposing the file attributes that are affected..
// Too much set up?
//
// Requires the developer to save the reference to the `Token` which we already were requiring based on the design
// of the `FileResourceRegistry`. However, we will still need a reference to
//
// Should these throw ?? see FileTransformer
public protocol DirectoryResourceObserverDelegate: AnyObject {
    
    func directoryDidReceive(updateEvent: FileUpdateEvent)
    
    func directoryDidReceive(newFileEvent: FileObservedEvent)
    
    func directoryDidReceive(deletedFileEvent: FileObservedEvent)
    
    func didReceiveRegister(registrationEvent: DirectoryObservationRegistrationEvent)
}
