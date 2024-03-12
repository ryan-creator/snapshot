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
    
    func checkRuntimeMode(image: UIImage, testFilePath: StaticString, named: String) throws -> String? {
        
        if SnapshotManager.debugMode {
            try deleteSnapshots(testFilePath: testFilePath, named: named)
            try saveSnapshot(image: image, named: named, testFilePath: testFilePath)
            return "DEBUG MODE: New snapshots saved."
        }
        
        if SnapshotManager.deleteSnapshots {
            try deleteSnapshots(testFilePath: testFilePath, named: named)
            return "Snapshots successfully delete."
        }
        
        if SnapshotManager.recordNewSnapshots {
            try deleteSnapshots(testFilePath: testFilePath, named: named)
            try saveSnapshot(image: image, named: named, testFilePath: testFilePath)
            return "Successfully recorded new snapshots."
        }
        
        return nil
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
        let snapshotTestDirectoryUrl = getSnapshotDirectoryUrl(testFilePath: testFilePath)
        
        try fileManager.createDirectory(at: snapshotTestDirectoryUrl, withIntermediateDirectories: true)
        
        try image.pngData()?.write(to: snapshotTestUrl)
    }
    
    func deleteSnapshots(testFilePath: StaticString, named: String) throws {
        
        let snapshotURL = getSnapshotUrl(testFilePath: testFilePath, named: named)
        let snapshotFailureURL = getSnapshotFailedUrl(testFilePath: testFilePath, named: named)
        
        if fileManager.fileExists(atPath: snapshotURL.path()) {
            try fileManager.removeItem(at: snapshotURL)
        }
        
        if fileManager.fileExists(atPath: snapshotFailureURL.path()) {
            try fileManager.removeItem(at: snapshotFailureURL)
        }
    }
}

@available(iOS 16.0, *)
private extension SnapshotManager {
    
    func getSnapshotDirectoryUrl(testFilePath: StaticString) -> URL {
        let testFileUrl = URL(filePath: String(testFilePath))
        let testFileName = testFileUrl.lastPathComponent.split(separator: ".").first ?? "unknown"
        
        return testFileUrl
            .deletingLastPathComponent()
            .appending(path: snapshotDirectoryName)
            .appending(path: testFileName)
    }
    
    func getSnapshotUrl(testFilePath: StaticString, named: String) -> URL {
        
        let snapshotName = "\(named).\(snapshotImageType)"
        let snapshotTestDirectoryUrl = getSnapshotDirectoryUrl(testFilePath: testFilePath)
        
        return snapshotTestDirectoryUrl.appending(path: snapshotName)
    }
    
    func getSnapshotFailedUrl(testFilePath: StaticString, named: String) -> URL {
        
        let snapshotName = "\(named)-FAILED.\(snapshotImageType)"
        let snapshotTestDirectoryUrl = getSnapshotDirectoryUrl(testFilePath: testFilePath)
        
        return snapshotTestDirectoryUrl.appending(path: snapshotName)
    }
}
