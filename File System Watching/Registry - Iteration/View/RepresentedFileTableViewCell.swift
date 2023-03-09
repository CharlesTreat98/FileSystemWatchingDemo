import UIKit

final class RepresentedFileTableViewCell: UITableViewCell {
    
    private(set) lazy var fileNameLabel = lazyFileNameLabel()
    private(set) lazy var fileAttributesLabel = lazyFileAttributesLabel()
    
    private(set) lazy var fileTypeLabel = lazyFileTypeLabel()
    
    private(set) lazy var representedFileInformationStackView = lazyRepresentedFileInformationStackView()
    
    private(set) lazy var containerStackView = lazyAllCellContentStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RepresentedFileTableViewCell {
    
    private func initSelf() {
        contentView.addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}

extension RepresentedFileTableViewCell {
    
    private func lazyFileTypeLabel() -> UILabel {
        return makeLabel(with: .preferredFont(forTextStyle: .headline))
    }
    
    private func lazyAllCellContentStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            representedFileInformationStackView,
            fileTypeLabel
        ])
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
}

extension RepresentedFileTableViewCell {
    
    private func lazyRepresentedFileInformationStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            fileNameLabel,
            fileAttributesLabel
        ])
        
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    private func lazyFileNameLabel() -> UILabel {
        return makeLabel(with: .preferredFont(forTextStyle: .headline))
    }
    
    private func lazyFileAttributesLabel() -> UILabel {
        let label = makeLabel(with: .preferredFont(forTextStyle: .subheadline))
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }
    
    private func makeLabel(with font: UIFont) -> UILabel {
        let label = UILabel()
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
}
