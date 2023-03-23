import Foundation
import UIKit

/// Can be used by `DirectoryResourceObserverDelegates` to process the raw file data
/// passed in from `FileObservedEvents` into "final product types"
protocol FileTransformer {
    
    // Should we enforce this type constraint to make it easier for
    // developers to re-use a 'general' delegate?
    // Perhaps hashable instead to make tracking elements even easier?
    associatedtype Element: Equatable
    
    func transform(fileDescriptor: FileDescriptor) -> Element?
}

protocol OpenFileTransformer {
    
    associatedtype Element
    
    func transform(fileDescriptor: FileDescriptor) -> Element?
}


final class InspectionFileTransformer: FileTransformer {
    
    var error: Error?
    
    func transform(fileDescriptor: FileDescriptor) -> Inspection? {
        guard
            fileDescriptor.type == .json,
            let data = FileManager.default.contents(atPath: fileDescriptor.url.path)
        else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(Inspection.self, from: data)
        } catch {
            self.error = error
            return nil
        }
    }
}


struct TextFileTransformer: FileTransformer {
    
    func transform(fileDescriptor: FileDescriptor) -> TextFile? {
        guard
            fileDescriptor.type == .plainText,
            let data = FileManager.default.contents(atPath: fileDescriptor.url.path),
            let string = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return TextFile(name: fileDescriptor.name, text: string)
    }
}

struct DatabaseFileTransformer: FileTransformer {
    
    func transform(fileDescriptor: FileDescriptor) -> FileDescriptor? {
        guard fileDescriptor.type == .database else {
            return nil
        }
        
        return fileDescriptor
    }
}
