//
//  Checkbox.swift
//  Time Tracker
//
//  Created by Mark McKeon on 3/2/2023.
//

import SwiftUI

struct Checkbox: View {
    @Binding var isChecked: Bool
    var shouldScale = true
    var size: CGSize = .init(width: 300, height: 300)
    var innerShapeSizeRatio: CGFloat = 1/3
    var animationDuration: Double = 0.75
    var strokeStyle: StrokeStyle = .init(lineWidth: 1, lineCap: .round, lineJoin: .round)
    @State private var outerTrimEnd: CGFloat = 0
    @State private var innerTrimEnd: CGFloat = 0
    @State private var strokeColor = Color.gray
    @State private var scale = 1.0
    var animateOnTap = false
    
    var body: some View {
        
        ZStack {
            Circle()
                .trim(from: 0.0, to: outerTrimEnd)
                .stroke(strokeColor, style: strokeStyle)
                .rotationEffect(.degrees(-90))
            Checkmark(isChecked: isChecked)
                   .trim(from: 0, to: innerTrimEnd)
                   .stroke(strokeColor, style: strokeStyle)
                   .frame(width: size.width * innerShapeSizeRatio, height: size.height * innerShapeSizeRatio)
        }
        .frame(width: size.width, height: size.height)
        .scaleEffect(scale)
        .onAppear() {
            animate()
            strokeColor = .red
        }
        .onTapGesture {
            self.isChecked.toggle()
                outerTrimEnd = 0
                innerTrimEnd = 0
                strokeColor = .blue
                scale = 1
                animate()
        }
    }
    
    func animate() {
        if shouldScale {
            withAnimation(.linear(duration: 0.4 * animationDuration)) {
                outerTrimEnd = 1.0
            }
            
            withAnimation(
                .linear(duration: 0.3 * animationDuration)
                .delay(0.4 * animationDuration)
            ) {
                innerTrimEnd = 1.0
            }
            
            withAnimation(
                .linear(duration: 0.2 * animationDuration)
                .delay(0.7 * animationDuration)
            ) {
                strokeColor = isChecked ? .green : .red
                scale = 1.1
            }
            
            withAnimation(
                .linear(duration: 0.1 * animationDuration)
                .delay(0.9 * animationDuration)
            ) {
                scale = 1
            }
        } else {
            withAnimation(.linear(duration: 0.5 * animationDuration)) {
                outerTrimEnd = 1.0
            }
            withAnimation(
                .linear(duration: 0.3 * animationDuration)
                .delay(0.5 * animationDuration)
            ) {
                innerTrimEnd = 1.0
            }
            
            withAnimation(
                .linear(duration: 0.2 * animationDuration)
                .delay(0.8 * animationDuration)
            ) {
                strokeColor = isChecked ? .green : .red
            }
        }
    }
}
