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
    
    var overrideSnapshots: Bool {
        get { SnapshotManager.overrideSnapshots }
        set { SnapshotManager.overrideSnapshots = newValue }
    }
    
    var debugMode: Bool {
        get { SnapshotManager.debugMode }
        set { SnapshotManager.debugMode = newValue }
    }
    
    var deleteSnapshots: Bool {
        get { SnapshotManager.deleteSnapshots }
        set { SnapshotManager.deleteSnapshots = newValue }
    }
    
    var deleteAllSnapshots: Bool {
        get { SnapshotManager.deleteAllSnapshots }
        set { SnapshotManager.deleteAllSnapshots = newValue }
    }
    
    @MainActor
    func assertSnapshot<V>(@ViewBuilder of view: () -> V, named: String, file: StaticString = #file, line: UInt = #line) where V : View {
        assertSnapshot(of: view(), named: named, file: file, line: line)
    }
    
    @MainActor
    func assertSnapshot<V>(of view: V, named: String, file: StaticString = #file, line: UInt = #line) where V : View {
        
        if recordSnapshots {
            recordSnapshots(of: view, named: named, file: file, line: line)
            return
        }
        
        let manager = SnapshotManager.shared
        
        guard let newImage = view.uiImage() else {
            XCTFail("Failed to create a snapshot image.", file: file, line: line)
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
    
    @MainActor
    private func recordSnapshots<V>(of view: V, named: String, file: StaticString = #file, line: UInt = #line) where V : View {
        
        let manager = SnapshotManager.shared
        
        guard let newImage = view.uiImage() else {
            XCTFail("Failed to create a snapshot image.", file: file, line: line)
            return
        }
        
        do {
            try manager.saveSnapshot(image: newImage, named: named, testFilePath: file)
            XCTFail("Successfully recorded new snapshot.", file: file, line: line)
        } catch {
            XCTFail("Failed to save snapshot.", file: file, line: line)
        }
    }
}

@available(iOS 16.0, *)
extension View {
    
    @MainActor
    func uiImage() -> UIImage? {
        ImageRenderer(content: self).uiImage
    }
}

extension String {
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}
