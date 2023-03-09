import UIKit

final class FileTableViewController: UITableViewController {
    
    var files: [FileDescriptor] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var sections: [[FileDescriptor]] {
        let largeFiles = files
            .filter { $0.size > Int(Constants.largestFiles.value) }
            .sorted(by: { $0.size > $1.size})
        let mediumFiles = files
            .filter { $0.size < Int(Constants.largestFiles.value) && $0.size > Int(Constants.mediumFiles.value) }
            .sorted(by: { $0.size > $1.size })
        let smallestFiles = files
            .filter { $0.size < Int(Constants.mediumFiles.value) }
            .sorted(by: { $0.size > $1.size })
        
        return [
            largeFiles,
            mediumFiles,
            smallestFiles
        ]
    }
//
//    private lazy var duplicatedFileWatcher = lazyDuplicatedFileWatcher()
    
    // Individual files in 'Dropbox'.
//    private lazy var individualFileWatchers = lazyFileWatchers()
    
    private let viewModel: FileDescriptorViewModel
    private let hasDetails: Bool
    
    init(viewModel: FileDescriptorViewModel, hasDetails: Bool) {
        self.files = viewModel.fileDescriptors
        self.viewModel = viewModel
        self.hasDetails = false
        
        super.init(style: .grouped)
        
        title = viewModel.title
        
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolBarItem()
        
        view.backgroundColor = .systemGroupedBackground
        
        configure(tableView)
    }
}

extension FileTableViewController: FileDescriptorViewDelegate {
    
    func fileDescriptorsDidChange(to fileDescriptors: [FileDescriptor]) {
        files = fileDescriptors
    }
}

extension FileTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return Constants.sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FileDescriptorTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: FileDescriptorTableViewCell.self)) as! FileDescriptorTableViewCell
        
        guard
            !files.isEmpty,
            indexPath.row < sections[indexPath.section].count
        else {
            return FileDescriptorTableViewCell()
        }
        
        let mapFileDescriptor = sections[indexPath.section][indexPath.row]
        
        render(cell: cell, with: mapFileDescriptor)
        return cell
    }
}

extension FileTableViewController {
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let file = sections[indexPath.section][indexPath.row]
//
//        guard
//            hasDetails,
//            let string = file.jsonInPlainText()
//        else {
//            return
//        }
//
//        show(EventLoggerViewController(jsonTextToPresent: string), sender: self)
//    }
}

extension FileTableViewController {
    
    private func configure(_ tableView: UITableView) {
        tableView.register(FileDescriptorTableViewCell.self, forCellReuseIdentifier: String(describing: FileDescriptorTableViewCell.self))
        tableView.allowsSelection = hasDetails
    }
}

extension FileTableViewController {
    
    private func render(cell: FileDescriptorTableViewCell, with fileDescriptor: FileDescriptor) {
        var configuration = UIListContentConfiguration.subtitleCell()
        let formattedName = (fileDescriptor.name as NSString).deletingPathExtension
        configuration.text = formattedName
        configuration.secondaryText = (fileDescriptor.type.description as NSString).pathExtension
        configuration.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        cell.fileInfoView.configuration = configuration
        
        let measurement = Measurement(value: Double(fileDescriptor.size), unit: UnitInformationStorage.bytes)
        
        cell.sizeLabel.text = ByteCountFormatter.string(from: measurement, countStyle: .file)
    }
}

extension FileTableViewController {
    
    private func addToolBarItem() {
        let addDocumentItem = UIBarButtonItem(
            image: UIImage(systemName: "doc.on.doc"),
            style: .plain,
            target: self,
            action: #selector(duplicateInspectionFile)
        )
        
        let increaseInspectionFileSize = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addContentToJsonFile)
        )
    
        navigationItem.rightBarButtonItem = addDocumentItem
        navigationItem.leftBarButtonItem = increaseInspectionFileSize
    }
    
    @objc
    func duplicateInspectionFile() {
        FileManager.default.duplicateFile(at: FileManager.documentDirectoryURL.appending(path: "DropBox/inspections.json"))
    }
    
    @objc
    func addContentToJsonFile() {
        let url = FileManager.documentDirectoryURL.appending(path: "DropBox/inspections.json")
        let originalData = FileManager.default.contents(atPath: url.path)
        
        guard
            var originalData,
            let newDataToAppend = Constants.aWholeBunchOfText.data(using: .utf8)
        else {
            return
        }
        
        originalData.append(newDataToAppend)
        do {
            // Without the atomic write option, the directory observer does not note the change for some reason.
            // By forcing the 'write' event by setting the atomic option, then we can see the changes dynamically.
            // This will be a problem in cases where we want to hold onto the original copy and it is not feasible
            // to completely 'copy and paste' the original data.
            //
            // Though it seems that this is dependent on the method by which we are performing the writes and reads. 
            try originalData.write(to: url, options: .atomic)
        } catch {
            print("An error was encountered trying to make the inspections file larger: \(error)")
        }
    }
}

extension FileTableViewController {
    
//    private func lazyFileWatcher() -> FileWatcher {
//        return FileWatcher(
//            fileSystemObservable: FileSystemObservable(type: .directory, url: URL(filePath: "")),
//            fileSystemObservableTransformer: FileSystemEventPropagator(
//                action: DirectoryFileTransformCommand(
//                    controller: self
//                )
//            )
//        )
//    }
//
//    private func lazyDuplicatedFileWatcher() -> FileWatcher {
//        return FileWatcher(
//            fileSystemObservable: FileSystemObservable(type: .directory, url: URL(fileURLWithPath: "")),
//            fileSystemObservableTransformer: FileSystemEventPropagator(
//                action: DoNothingTransformCommand()
//            )
//        )
//    }
    
//    private func lazyFileWatchers() -> [FileWatcher] {
//        do {
//            let urls = try FileManager.default.contentsOfDirectory(
//                at: dropBoxURL(),
//                includingPropertiesForKeys: nil
//            )
//
//            return urls.map {
//                FileWatcher(
//                    fileSystemObservable: FileSystemObservable(type: .file, url: $0),
//                    fileSystemObservableTransformer: DefaultFileSystemObservableTransformer(
//                        action: IndividualFileTransformCommand(
//                            controller: self
//                        )
//                    )
//                )
//            }
//        } catch {
//            return []
//        }
//    }
}

extension FileTableViewController {
    
    private enum Constants {
        
        static let largestFiles = Measurement(value: 1000000.0, unit: UnitInformationStorage.bytes)
        static let mediumFiles = Measurement(value: 500000.0, unit: UnitInformationStorage.bytes)
        
        static let sectionTitles = ["Largest Files", "Medium Files", "Smallest Files"]
        
        static let aWholeBunchOfText = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris pellentesque erat sit amet sollicitudin facilisis. Vivamus luctus condimentum est, tristique faucibus nisi venenatis quis. Nulla malesuada lectus eu enim malesuada tincidunt. Praesent ut justo lorem. Aliquam efficitur felis ut nunc mattis, eu ultrices turpis posuere. Curabitur pellentesque nisi non mollis varius. Vivamus sed dolor efficitur, convallis elit non, maximus urna. Nulla congue viverra neque quis commodo. Donec ac turpis non urna tempor auctor sed at lacus. In ac mattis odio. Proin suscipit fermentum consectetur. In hac habitasse platea dictumst. Sed eu dignissim ipsum.

        Donec volutpat sapien sed quam volutpat elementum. Proin vitae tellus urna. Ut lacinia non justo sit amet pharetra. Aenean vestibulum blandit quam non sodales. Donec quis lacinia justo. Integer lacinia mauris sapien, nec molestie metus condimentum eu. Nunc non nulla orci. In maximus vestibulum blandit. Donec a ex enim.

        Interdum et malesuada fames ac ante ipsum primis in faucibus. Vivamus egestas mauris id urna dignissim, eget feugiat augue molestie. Nulla ornare lorem vel placerat commodo. Vestibulum semper ullamcorper massa quis pellentesque. Maecenas venenatis orci nec finibus lacinia. Vestibulum ultrices quam eu lobortis aliquet. Nam vitae posuere urna. Nam et dui luctus, pellentesque sapien in, consectetur dolor. Suspendisse elit arcu, congue et gravida ut, dapibus ut nulla. Aliquam a eros varius, facilisis nulla a, volutpat neque. Proin vehicula blandit elit faucibus condimentum. Sed sit amet euismod ipsum. Etiam vitae elit diam.

        Praesent in neque non ex convallis laoreet vitae a mi. Donec sit amet turpis posuere, auctor eros non, suscipit libero. Cras viverra pharetra ex quis consectetur. Morbi nec scelerisque elit. Cras sed lacinia ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Etiam egestas metus ut odio facilisis, vitae dictum sapien finibus. Duis porttitor quis diam at auctor. Nunc accumsan nec justo vitae posuere. Donec nec sapien vitae libero dictum accumsan. Quisque eget dui ultricies turpis consectetur fringilla. Morbi quis nibh sed lectus gravida molestie ac sit amet est. Quisque sit amet tristique lectus, nec vehicula tellus.

        Aliquam erat volutpat. Aliquam semper tristique felis, id ullamcorper purus malesuada at. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam et mauris sed odio varius dapibus. Vivamus ac dictum arcu, ut porta est. Donec in leo eget leo fringilla congue vel sed lacus. Nam nulla risus, ultricies at gravida viverra, consectetur vitae velit. Praesent a justo venenatis, consequat ex a, tincidunt risus. Ut pellentesque dolor ac porttitor rhoncus. In convallis tortor ipsum, quis sollicitudin ipsum consectetur sed. In hac habitasse platea dictumst. In semper odio ac erat viverra auctor. Praesent scelerisque scelerisque facilisis. Donec rhoncus pulvinar tortor ut suscipit.

        Nulla quis lorem a massa luctus hendrerit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam erat volutpat. Suspendisse mollis mi et metus viverra, eu maximus tortor imperdiet. Nulla odio ligula, commodo sed auctor ut, eleifend in ipsum. Maecenas consequat eu ex eu molestie. Ut vulputate, lacus vitae auctor auctor, metus lacus commodo neque, vitae accumsan dolor sem id ex. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Duis sagittis lectus vitae sollicitudin pellentesque. Nullam condimentum metus ornare justo tristique ultricies.

        Praesent quis orci consequat, congue dui sit amet, dignissim lorem. Cras in viverra mauris. Curabitur ut risus non magna vestibulum dapibus ut eget felis. Maecenas pretium eros elit, id bibendum turpis mollis eu. Nunc nec blandit mi. Donec placerat, magna eget mollis ultricies, elit mi commodo velit, eget tempor nulla lorem eget arcu. Praesent vestibulum scelerisque lobortis. Ut semper efficitur semper.

        Vestibulum eget nulla venenatis, interdum nisl et, condimentum nibh. Phasellus quis tempus ligula, vitae accumsan ligula. Nullam lobortis eu purus vitae accumsan. Cras ultrices turpis a imperdiet tristique. Praesent vitae viverra tortor, eget maximus nunc. Mauris sit amet mattis ligula, quis elementum mi. Phasellus ultricies nibh non leo imperdiet accumsan. Maecenas venenatis arcu quis viverra efficitur. Curabitur iaculis ligula enim, sit amet convallis nisi egestas et. Donec dapibus aliquet ante nec rutrum. Donec tempus at ipsum sit amet tristique. Mauris vel elit vel ligula mollis mattis sit amet quis mauris. Etiam scelerisque in tellus ut commodo.

        Morbi ut posuere ex. In lacinia gravida volutpat. Nulla id facilisis orci, et vehicula odio. Phasellus euismod scelerisque magna, et lacinia libero porta nec. Praesent non turpis id sapien dictum tincidunt. In sollicitudin vestibulum sapien non aliquam. Nunc sodales ipsum a arcu fringilla, quis imperdiet erat consectetur.

        Curabitur ex justo, vestibulum eget hendrerit quis, sodales sed justo. Vestibulum bibendum gravida vestibulum. In vel enim blandit, rutrum urna eget, pharetra neque. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec feugiat augue a risus suscipit pulvinar. Pellentesque arcu lacus, aliquet non interdum et, maximus pretium magna. Cras molestie mauris eu purus pretium, eu aliquet lorem hendrerit. Nunc tempus leo in quam pulvinar, at maximus sem tristique. Donec rutrum tortor porttitor faucibus mollis. Praesent a neque est. Praesent suscipit velit sed libero dignissim viverra. Cras egestas urna at imperdiet auctor. Fusce ultrices facilisis velit in congue. Cras tincidunt elit ac ipsum faucibus egestas.

        Vivamus placerat ex odio, at ornare turpis volutpat in. Cras accumsan at risus nec pretium. Proin pretium, lacus eu lobortis tincidunt, mauris risus dictum nibh, aliquet iaculis quam ex hendrerit purus. Donec non molestie massa, a ultricies justo. Phasellus eu dui vitae ligula bibendum faucibus. Donec malesuada eget orci sed vehicula. Suspendisse potenti. Morbi volutpat eros et tempor venenatis. Etiam libero sem, pulvinar quis arcu id, lobortis suscipit dui. Phasellus blandit eleifend ligula, nec tempor magna ultrices sit amet.

        Nulla non neque felis. Maecenas egestas vel arcu tincidunt dictum. Sed sed varius nisi. Duis sagittis fermentum ipsum et congue. Mauris laoreet vel eros eget scelerisque. Aliquam elementum, tortor at malesuada auctor, dolor tortor accumsan justo, et tempus lectus justo nec quam. Vestibulum scelerisque, massa at tristique tincidunt, metus mauris lacinia ipsum, sed rhoncus libero velit id elit. Pellentesque nec lectus libero. Duis malesuada sodales ligula bibendum varius. Nulla tellus mauris, commodo facilisis tempor sed, euismod vitae erat. Proin efficitur varius ipsum, eget tincidunt nulla tempor a. Sed auctor turpis id orci fermentum, eget porta ante rutrum. Quisque eleifend mi non tellus vulputate posuere suscipit at nisl. Quisque commodo tempus justo vel rutrum. Mauris at hendrerit nisl, laoreet aliquet lacus.

        Ut eu sapien eget ligula vulputate suscipit vitae at nunc. Morbi elementum, enim nec ultricies viverra, sapien est lacinia turpis, vel aliquam orci ex sit amet dolor. Donec sed ipsum porta, scelerisque ante id, dignissim risus. Aliquam et dapibus felis. Suspendisse nisi ante, ultricies eget leo eu, auctor tempus arcu. Ut sit amet lorem nunc. Mauris tincidunt auctor dui, ut cursus mauris ultrices eget. Aliquam commodo lorem nec vulputate molestie. Nunc eu libero vitae massa congue facilisis eget nec leo. Pellentesque volutpat nunc vel leo fringilla, vel tincidunt orci ullamcorper. Integer lectus est, semper vel leo quis, dapibus interdum purus. Quisque elementum pretium odio aliquet scelerisque. Sed hendrerit pulvinar magna non tristique. Duis in arcu nec lectus accumsan tincidunt.

        Vestibulum convallis, lorem a rutrum lobortis, libero ligula sollicitudin lacus, id vestibulum purus tortor vitae arcu. Donec vitae nunc nec orci consequat lobortis. Vivamus eu ipsum ex. Pellentesque a mi lobortis, tincidunt nisl a, posuere augue. Suspendisse et est nunc. Proin id nisi volutpat, tempus sem at, gravida augue. Vivamus posuere tellus ut mauris sollicitudin finibus. Fusce sit amet tortor suscipit tortor vehicula molestie eu vitae augue. Praesent at ultrices urna, sed hendrerit arcu. Aliquam ac dui convallis, viverra turpis ut, consequat urna. Nam sed condimentum leo. Duis aliquam facilisis libero, nec suscipit neque bibendum vel.

        Vestibulum eleifend neque ac augue viverra interdum. Donec dignissim magna sit amet sagittis interdum. Nunc sagittis est fermentum, sodales dui ac, tristique velit. Sed mi ipsum, consequat et lorem at, porttitor posuere odio. Donec semper consequat erat, vel commodo tellus pellentesque vitae. Donec ante felis, tincidunt in mollis gravida, elementum sed nunc. Proin bibendum, ante non aliquet lobortis, lacus mauris finibus sapien, quis consequat tellus urna et dui.

        Vivamus imperdiet ipsum purus, vel molestie quam lacinia consectetur. Nullam pharetra ante vitae sapien condimentum tincidunt. Cras sagittis, lacus at finibus varius, leo diam venenatis purus, lacinia porttitor sem tortor sit amet dui. Praesent vitae dui fermentum, pharetra urna vel, consectetur nunc. Vestibulum ut suscipit tortor, in viverra tellus. Quisque id massa vel purus dictum malesuada ac sed arcu. Nunc a ipsum tempor, elementum ante quis, feugiat dolor. Phasellus condimentum velit ligula, ac laoreet arcu pulvinar eu. Morbi elementum convallis ipsum. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec vulputate bibendum massa vel tincidunt.

        Nunc ante nunc, porta ut tincidunt at, commodo in dolor. Duis tellus nisi, posuere id mollis sit amet, fringilla eu turpis. Aliquam erat volutpat. Vivamus sit amet feugiat nulla, a ullamcorper nunc. In tincidunt ex a porta imperdiet. Donec dapibus lorem feugiat ornare blandit. Etiam viverra eleifend ipsum, ac pharetra massa tincidunt id. Etiam congue nunc nisl, ut posuere tellus facilisis ut. Aenean semper, odio eu ultrices malesuada, dolor lorem pulvinar nisi, a scelerisque mauris libero eu orci.

        Maecenas consequat risus at augue condimentum, sit amet consequat arcu varius. Ut ipsum sem, sollicitudin vel dapibus euismod, posuere id elit. Aenean in mollis enim. Nullam risus lorem, sagittis in interdum nec, convallis ut magna. Duis pharetra molestie elit ac euismod. Sed posuere tincidunt eleifend. Etiam sagittis, libero et malesuada commodo, enim nisl dapibus sapien, a accumsan erat arcu et sem. Phasellus at dui eros. Nunc iaculis, orci semper facilisis commodo, ante lectus porttitor sem, non aliquam urna diam non lacus.

        Pellentesque mollis et ante ut pulvinar. Nam sem sapien, blandit sit amet libero nec, posuere ornare felis. Donec viverra neque neque, sit amet dictum ex finibus non. Donec ligula orci, dignissim vitae mi a, tempus accumsan erat. Donec a justo sollicitudin tellus hendrerit accumsan. Donec pretium, est id laoreet scelerisque, libero risus vehicula sem, eu tristique arcu augue fringilla neque. Vivamus feugiat scelerisque neque, sit amet euismod orci placerat at. In ac nisl leo. Sed ligula ante, pretium eget magna non, iaculis posuere leo.

        Vestibulum eget arcu varius ipsum commodo luctus id non orci. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce luctus venenatis ex, in pharetra tortor vehicula ut. Pellentesque eget elit id ligula ornare fringilla non non sem. Integer porttitor dignissim pulvinar. Praesent vel augue eu leo bibendum placerat. Suspendisse euismod, eros in laoreet finibus, sem sem facilisis diam, ut luctus purus enim eget arcu. Sed efficitur urna at risus congue, ut feugiat augue facilisis.
        """
    }
}


