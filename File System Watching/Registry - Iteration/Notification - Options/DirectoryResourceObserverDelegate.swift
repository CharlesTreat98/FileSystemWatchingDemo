import Foundation

// This requires us to expose a lot of information about the underlying files.
// Also ends up exposing the file attributes that are affected..
// Too much set up?
//
// Requires the developer to save the reference to the `Token` which we already were requiring based on the design
// of the `FileResourceRegistry`. However, we will still need a reference to
public protocol DirectoryResourceObserverDelegate: AnyObject {
    
    func directoryDidReceive(update: FileUpdateEvent)
    
    func directoryDidReceive(newFile: FileObservedEvent)
    
    func directoryDidReceive(deletedFile: FileObservedEvent)
    
    func didReceiveRegister(registrationEvent: DirectoryObservationRegistrationEvent)
}
