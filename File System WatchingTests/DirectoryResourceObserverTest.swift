import XCTest
import UniformTypeIdentifiers

@testable import File_System_Watching

final class DirectoryResourceObserverTest: XCTestCase {
    
    private lazy var observedDirectoryURL = lazyFileDirectory()
    private lazy var directoryResourceObserver = lazyDirectoryObserver()
    private lazy var delegate = lazyDelegate()
    
    override func setUp() {
        super.setUp()
        
        print("_______________________________")
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        defer { print("_______________________________") }
        
        directoryResourceObserver.tearDown()
        
        let filePathsToDelete = try FileManager.default.contentsOfDirectory(atPath: observedDirectoryURL.path)
        
        for delete in filePathsToDelete {
            try FileManager.default.removeItem(atPath: observedDirectoryURL.appending(path: delete).path)
        }
    }
}

// MARK: Register

extension DirectoryResourceObserverTest {

    func testAddDelegate_NotJoiningInProgress() {
        directoryResourceObserver.add(delegate)
        
        doVerify([
            // Not joined in progress
        ])
    }
    
    func testRegistration_ReturnsDirectoryWithEmptyDirectory() {
        directoryResourceObserver.add(delegate, joinInProgress: true)
        
        doVerify([
            .didRegister(
                observedDirectory: observedDirectoryURL.lastPathComponent,
                files: []
            )
        ])
    }
    
    func testInsertFile_ThenRegisteringInProgressReturnsThatFile() throws {
        let fileName = "foo.json"
        
        try insertFile(with: fileName, type: .json, fileContents: "{ }")
        
        directoryResourceObserver.add(delegate, joinInProgress: true)
        
        doVerify([
            .didRegister(
                observedDirectory: observedDirectoryURL.lastPathComponent,
                files: [
                    fileName
                ]
            )
        ])
    }
    
    func testInsertFiles_ThenRegisteringInProgressReturnsAllFile() throws {
        let fileName = "foo.json"
        let fileNameTwo = "bar.json"
        
        try insertFile(with: fileName, type: .json, fileContents: "{ }")
        try insertFile(with: fileNameTwo, type: .json, fileContents: "{ }")
        
        directoryResourceObserver.add(delegate, joinInProgress: true)
        
        doVerify([
            .didRegister(
                observedDirectory: observedDirectoryURL.lastPathComponent,
                files: [
                    fileName,
                    fileNameTwo
                ]
            )
        ])
    }
}

// MARK: Update File Event

extension DirectoryResourceObserverTest {
    
    func testUpdateFile_DelegateReceivesCallback_ForContentsChanged() throws {
        let fileName = "foo.json"
        
        try insertFile(with: fileName, type: .json, fileContents: "{ }")

        directoryResourceObserver.add(delegate)
        
        try updateFile(named: fileName, with: "{ [] }")
        doVerify([
            .didReceiveUpdateFor(
                fileNamed: fileName,
                contentsChanged: true,
                attributesChanged: [
                    // Due to atomic option
                    .creationDate,
                    .systemFileNumber,
                    .size,
                    .modificationDate
                ]
            )
        ])
    }
}

// MARK: Delete Event

extension DirectoryResourceObserverTest {
    
    // Un-reliable - verification fires before the `DispatchSource` is indicated to have 
    func testFileDeleteEvent_DelegateReceivesCallback_ForDeletedFile() throws {
        let firstFileName = "FirstFileName.json"
        let secondFileName = "SecondFileName.txt"
        let thirdFileName = "ThirdMapFile.xml"
        
        try insertFile(with: firstFileName, type: .json, fileContents: " { } ")
        try insertFile(with: secondFileName, type: .text, fileContents: " Lorem Ipsum ")
        try insertFile(with: thirdFileName, type: .xml, fileContents: "  ")

        // Allow the queue to process the insertions and prevent the delegate from
        // catching read the insertion events.
        directoryResourceObserver.queue.sync {
        }
        
        directoryResourceObserver.add(delegate)
        
        try deleteFile(named: secondFileName)
     
        doVerify([
            .didDelete(fileNamed: secondFileName)
        ])
        
        // Force a re-register to verify that the correct files have been removed.
        directoryResourceObserver.add(delegate, joinInProgress: true)
        
        doVerify([
            .didRegister(
                observedDirectory: observedDirectoryURL.lastPathComponent,
                files: [
                    firstFileName,
                    thirdFileName
                ]
            )
        ])
    }
}

extension DirectoryResourceObserverTest {
    
    private func doVerify(_ expectedCallbacks: [MockDirectoryObserverDelegate.Callback]) {
        // Let everything wrap up before trying to read.
        directoryResourceObserver.queue.sync {
        }

        delegate.verifyCallbacks(against: expectedCallbacks)
    }
}

extension DirectoryResourceObserverTest {
    
    private func insertFile(with name: String, type: UTType, fileContents: String) throws {
        let fileContents = try XCTUnwrap(fileContents.data(using: .utf8))
        
        FileManager.default.createFile(atPath: observedDirectoryURL.appending(path: name).path, contents: fileContents)
    }
    
    private func updateFile(named: String, with contents: String) throws {
        let url = observedDirectoryURL.appending(path: named)
        let originalData = directoryResourceObserver.fileManager.contents(atPath: url.path)

        guard
            var originalData,
            let newDataToAppend = contents.data(using: .utf8)
        else {
            return
        }

        directoryResourceObserver.queue.sync {
            do {
                originalData.append(newDataToAppend)
                try originalData.write(to: url, options: .atomic)
            } catch {
                XCTFail("Encountered error when updating file: \(error)")
            }
        }
    }
    
    private func deleteFile(named name: String) throws {
        
        directoryResourceObserver.queue.sync {
            do {
                let url = self.observedDirectoryURL.appending(path: name)
                
                try FileManager.default.removeItem(atPath: url.path)
            } catch {
                XCTFail("Encountered error when deleting file: \(error)")
            }
        }
    }
}

extension DirectoryResourceObserverTest {
    
    private func lazyFileDirectory() -> URL {
        return URL(filePath: NSTemporaryDirectory())
    }
    
    private func lazyDirectoryObserver() -> DirectoryResourceObserver {
        return DirectoryResourceObserver(
            fileResource: FileResource(
                url: observedDirectoryURL
            )
        )
    }
    
    private func lazyDelegate() -> MockDirectoryObserverDelegate {
        return MockDirectoryObserverDelegate(queue: directoryResourceObserver.queue)
    }
}
