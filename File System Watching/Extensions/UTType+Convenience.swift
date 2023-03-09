import UniformTypeIdentifiers

extension UTType {
    
    /// - Parameters:
    ///  - fileName: Last path component of a URL containing the extension for the file. 
    static func makeType(from fileName: String) -> UTType {
        let fileExtension = (fileName as NSString).pathExtension
        
        guard let type = UTType(filenameExtension: fileExtension) else {
            return .item
        }
        
        return type
    }
}
