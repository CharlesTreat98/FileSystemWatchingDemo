import Foundation
import UIKit

public class FileDescriptorTableViewCell: UITableViewCell {
    
    private(set) lazy var fileInfoView = lazyFileMetadataView()
    private(set) lazy var stackView = lazyStackView()
    private(set) lazy var sizeLabel = lazySizeLabel()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FileDescriptorTableViewCell {
    
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

extension FileDescriptorTableViewCell {
    
    private func lazyStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            fileInfoView,
            sizeLabel
        ])
        
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    private func lazyFileMetadataView() -> UIListContentView {
        let contentView = UIListContentView(configuration: .subtitleCell())
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        return contentView
    }
    
    private func lazySizeLabel() -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }
}
