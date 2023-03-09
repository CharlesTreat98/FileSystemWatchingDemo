import Foundation

final class InspectionViewModel {
    
    var inspections: [InspectionsDecodingTransformationStrategy.Inspection] = [] {
        didSet {
            delegate?.inspectionsDidChange(to: inspections)
        }
    }
    
    weak var delegate: InspectionViewDelegate?
    
    init() {
    }
}
