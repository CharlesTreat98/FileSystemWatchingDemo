import Foundation

func compare(lhs: [FileAttributeKey: Any]?, rhs: [FileAttributeKey: Any]?) -> [FileAttributeKey]? {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        let lhsKeys = Set(lhs.keys.compactMap { $0 as FileAttributeKey })
        let rhsKeys = Set(rhs.keys.compactMap { $0 as FileAttributeKey })
        
        guard lhsKeys == rhsKeys else {
            return [FileAttributeKey](lhsKeys.subtracting(rhsKeys))
        }
        
        var newFileAttributeKeys = [FileAttributeKey]()
        for currentKey in lhsKeys {
            
            let lhsValue = lhs[currentKey]
            let rhsValue = rhs[currentKey]
            
            switch currentKey {
            case .systemFileNumber, .posixPermissions, .systemNumber, .size, .extensionHidden, .referenceCount, .ownerAccountID:
                guard lhsValue as? Int64 == rhsValue as? Int64 else {
                    newFileAttributeKeys.append(currentKey)
                    continue
                }
                
                continue
            case .ownerAccountName, .type:
                guard lhsValue as? String == rhsValue as? String else {
                    newFileAttributeKeys.append(currentKey)
                    continue
                }
                
                continue
            case .modificationDate, .creationDate:
                guard lhsValue as? Date == rhsValue as? Date else {
                    newFileAttributeKeys.append(currentKey)
                    continue
                }
                
                continue
            default:
                continue
            }
        }
        
        return newFileAttributeKeys.isEmpty ? nil : newFileAttributeKeys
    case (.none, .none):
        return nil
    case (_, .some(let newAttributes)):
        return newAttributes.keys.compactMap { $0 as FileAttributeKey }
    case (.some(_), _):
        return nil
    }
}
