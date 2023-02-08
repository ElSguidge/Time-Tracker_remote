//
//  CustomButton.swift
//  Time Tracker
//
//  Created by Mark McKeon on 7/2/2023.
//

import SwiftUI

struct CustomButton: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct LargeButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "003459"))
            .foregroundColor(.white)
            .mask(RoundedCorner(radius: 20, corners: [.topRight, .bottomLeft, .bottomRight]))
            .mask(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color(hex: "003459").opacity(0.5), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func largeButton() -> some View {
        modifier(LargeButton())
    }
}

