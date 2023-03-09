import Foundation
import UIKit

final class EventLogTableViewCell: UITableViewCell {
    
    private(set) lazy var eventTypeLabel = lazyEventTypeLabel()
    private(set) lazy var isChangedSwitch = lazyIsChangedSwitch()
    private(set) lazy var stackView = lazyStackView()
    
    static var tableReuseIdentifier = String(describing: EventLogViewModel.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EventLogTableViewCell {
    
    private func initSelf() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}

extension EventLogTableViewCell {
    
    private func lazyStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            eventTypeLabel,
            isChangedSwitch
        ])
        
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func lazyEventTypeLabel() -> UIListContentView {
        let contentView = UIListContentView(configuration: .subtitleCell())
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        return contentView
    }
    
    private func lazyIsChangedSwitch() -> UISwitch {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.isUserInteractionEnabled = false
        
        return view
    }
}
