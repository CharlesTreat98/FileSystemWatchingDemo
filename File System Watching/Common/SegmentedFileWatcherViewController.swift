import Foundation
import UIKit

final class SegmentedFileWatcherViewController: UIViewController {
    
    private(set) lazy var segmentedControl = lazySegmentedView()
    
    private lazy var coordinator = lazyFileDescriptorCoordinator()
    
    private lazy var lineSeparatorView = lazyLineSeparatorView()
    
    private var viewControllers: [UIViewController] = []
    
    private var selectedViewController: UIViewController?
    
    private lazy var fileRegistry = lazyFileObserverRegistry()
    
//    private let loggerViewController = EventLoggerViewController()
    
    private lazy var fileResourceToken = lazyFileResourceToken()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // Strategies Iteration
//        let jsonViewModel = FileDescriptorViewModel(title: "JSON")
//        let filesViewModel = FileDescriptorViewModel(title: "All")
//        let inspectionViewModel = InspectionViewModel()
//
//        coordinator.register(JSONFilesTransformationStrategy(viewModel: jsonViewModel))
//        coordinator.register(TotalFilesTransformationStrategy(viewModel: filesViewModel))
//        coordinator.register(InspectionsDecodingTransformationStrategy(viewModel: inspectionViewModel))
        
//        self.viewControllers = [
//            FileTableViewController(viewModel: filesViewModel, hasDetails: false),
//            loggerViewController,
//            InspectionTableViewController(viewModel: inspectionViewModel)
//        ]
        
        self.viewControllers = [
            EventLoggerViewController(token: fileResourceToken),
            AllFilesDynamicTableViewController(token: fileResourceToken)
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        fileRegistry.unregister(fileResourceToken)
    }
}

extension SegmentedFileWatcherViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(segmentedControl)
        self.selectedViewController = viewControllers.first
        
        view.addSubview(lineSeparatorView)
        
        addChild(selectedViewController!)
        view.addSubview(selectedViewController!.view)
        
        updateConstraintsFor(new: selectedViewController!.view)
        
        selectedViewController!.didMove(toParent: self)
        
        let fileResource = FileResource(url: dropBoxURL())
        self.fileResourceToken = fileRegistry.register(fileResource)
        
//        do {
//            try coordinator.start()
//        } catch {
//            print("Error caught: \(error)")
//        }
    }
}

extension SegmentedFileWatcherViewController {
    
    @objc
    private func segmentedControlDidChange() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let toViewController = viewControllers[selectedIndex]
        
        transition(from: selectedViewController!, to: toViewController)
        selectedViewController = toViewController
    }
    
    private func transition(from currentViewController: UIViewController, to nextViewController: UIViewController) {
        currentViewController.willMove(toParent: nil)
        currentViewController.view.removeFromSuperview()
        currentViewController.removeFromParent()
        
        addChild(nextViewController)
        let subview = nextViewController.view!
        view.addSubview(subview)
        
        updateConstraintsFor(new: subview)
    }
}

extension SegmentedFileWatcherViewController {
    
    private func updateConstraintsFor(new subview: UIView) {
        segmentedControl.setContentHuggingPriority(.required, for: .horizontal)
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            segmentedControl.leadingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
            
            lineSeparatorView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            lineSeparatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            lineSeparatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            lineSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            subview.topAnchor.constraint(equalTo: lineSeparatorView.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SegmentedFileWatcherViewController {
    
    private func lazyFileResourceToken() -> FileResourceToken {
        let fileResource = FileResource(url: dropBoxURL())
        
        return fileRegistry.register(fileResource)
    }
    
    private func lazySegmentedView() -> UISegmentedControl {
        let titles = viewControllers.map { $0.title ?? "Default" }
        let segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        
        return segmentedControl
    }
    
    private func lazyFileDescriptorCoordinator() -> FileWatcherCoordinator {
        return FileWatcherCoordinator(
            observable: FileSystemObservable(url: dropBoxURL())
        )
    }
    
    private func lazyFileObserverRegistry() -> FileResourceRegistry {
        return DefaultFileResourceRegistry()
    }
    
    private func lazyLineSeparatorView() -> UIView {
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        return separatorView
    }
        
    private func dropBoxURL() -> URL {
        return FileManager.documentDirectoryURL.appending(path: "DropBox/")
    }
}
