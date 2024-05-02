//
//  SnapshotManager.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

#if !os(macOS)
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
            
            guard let savedImage = getSavedSnapshot(named: named, testFilePath: testFilePath) else {
                return "DEBUG MODE: Failed to find an existing snapshot."
            }
            
            if image.pngData() != savedImage.pngData() {
                
                if SnapshotManager.saveFailedSnapshots {
                    try saveSnapshot(image: image, named: "\(named)-FAILED", testFilePath: testFilePath)
                }
                
                return "DEBUG MODE: Snapshots do not match."
            }
            
            
            return "DEBUG MODE: New snapshots saved and matches."
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
    
    func createFailedSnapshotComparison(savedSnapshot: UIImage, newSnapshot: UIImage) -> UIImage {
        
        let verticalSpacing: CGFloat = 8
        let horizontalSpacing: CGFloat = 4
        let fontSize: CGFloat = 14
        let headerSpacing = fontSize + horizontalSpacing
        
        let size = CGSize(
            width: (savedSnapshot.size.width * 2) + verticalSpacing,
            height: (savedSnapshot.size.height * 2) + (headerSpacing * 2))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        var savedTitlePoint: CGPoint {
            CGPoint(x: 0, y: 0)
        }
        
        var savedImagePoint: CGPoint {
            CGPoint(x: 0, y: headerSpacing)
        }
        
        var newTitlePoint: CGPoint {
            CGPoint(x: savedSnapshot.size.width + verticalSpacing, y: 0)
        }
        
        var newImagePoint: CGPoint {
            CGPoint(x: savedSnapshot.size.width + verticalSpacing, y: headerSpacing)
        }
        
        var overlayTitlePoint: CGPoint {
            CGPoint(x: 0, y: savedSnapshot.size.height + headerSpacing)
        }
        
        var overlayImagePoint: CGPoint {
            CGPoint(x: 0, y: savedSnapshot.size.height + (headerSpacing * 2))
        }
        
        return renderer.image { context in
            
            // Draw saved snapshot with title "Saved"
            let savedTitle = "Saved Snapshot"
            savedTitle.draw(at: savedTitlePoint, withAttributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ])
            savedSnapshot.draw(in: CGRect(origin: savedImagePoint, size: savedSnapshot.size))
            
            // Draw new snapshot beside the first with title "New"
            let newTitle = "New Snapshot"
            newTitle.draw(at: newTitlePoint, withAttributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ])
            newSnapshot.draw(in: CGRect(origin: newImagePoint, size: newSnapshot.size))
            
            // Draw new snapshot on top of the saved snapshot for comparison with 50% opacity and the title "Overlay"
            let overlayTitle = "Both Overlayed"
            overlayTitle.draw(at: overlayTitlePoint, withAttributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ])
            savedSnapshot.draw(in: CGRect(origin: overlayImagePoint, size: savedSnapshot.size))
            newSnapshot.draw(in: CGRect(origin: overlayImagePoint, size: newSnapshot.size), blendMode: .normal, alpha: 0.5)
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

#endif
