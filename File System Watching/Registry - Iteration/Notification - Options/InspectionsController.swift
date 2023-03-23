import Foundation

final class InspectionsController: DirectoryResourceObserverDelegate {
    
    private(set) var inspections: [Inspection] = []
    
    private let inspectionTransformer = InspectionFileTransformer()

}

extension InspectionsController {
    
    func directoryDidReceive(updateEvent: FileUpdateEvent) {
        guard
            updateEvent.contentsChanged,
            let inspection = deriveInspection(from: updateEvent.affectedFile)
        else {
            return
        }
        
        updateInspections(with: inspection)
    }
    
    func directoryDidReceive(newFileEvent: FileObservedEvent) {
        guard let inspection = deriveInspection(from: newFileEvent.affectedFile) else {
            return
        }
        
        inspections.append(inspection)
    }
    
    func directoryDidReceive(deletedFileEvent: FileObservedEvent) {
        guard
            let inspection = deriveInspection(from: deletedFileEvent.affectedFile),
            let indexToRemove = inspections.firstIndex(where: { $0.header.name == inspection.header.name })
        else {
            return
        }
        
        inspections.remove(at: indexToRemove)
    }
    
    func didReceiveRegister(registrationEvent: DirectoryObservationRegistrationEvent) {
        let registeredInspections = registrationEvent.snapshot.compactMap { deriveInspection(from: $0) }
        
        inspections = registeredInspections
    }
}

extension InspectionsController {
    
    private func deriveInspection(from fileDescriptor: FileDescriptor) -> Inspection? {
        return inspectionTransformer.transform(fileDescriptor: fileDescriptor)
    }
}

extension InspectionsController {
    
    private func updateInspections(with newInspection: Inspection) {
        guard let index = inspections.firstIndex(where: { $0.header.name == newInspection.header.name }) else {
            return
        }
        
        // Not thread safe
        inspections.remove(at: index)
        inspections.insert(newInspection, at: index)
    }
}
