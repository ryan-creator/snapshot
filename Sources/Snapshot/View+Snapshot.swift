//
//  View+Snapshot.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

#if !os(macOS)

import SwiftUI

@available(iOS 16.0, *)
extension View {
    
    @MainActor
    func snapshot() -> UIImage? {
        ImageRenderer(content: self).uiImage
    }
}

#endif
