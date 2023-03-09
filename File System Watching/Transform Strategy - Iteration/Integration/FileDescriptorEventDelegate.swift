import Foundation

protocol FileDescriptorEventDelegate: AnyObject {
    
    func didReceive(event: FileDescriptorEvent)
    
    func didReceive(error: Error)
}

