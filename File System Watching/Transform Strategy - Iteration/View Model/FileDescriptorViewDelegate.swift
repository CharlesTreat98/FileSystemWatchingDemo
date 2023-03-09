import Foundation

protocol FileDescriptorViewDelegate: AnyObject {
    
    func fileDescriptorsDidChange(to fileDescriptors: [FileDescriptor])
}
