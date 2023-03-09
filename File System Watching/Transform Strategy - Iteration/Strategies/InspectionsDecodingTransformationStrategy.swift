import Foundation

final class InspectionsDecodingTransformationStrategy: FileDescriptorEventTransformStrategy {
    
    let viewModel: InspectionViewModel
    
    init(viewModel: InspectionViewModel) {
        self.viewModel = viewModel
    }
    
    func perform(with fileDescriptorEvent: FileDescriptorEvent) {
        guard case let .directory(fileDescriptors, _) = fileDescriptorEvent.eventPayload else {
            return
        }
        
        let jsonFileDescriptors = fileDescriptors.filter {
            return $0.type == .json
        }
        
        viewModel.inspections = jsonFileDescriptors.compactMap { jsonFileDescriptor in
            guard
                let data = FileManager.default.contents(atPath: jsonFileDescriptor.url.path),
                let inspection = decodeInspection(from: data)
            else {
                return nil
            }
            
            return inspection
        }
    }
}

extension InspectionsDecodingTransformationStrategy {
    
    private func decodeInspection(from data: Data) -> Inspection? {
        do {
            let inspection = try JSONDecoder().decode(Inspection.self, from: data)
            return inspection
        } catch {
            print("Error encountered while decoding: \(error)")
            return nil
        }
    }
}

extension InspectionsDecodingTransformationStrategy {
    
    struct Inspection: Decodable {
        
        let header: Metadata
        let forms: [Form]
        
        struct Metadata: Decodable {
            let name: String
            let description: String
            let purpose: String
            let revision: Int64
            let databaseSize: Int64
        }
        
        struct Form: Decodable {
            let name: String
            let mappingFeatureClassName: String
            let primaryDisplayField: String
        }
    }
}
