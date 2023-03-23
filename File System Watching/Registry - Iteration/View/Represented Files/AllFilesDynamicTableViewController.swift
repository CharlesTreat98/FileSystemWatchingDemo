import UIKit
import Foundation

final class AllFilesDynamicTableViewController: UITableViewController, DirectoryResourceObserverDelegate {
    
    private var fileDescriptors = [FileDescriptor]()
    
    private let token: FileResourceToken
    
    init(token: FileResourceToken) {
        self.token = token
        
        super.init(nibName: nil, bundle: nil)
        
        title = "All Files"
        
        token.observer.add(self, joinInProgress: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AllFilesDynamicTableViewController {
    
    func tearDown() {
        token.observer.remove(self)
    }
}

extension AllFilesDynamicTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        tableView.register(RepresentedFileTableViewCell.self, forCellReuseIdentifier: String(describing: RepresentedFileTableViewCell.self))
    }
}

extension AllFilesDynamicTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            indexPath.row < fileDescriptors.count,
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepresentedFileTableViewCell.self)) as? RepresentedFileTableViewCell
        else {
            return RepresentedFileTableViewCell(style: .default, reuseIdentifier: String(describing: RepresentedFileTableViewCell.self))
        }
        
        let fileDescriptor = fileDescriptors[indexPath.row]
        
        cell.fileTypeLabel.text = fileDescriptor.type.preferredFilenameExtension
        cell.fileNameLabel.text = fileDescriptor.name
        cell.fileAttributesLabel.text = fileDescriptor.attributes == nil
        ? nil
        : fileDescriptor.attributes!.keys.map { $0.rawValue }.joined(separator: ", ")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileDescriptors.count
    }
}

extension AllFilesDynamicTableViewController {
    
    func directoryDidReceive(updateEvent: FileUpdateEvent) {
        DispatchQueue.main.async {
            guard
                let index = self.fileDescriptors.firstIndex(of: updateEvent.affectedFile),
                let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RepresentedFileTableViewCell
            else {
                return
            }
            
            self.tableView.beginUpdates()
            cell.fileAttributesLabel.text = updateEvent.affectedFile.attributes!.keys.compactMap { $0.rawValue }.joined(separator: ", ")
            cell.fileTypeLabel.text = updateEvent.affectedFile.type.description
            self.tableView.endUpdates()
        }
    }
    
    func directoryDidReceive(newFileEvent: FileObservedEvent) {
        DispatchQueue.main.async {
            self.fileDescriptors.append(newFileEvent.affectedFile)
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.fileDescriptors.count - 1, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func directoryDidReceive(deletedFileEvent: FileObservedEvent) {
        DispatchQueue.main.async {
            guard let index = self.fileDescriptors.firstIndex(of: deletedFileEvent.affectedFile) else {
                return
            }
            
            self.fileDescriptors.remove(at: index)
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func didReceiveRegister(registrationEvent: DirectoryObservationRegistrationEvent) {
        fileDescriptors = registrationEvent.snapshot
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
