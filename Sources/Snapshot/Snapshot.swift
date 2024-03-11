// The Swift Programming Language
// https://docs.swift.org/swift-book

import XCTest
import SwiftUI

@available(iOS 16.0, *)
public extension XCTestCase {
    
    /// Record new snapshots, this will overwrite any existing snapshots.
    var recordSnapshots: Bool {
        get { SnapshotManager.recordNewSnapshots }
        set { SnapshotManager.recordNewSnapshots = newValue }
    }
    
    /// Delete the existing snapshots and write new snapshots.
    var debugMode: Bool {
        get { SnapshotManager.debugMode }
        set { SnapshotManager.debugMode = newValue }
    }
    
    /// Delete existing snapshots
    var deleteSnapshots: Bool {
        get { SnapshotManager.deleteSnapshots }
        set { SnapshotManager.deleteSnapshots = newValue }
    }
    
    ///  Save snapshots that do not match. The snapshots are saved under the same
    ///  name as the standard snapshots but with the "...-FAILED" attached to the name.
    var saveFailedSnapshots: Bool {
        get { SnapshotManager.saveFailedSnapshots }
        set { SnapshotManager.saveFailedSnapshots = newValue }
    }
    
    @MainActor
    /// Assert in SwiftUI view against a saved snapshot which is identified by the `named` parameter.
    /// - Parameters:
    ///   - of: The closure that contains the view to snapshot.
    ///   - named: The name of the snapshot file to compare against and or save the new snapshot under.
    ///   - file: The url string of the test file that this function will exist in. Please leave empty because
    ///   this is used to locate the saved snapshot directory.
    ///   - line: The line this function is located at. This is to attach the failure message to the correct assertion.
    func assertSnapshot<V>(@ViewBuilder of view: () -> V, named: String, file: StaticString = #file, line: UInt = #line) where V : View {
        assertSnapshot(of: view(), named: named, file: file, line: line)
    }
    
    @MainActor
    /// Assert in SwiftUI view against a saved snapshot which is identified by the `named` parameter.
    /// - Parameters:
    ///   - view: The view to snapshot.
    ///   - named: The name of the snapshot file to compare against and or save the new snapshot under.
    ///   - file: The url string of the test file that this function will exist in. Please leave empty because
    ///   this is used to locate the saved snapshot directory.
    func assertSnapshot<V>(of view: V, named: String, file: StaticString = #file, line: UInt = #line) where V : View {
        
        let manager = SnapshotManager.shared
        
        guard let newImage = view.snapshot() else {
            XCTFail("Failed to create a snapshot image.", file: file, line: line)
            return
        }
        
        if let message = manager.checkRuntimeMode(image: newImage, testFilePath: file, named: named) {
            XCTFail(message, file: file, line: line)
            return
        }
        
        do {
        
            guard let previousImage = manager.getSavedSnapshot(named: named, testFilePath: file) else {
                try manager.saveSnapshot(image: newImage, named: named, testFilePath: file)
                XCTFail("Failed to find an existing snapshot.", file: file, line: line)
                return
            }
            
            if newImage.pngData() != previousImage.pngData() {
                
                if saveFailedSnapshots {
                    try manager.saveSnapshot(image: newImage, named: "\(named)-FAILED", testFilePath: file)
                }
                
                
                XCTFail("Snapshots do not match.", file: file, line: line)
                return
            }
        
            try manager.saveSnapshot(image: newImage, named: named, testFilePath: file)
        } catch {
            XCTFail("Failed to save snapshot.", file: file, line: line)
        }
    }
}
