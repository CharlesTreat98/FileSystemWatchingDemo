import Foundation
import UniformTypeIdentifiers

final class JSONFilesTransformationStrategy: FileDescriptorEventTransformStrategy {
    
    let viewModel: FileDescriptorViewModel
    
    init(viewModel: FileDescriptorViewModel) {
        self.viewModel = viewModel
    }
    
    func perform(with fileDescriptorEvent: FileDescriptorEvent) {
        guard case let .directory(fileDescriptors, _) = fileDescriptorEvent.eventPayload else {
            return
        }
        
        viewModel.fileDescriptors = fileDescriptors.filter { fileDescriptor in
            return fileDescriptor.type == .json
        }
    }
}
