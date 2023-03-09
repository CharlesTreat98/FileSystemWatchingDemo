import Foundation

public extension FileManager {
    
    static var documentDirectoryURL: URL {
        return `default`.urls(for: .desktopDirectory, in: .userDomainMask)[0]
    }
    
    /// Randomly creates a duplicate of the existing file in the same directory as the existing file. 
    func duplicateFile(at url: URL) {
        guard let data = contents(atPath: url.path) else {
            return
        }
        
        let fileExtension = url.pathExtension
        let fileNameWithoutExtension = (url.lastPathComponent as NSString).deletingPathExtension
        let duplicatedName = fileNameWithoutExtension + "\(Int.random(in: 1...1000))." + fileExtension
        let url = url.deletingLastPathComponent().appending(path: duplicatedName)
        createFile(atPath: url.path, contents: data)
    }
}

