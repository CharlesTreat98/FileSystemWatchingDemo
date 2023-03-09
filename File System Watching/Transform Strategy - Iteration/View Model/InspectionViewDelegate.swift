import Foundation

protocol InspectionViewDelegate: AnyObject {
    
    func inspectionsDidChange(to inspections: [InspectionsDecodingTransformationStrategy.Inspection])
}
