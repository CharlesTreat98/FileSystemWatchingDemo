import Foundation
import UIKit

/// View begins registering events when the View Controller is visible.
final class EventLoggerViewController: UITableViewController {
    
    var events: [EventLogViewModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let token: FileResourceToken
    
    init(token: FileResourceToken) {
        self.token = token
        super.init(nibName: nil, bundle: nil)
        
        title = "Logger"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EventLoggerViewController: DirectoryResourceObserverDelegate {
    
    func directoryDidReceive(update: FileUpdateEvent) {
        events.append(EventLogViewModel(event: update))
    }
    
    func directoryDidReceive(newFileEvent: FileObservedEvent) {
        events.append(EventLogViewModel(event: newFileEvent))
    }
    
    func directoryDidReceive(deletedFileEvent: FileObservedEvent) {
        events.append(EventLogViewModel(event: deletedFileEvent))
    }
    
    func didReceiveRegister(registrationEvent: DirectoryObservationRegistrationEvent) {
        // no ops
    }
    
    func directoryDidReceive(renameEvent: FileRenameEvent) {
        events.append(EventLogViewModel(event: renameEvent))
    }
}

extension EventLoggerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        tableView.allowsSelection = false
        tableView.register(EventLogTableViewCell.self, forCellReuseIdentifier: EventLogTableViewCell.tableReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        token.observer.add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        token.observer.remove(self)
    }
}

extension EventLoggerViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            indexPath.row < events.count,
            let cell = tableView.dequeueReusableCell(withIdentifier: EventLogTableViewCell.tableReuseIdentifier) as? EventLogTableViewCell
        else {
            return UITableViewCell()
        }
        
        let viewModel = events[indexPath.row]
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.text = viewModel.title
        configuration.secondaryText = viewModel.subtitle
        configuration.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        cell.eventTypeLabel.configuration = configuration
        cell.isChangedSwitch.isHidden = viewModel.contentIsChanged == nil ? true : false
        cell.isChangedSwitch.isOn = viewModel.contentIsChanged ?? false
        
        return cell
    }
}
