import Foundation

struct EventLogViewModel {
    
    private let event: FileObservedEvent
    
    var title: String {
        if event is FileUpdateEvent {
            return "Update"
        } else if event is FileInsertEvent {
            return "Insert"
        } else {
            return "Deleted"
        }
    }
    
    var subtitle: String {
        if let update = event as? FileUpdateEvent {
            return update.changedAttributes == nil ? "" : update.changedAttributes!.map { $0.rawValue }.joined(separator: ",")
        } else if event is FileInsertEvent {
            return event.affectedFile.name
        } else {
            return event.affectedFile.name
        }
    }
    
    var contentIsChanged: Bool? {
        guard let updateEvent = event as? FileUpdateEvent else {
            return nil
        }
        
        return updateEvent.contentsChanged
    }
    
    init(event: FileObservedEvent) {
        self.event = event
    }
}
