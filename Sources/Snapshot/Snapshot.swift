// The Swift Programming Language
// https://docs.swift.org/swift-book

import XCTest
import SwiftUI

@available(iOS 16.0, *)
public extension XCTestCase {
    
    var recordSnapshots: Bool {
        get { SnapshotManager.recordNewSnapshots }
        set { SnapshotManager.recordNewSnapshots = newValue }
    }
    
    var debugMode: Bool {
        get { SnapshotManager.debugMode }
        set { SnapshotManager.debugMode = newValue }
    }
    
    var deleteSnapshots: Bool {
        get { SnapshotManager.deleteSnapshots }
        set { SnapshotManager.deleteSnapshots = newValue }
    }
    
    var saveFailedSnapshots: Bool {
        get { SnapshotManager.saveFailedSnapshots }
        set { SnapshotManager.saveFailedSnapshots = newValue }
    }
    
    @MainActor
    func assertSnapshot<V>(@ViewBuilder of view: () -> V, named: String, file: StaticString = #file, line: UInt = #line) where V : View {
        assertSnapshot(of: view(), named: named, file: file, line: line)
    }
    
    @MainActor
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
                XCTFail("Snapshots do not match.", file: file, line: line)
                return
            }
        
            try manager.saveSnapshot(image: newImage, named: named, testFilePath: file)
        } catch {
            XCTFail("Failed to save snapshot.", file: file, line: line)
        }
    }
}
