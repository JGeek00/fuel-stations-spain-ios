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
    
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
