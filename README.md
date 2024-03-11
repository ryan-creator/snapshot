# SwiftUI Snapshot Testing

SwiftUI Snapshot Testing is a Swift package that facilitates snapshot testing for SwiftUI views. It allows you to easily capture and compare snapshots of SwiftUI views, helping you identify any unintended changes in the UI.

> [!WARNING]  
> **Only suitable for iOS 16 and above**

## Table of Contents

-   [Installation](#installation)
-   [Usage](#usage)
-   [How to Test Views](#how-to-test-views)
-   [Snapshot Files Location](#snapshot-files-location)
-   [License](#license)

## Installation <a name="installation"></a>

### Xcode

To integrate SwiftUI Snapshot Testing into your Xcode project using Swift Package Manager, follow these steps:

1. Open your Xcode project.
2. Navigate to "File" -> "Swift Packages" -> "Add Package Dependency..."
3. Paste the package URL `https://github.com/ryan-creator/snapshot.git` and click "Next."
4. Choose the version rule according to your preference and click "Next."
5. Click "Finish."

Now you can import the package in your Swift files where you want to perform snapshot testing.

### Swift Package Manager (SPM)

If you want to use Snapshot in any other project that uses SPM, add the package as a dependency in Package.swift:

```swift
dependencies: [
    .package(
        name: "Snapshot",
        url: "https://github.com/ryan-creator/snapshot.git",
        from: "1.1.0"
    ),
]
```

Next, add Snapshot as a dependency of your test target:

```swift
targets: [
  .target(name: "MyApp"),
  .testTarget(
    name: "MyAppTests",
    dependencies: ["MyApp", "Snapshot", ...]
  )
]
```

## Usage <a name="usage"></a>

SwiftUI Snapshot Testing extends XCTestCase with convenient methods for snapshot testing. You can use it to assert that a SwiftUI view matches a saved snapshot or to update snapshots when needed.

> [!IMPORTANT]  
> The tests must be run on the main thread so please attach `@MainActor` to the test or its parent class.

```swift
import XCTest
import Snapshot

class YourSnapshotTests: XCTestCase {

    @MainActor
    func testYourView() {
        // Use assertSnapshot to compare or update snapshots
        assertSnapshot(of: YourSwiftUIView(), named: "YourSnapshotName")
    }
}
```

### Available Configuration Options

You can customise the behaviour of SwiftUI Snapshot Testing by modifying the configuration flags available on XCTestCase.

> [!IMPORTANT]  
> If any of the configuration flags are set to `true` during the test execution, the tests will fail. This ensures that you do not accidentally leave any of the flags set to `true`, which could potentially affect the reliability of your snapshot tests.

> [!WARNING]
>
> #### Warning: Flags' Global Impact
>
> Setting any of the configuration flags to `true` will globally impact all tests. However, it's important to note that the flags only take effect when the corresponding tests are executed. Be careful what tests are run when a flag is set to true.

#### `recordSnapshots`

When set to `true`, it records new snapshots, overwriting existing ones.

#### `debugMode`

When set to `true`, it deletes existing snapshots and writes new ones.

#### `deleteSnapshots`

When set to `true`, it deletes existing snapshots.

#### `saveFailedSnapshots`

When set to `true`, it saves snapshots that do not match with a "-FAILED" suffix.

```swift
class YourSnapshotTests: XCTestCase {

    @MainActor
    func testYourView() {
        // Configure snapshot testing options
        recordSnapshots = true
        saveFailedSnapshots = true

        // Use assertSnapshot to compare or update snapshots
        assertSnapshot(of: YourSwiftUIView(), snapshotName: "YourSnapshotName")
    }
}

```

## How to Test Views <a name="how-to-test-views"></a>

To test your SwiftUI views, use the assertSnapshot method provided by XCTestCase. This method captures a snapshot of the provided SwiftUI view and compares it to the previously saved snapshot.

```swift
class YourSnapshotTests: XCTestCase {

    @MainActor
    func testYourView() {
        // Use assertSnapshot to compare or update snapshots
        assertSnapshot(of: YourSwiftUIView(), named: "YourSnapshotName")
    }
}
```

## Snapshot Files Location <a name="snapshot-files-location"></a>

Snapshot files are stored in a directory relative to the test file location. The directory is named **snapshots**. When you run your tests, this directory will be created if it doesn't exist.

Example directory structure:

```
YourProject
|-- Sources
|-- Tests
|   |-- YourSnapshotTests.swift
|       |-- _snapshots__
|       |   |-- YourSnapshotName1.png
|       |   |-- YourSnapshotName2.png
|       |-- SnapshotTests1
|       |-- SnapshotTests2
```

## License <a name="license"></a>

This library is released under the MIT license. See [LICENSE](https://github.com/pointfreeco/swift-snapshot-testing/blob/main/LICENSE) for details.
