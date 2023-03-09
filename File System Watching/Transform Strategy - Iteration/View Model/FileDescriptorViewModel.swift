import Foundation

final class FileDescriptorViewModel {
    
    var fileDescriptors: [FileDescriptor] {
        didSet {
            delegate?.fileDescriptorsDidChange(to: fileDescriptors)
        }
    }
    let title: String
    
    weak var delegate: FileDescriptorViewDelegate?
    
    init(fileDescriptors: [FileDescriptor] = [], title: String) {
        self.fileDescriptors = fileDescriptors
        self.title = title
    }
}
