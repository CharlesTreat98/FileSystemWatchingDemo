import Foundation

final class TotalFilesTransformationStrategy: FileDescriptorEventTransformStrategy {
    
    let viewModel: FileDescriptorViewModel
    
    init(viewModel: FileDescriptorViewModel) {
        self.viewModel = viewModel
    }
    
    func perform(with fileDescriptorEvent: FileDescriptorEvent) {
        guard case let .directory(fileDescriptors, _) = fileDescriptorEvent.eventPayload else {
            return
        }
        
        viewModel.fileDescriptors = fileDescriptors
    }
}
