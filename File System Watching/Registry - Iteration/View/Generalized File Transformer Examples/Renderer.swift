import UIKit
import Foundation

protocol Renderer {
    
    associatedtype Element
    
    func render(cell: UITableViewCell, with element: Element)
}

final class InspectionCellRenderer: Renderer {
    
    func render(cell: UITableViewCell, with element: Inspection) {
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        contentConfiguration.text = element.header.name
        let measurement = Measurement(value: Double(element.header.databaseSize), unit: UnitInformationStorage.bytes)
        contentConfiguration.secondaryText = ByteCountFormatter.string(from: measurement, countStyle: .file)
        
        cell.contentConfiguration = contentConfiguration
    }
}

final class TextCellRenderer: Renderer {
    
    func render(cell: UITableViewCell, with element: TextFile) {
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        contentConfiguration.text = element.name
        contentConfiguration.secondaryText = element.text != nil ? String(element.text!.prefix(45)) + "..." : nil
        
        cell.contentConfiguration = contentConfiguration
    }
}
