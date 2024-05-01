//
//  TestView.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

import XCTest
import SwiftUI

class TestView: XCTestCase {
    
    func testView() {
        assertSnapshot(of: Text("Hello World!"), named: "hello-world")
    }
}
