//
//  TestView.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

import XCTest

class TestView: XCTestCase {
    
    func testView() {
        assertSnapshot(of: Text("Hello World!"), named: "hello-world")
    }
    
    func testViewDarkMode() {
        assertSnapshot(of: {
            Text("Hello World!")
                .preferredColorScheme(.dark)
        }, named: "hello-world")
    }
}
