import Foundation

protocol FileTransformer {
    
    associatedtype Element
    
    func transform(fileDescriptor: FileDescriptor) throws -> Element?
}


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

struct InspectionFileTransformer: FileTransformer {
    
    func transform(fileDescriptor: FileDescriptor) throws -> Inspection? {
        guard
            fileDescriptor.type == .json,
            let data = FileManager.default.contents(atPath: fileDescriptor.url.path)
        else {
            return nil
        }
        
        let inspection = try JSONDecoder().decode(Inspection.self, from: data)
        return inspection
    }
}
