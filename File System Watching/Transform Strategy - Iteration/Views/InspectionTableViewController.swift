import Foundation
import UIKit

final class InspectionTableViewController: UITableViewController, InspectionViewDelegate {
    
    var inspections: [InspectionsDecodingTransformationStrategy.Inspection] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let viewModel: InspectionViewModel
    
    init(viewModel: InspectionViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Inspections"
        
        viewModel.delegate = self
        tableView.allowsSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InspectionTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inspections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) ?? UITableViewCell()
        
        guard indexPath.row < inspections.count else {
            return UITableViewCell()
        }
        
        let inspection = inspections[indexPath.row]
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        contentConfiguration.text = inspection.header.name
        let measurement = Measurement(value: Double(inspection.header.databaseSize), unit: UnitInformationStorage.bytes)
        contentConfiguration.secondaryText = ByteCountFormatter.string(from: measurement, countStyle: .file)
        
        cell.contentConfiguration = contentConfiguration
        return cell
    }
}

extension InspectionTableViewController {
    
    func inspectionsDidChange(to inspections: [InspectionsDecodingTransformationStrategy.Inspection]) {
        self.inspections = inspections
    }
}
