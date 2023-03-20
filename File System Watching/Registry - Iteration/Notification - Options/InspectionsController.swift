import Foundation

final class InspectionsController: DirectoryResourceObserverDelegate {
    
    private(set) var inspections: [Inspection] = []
    
    private let inspectionTransformer = InspectionFileTransformer()

}

extension InspectionsController {
    
    func directoryDidReceive(update: FileUpdateEvent) {
        guard
            update.contentsChanged,
            let inspection = deriveInspection(from: update.affectedFile)
        else {
            return
        }
        
        updateInspections(with: inspection)
    }
    
    func directoryDidReceive(newFile: FileObservedEvent) {
        guard let inspection = deriveInspection(from: newFile.affectedFile) else {
            return
        }
        
        inspections.append(inspection)
    }
    
    func directoryDidReceive(deletedFile: FileObservedEvent) {
        guard
            let inspection = deriveInspection(from: deletedFile.affectedFile),
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
        do {
            return try inspectionTransformer.transform(fileDescriptor: fileDescriptor)
        } catch {
            print("Encountered error trying to derive inspection: \(error)")
            return nil
        }
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
