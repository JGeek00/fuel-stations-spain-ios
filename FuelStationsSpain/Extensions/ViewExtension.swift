import Foundation
import SwiftUI

fileprivate struct ConditionalBackgroundWithMaterial: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .background(Material.ultraThick)
        }
        else {
            content
                .background(Color.white)
        }
    }
}

extension View {
    func customBackgroundWithMaterial() -> some View {
        modifier(ConditionalBackgroundWithMaterial())
    }
}
