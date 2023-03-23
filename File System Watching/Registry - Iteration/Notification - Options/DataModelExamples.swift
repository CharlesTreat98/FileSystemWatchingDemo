import Foundation

struct Inspection: Decodable, Equatable {
    
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
    
    static func == (lhs: Inspection, rhs: Inspection) -> Bool {
        return lhs.header.databaseSize == rhs.header.databaseSize
    }
}

struct TextFile: Equatable {
    
    let name: String
    let text: String?
    
    static func ==(lhs: TextFile, rhs: TextFile) -> Bool {
        return lhs.name == rhs.name
    }
}
