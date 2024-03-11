//
//  String+StaticStringInit.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

import Foundation

extension String {
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}
