import Foundation
import UniformTypeIdentifiers

public struct FileDescriptor: Hashable {
    
    let name: String
    let type: UTType
    let size: Int
    let attributes: [FileAttributeKey: Any]?
    let url: URL
    
}

extension FileDescriptor {
    
    public static func ==(lhs: FileDescriptor, rhs: FileDescriptor) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
