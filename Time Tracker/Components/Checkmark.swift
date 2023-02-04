//
//  Checkmark.swift
//  Time Tracker
//
//  Created by Mark McKeon on 3/2/2023.
//

import SwiftUI

struct Checkmark: Shape {
    var isChecked: Bool
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
 
        var path = Path()
                if isChecked {
                    path.move(to: .init(x: 0 * width, y: 0.5 * height))
                    path.addLine(to: .init(x: 0.4 * width, y: 1.0 * height))
                    path.addLine(to: .init(x: 1.0 * width, y: 0 * height))
                } else {
                    path.move(to: .init(x: 0 * width, y: 0 * height))
                    path.addLine(to: .init(x: 1.0 * width, y: 1.0 * height))
                    path.move(to: .init(x: 1.0 * width, y: 0 * height))
                    path.addLine(to: .init(x: 0 * width, y: 1.0 * height))
                }
                return path
    }
}
