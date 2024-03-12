//
//  View+Snapshot.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

import SwiftUI

@available(iOS 16.0, *)
extension View {
    
    @MainActor
    func snapshot() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.colorMode = .extendedLinear
        return renderer.uiImage
    }
}
