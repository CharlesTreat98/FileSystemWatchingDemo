import Foundation

// Non-thread safe, unscalable but generalized example.
final class DefaultFileElementController<F: FileTransformer>: DirectoryResourceObserverDelegate {
    
    /// NOT thread safe accessed.
    /// It is always mutated by the queue on the `DirectoryResourceObserver`
    private(set) var elements: [F.Element] = [] {
        didSet {
            delegate?.didUpdateElements()
        }
    }
    
    private var underlyingFiles: [FileDescriptor: F.Element] = [:]
    
    private let transformer: F
    
    weak var delegate: FileElementViewDelegate?
    
    init(transformer: F) {
        self.transformer = transformer
    }
}

extension DefaultFileElementController {
    
    func directoryDidReceive(updateEvent: FileUpdateEvent) {
        guard let element = transformer.transform(fileDescriptor: updateEvent.affectedFile) else {
            return
        }
        
        updateUnderlyingFiles(with: updateEvent.affectedFile, element: element)
    }
    
    func directoryDidReceive(newFileEvent: FileObservedEvent) {
        guard let element = transformer.transform(fileDescriptor: newFileEvent.affectedFile) else {
            return
        }
        
        updateUnderlyingFiles(with: newFileEvent.affectedFile, element: element)
    }
    
    func directoryDidReceive(deletedFileEvent: FileObservedEvent) {
        updateUnderlyingFiles(with: deletedFileEvent.affectedFile, element: nil)
    }
    
    func didReceiveRegister(registrationEvent: DirectoryObservationRegistrationEvent) {
        self.underlyingFiles = registrationEvent.snapshot.reduce(into: [FileDescriptor: F.Element]()) { allUnderlying, nextFile in
            allUnderlying[nextFile] = transformer.transform(fileDescriptor: nextFile)
        }
        
        rebuildElements()
    }
}

extension DefaultFileElementController {
    
    private func updateUnderlyingFiles(with affectedFile: FileDescriptor, element: F.Element?) {
        underlyingFiles[affectedFile] = element
        rebuildElements()
    }
    
    private func rebuildElements() {
        elements = underlyingFiles.values.map {
            $0
        }
    }
}
