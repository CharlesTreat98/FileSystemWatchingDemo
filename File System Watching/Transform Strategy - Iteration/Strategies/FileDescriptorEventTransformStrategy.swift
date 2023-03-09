import Foundation

protocol FileDescriptorEventTransformStrategy: AnyObject {
    
    func perform(with fileDescriptorEvent: FileDescriptorEvent)
}
