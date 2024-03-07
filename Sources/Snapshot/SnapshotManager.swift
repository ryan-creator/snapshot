//
//  SnapshotManager.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

import UIKit

@available(iOS 16.0, *)
class SnapshotManager {
    
    public static var shared = SnapshotManager()
    
    public static var debugMode = false
    public static var deleteSnapshots = false
    public static var overrideSnapshots = false
    public static var deleteAllSnapshots = false
    public static var recordNewSnapshots = false
    
    private let snapshotDirectoryName = "__snapshots__"
    
    private init() {}
    
    func getSavedSnapshot(named: String, testFilePath: StaticString) -> UIImage? {
        
        let snapshotTestUrl = getSnapshotUrl(testFilePath: testFilePath, named: named)
        
        guard FileManager.default.fileExists(atPath: snapshotTestUrl.path()) else {
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
        
        try FileManager.default.createDirectory(at: snapshotTestDirectoryUrl, withIntermediateDirectories: true)
        
        try image.pngData()?.write(to: snapshotTestUrl)
    }
    
    private func getSnapshotUrl(testFilePath: StaticString, named: String) -> URL {
        
        let snapshotName = "\(named).png"
        let snapshotTestDirectoryUrl = getSnapshotDirectoryUrl(testFilePath: testFilePath, named: named)
        
        return snapshotTestDirectoryUrl.appending(path: snapshotName)
    }
    
    private func getSnapshotDirectoryUrl(testFilePath: StaticString, named: String) -> URL {
        let testFileUrl = URL(filePath: String(testFilePath))
        let testFileName = testFileUrl.lastPathComponent.split(separator: ".").first ?? "unknown"
        
        return testFileUrl
            .deletingLastPathComponent()
            .appending(path: snapshotDirectoryName)
            .appending(path: testFileName)
    }
}
