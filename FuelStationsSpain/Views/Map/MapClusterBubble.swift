import SwiftUI

struct MapClusterBubble: View {
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Text(verbatim: "\(count)")
            .fontSize(16)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frameDynamicSize(width: diameter, height: diameter)
            .background(
                Circle().fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.markerGradientStart, Color.markerGradientEnd]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            .overlay(Circle().stroke(Color.background, lineWidth: 2))
            .shadow(color: .black.opacity(0.3), radius: 5)
            .onTapGesture(perform: onTap)
    }

    private var diameter: CGFloat {
        min(44 + CGFloat(count / 10) * 4, 64)
    }
}
