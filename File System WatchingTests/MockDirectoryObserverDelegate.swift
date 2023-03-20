import Foundation
import XCTest

@testable import File_System_Watching

final class MockDirectoryObserverDelegate: DirectoryResourceObserverDelegate {
    
    private var callbacks: [Callback] = []
    
    private var queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }
}

extension MockDirectoryObserverDelegate {
    
    func directoryDidReceive(update: FileUpdateEvent) {
        add(
            .didReceiveUpdateFor(
                fileNamed: update.affectedFile.name,
                contentsChanged: update.contentsChanged,
                attributesChanged: Set(update.changedAttributes ?? [])
            )
        )
    }
    
    func directoryDidReceive(newFile: FileObservedEvent) {
        add(
            .didInsert(
                newFileNamed: newFile.affectedFile.name
            )
        )
    }
    
    func directoryDidReceive(deletedFile: FileObservedEvent) {
        add(
            .didDelete(
                fileNamed: deletedFile.affectedFile.name
            )
        )
    }
    
    func didReceiveRegister(registrationEvent: DirectoryObservationRegistrationEvent) {
        add(
            .didRegister(
                observedDirectory: registrationEvent.affectedFile.name,
                files: Set(registrationEvent.snapshot.map { $0.name })
            )
        )
    }
}

extension MockDirectoryObserverDelegate {
    
    private func add(_ callback: Callback) {
        self.callbacks.append(callback)
    }
}

extension MockDirectoryObserverDelegate {
    
    func verifyCallbacks(against expected: [Callback]) {
        queue.async {
            XCTAssertEqual(expected, self.callbacks)
            
            self.callbacks = []
        }
    }
}

extension MockDirectoryObserverDelegate {
    
    enum Callback: Equatable {
        case didReceiveUpdateFor(fileNamed: String, contentsChanged: Bool, attributesChanged: Set<FileAttributeKey>?)
        case didInsert(newFileNamed: String)
        case didDelete(fileNamed: String)
        case didRegister(observedDirectory: String, files: Set<String>)
    }
}

