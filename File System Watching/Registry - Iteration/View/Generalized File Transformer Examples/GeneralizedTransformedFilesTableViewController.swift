import UIKit

protocol FileElementViewDelegate: AnyObject {
    
    func didUpdateElements()
    
    func didRemoveElement(at index: Int)
    
    func didAddElement(at index: Int)
    
    func didUpdateElement(at index: Int)
}

final class GeneralizedTransformedFilesTableViewController<
    F: FileTransformer,
    R: Renderer
>: UITableViewController where F.Element == R.Element {
    
    private let token: FileResourceToken
    
    private let controller: DefaultFileElementController<F>
    private let renderer: R
    
    init(
        token: FileResourceToken,
        fileTransformer: F = InspectionFileTransformer(),
        renderer: R = InspectionCellRenderer(),
        title: String
    ) {
        self.token = token
        self.controller = DefaultFileElementController(transformer: fileTransformer)
        self.renderer = renderer
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
        
        controller.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        token.observer.add(controller, joinInProgress: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        token.observer.remove(controller)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) ?? UITableViewCell()
        
        guard indexPath.row < controller.elements.count else {
            return UITableViewCell()
        }
        
        renderer.render(cell: cell, with: controller.elements[indexPath.row])
        
        return cell
    }
}

extension GeneralizedTransformedFilesTableViewController: FileElementViewDelegate {
   
    func didRemoveElement(at index: Int) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func didAddElement(at index: Int) {
        DispatchQueue.main.async {
            guard index < self.controller.elements.count else {
                return 
            }
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func didUpdateElement(at index: Int) {
        DispatchQueue.main.async {
            guard
                let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0))
            else {
                return
            }
            
            let element = self.controller.elements[index]
            
            self.tableView.beginUpdates()
            
            self.renderer.render(cell: cell, with: element)
            self.tableView.endUpdates()
        }
    }
    
    
    func didUpdateElements() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
