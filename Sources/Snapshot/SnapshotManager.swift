//
//  SnapshotManager.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

import UIKit

@available(iOS 16.0, *)
class SnapshotManager {
    
    static var shared = SnapshotManager()
    
    static var debugMode = false
    static var deleteSnapshots = false
    static var recordNewSnapshots = false
    static var saveFailedSnapshots = false
    
    private let fileManager = FileManager.default
    private let snapshotImageType = "png"
    private let snapshotDirectoryName = "__snapshots__"
    
    private init() {}
    
    func checkRuntimeMode(image: UIImage, testFilePath: StaticString, named: String) -> String? {
        
        if SnapshotManager.debugMode {
            deleteSnapshots(testFilePath: testFilePath)
            saveSnapshot(image: image, named: named, testFilePath: testFilePath)
            return "DEBUG MODE: New snapshots saved."
        }
        
        if SnapshotManager.deleteSnapshots {
            deleteSnapshots(testFilePath: testFilePath)
            return "Snapshots successfully delete."
        }
        
        if SnapshotManager.recordNewSnapshots {
            deleteSnapshots(testFilePath: testFilePath)
            saveSnapshot(image: image, named: named, testFilePath: testFilePath)
            return "Successfully recorded new snapshots."
        }
    }
    
    func getSavedSnapshot(named: String, testFilePath: StaticString) -> UIImage? {
        
        let snapshotTestUrl = getSnapshotUrl(testFilePath: testFilePath, named: named)
        
        guard fileManager.fileExists(atPath: snapshotTestUrl.path()) else {
            return nil
        }
        
        guard let image = UIImage(contentsOfFile: snapshotTestUrl.path()) else {
            return nil
        }
        
        return image
    }
    
    func saveSnapshot(image: UIImage, named: String, testFilePath: StaticString) throws {

        let snapshotTestUrl = getSnapshotUrl(testFilePath: testFilePath, named: named)
        let snapshotTestDirectoryUrl = getSnapshotDirectoryUrl(testFilePath: testFilePath, named: named)
        
        try fileManager.createDirectory(at: snapshotTestDirectoryUrl, withIntermediateDirectories: true)
        
        try image.pngData()?.write(to: snapshotTestUrl)
    }
    
    func deleteSnapshots(testFilePath: StaticString) {
        fileManager.removeItem(at: getSnapshotDirectoryUrl(testFilePath: testFilePath, named: named))
    }
}

private extension SnapshotManager {
    
    func getSnapshotDirectoryUrl(testFilePath: StaticString, named: String) -> URL {
        let testFileUrl = URL(filePath: String(testFilePath))
        let testFileName = testFileUrl.lastPathComponent.split(separator: ".").first ?? "unknown"
        
        return testFileUrl
            .deletingLastPathComponent()
            .appending(path: snapshotDirectoryName)
            .appending(path: testFileName)
    }
    
    func getSnapshotUrl(testFilePath: StaticString, named: String) -> URL {
        
        let snapshotName = "\(named).\(snapshotImageType)"
        let snapshotTestDirectoryUrl = getSnapshotDirectoryUrl(testFilePath: testFilePath, named: named)
        
        return snapshotTestDirectoryUrl.appending(path: snapshotName)
    }
}
