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

fileprivate struct FontSize: ViewModifier {
    var size: CGFloat
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private func fontMultiplier() -> CGFloat {
        switch dynamicTypeSize {
            case .xSmall: return 0.8
            case .small: return 0.9
            case .medium: return 0.95
            case .large: return 1.0 // base size
            case .xLarge: return 1.05
            case .xxLarge: return 1.1
            case .xxxLarge: return 1.15
            case .accessibility1: return 1.2
            case .accessibility2: return 1.3
            case .accessibility3: return 1.4
            case .accessibility4: return 1.5
            case .accessibility5: return 1.6
            default: return 1.0 // Fallback to base size if not matched
            }
        }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size * fontSizeMultiplier(for: dynamicTypeSize)))
    }
}

fileprivate struct FrameDynamicSize: ViewModifier {
    var width: CGFloat?
    var height: CGFloat?
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    func body(content: Content) -> some View {
        content
            .frame(
                width: width != nil ? width! * fontSizeMultiplier(for: dynamicTypeSize) : nil,
                height: height != nil ? height! * fontSizeMultiplier(for: dynamicTypeSize) : nil
            )
    }
}

extension View {
    func customBackgroundWithMaterial() -> some View {
        modifier(ConditionalBackgroundWithMaterial())
    }
    
    func fontSize(_ size: CGFloat) -> some View {
        modifier(FontSize(size: size))
    }
    
    func frameDynamicSize(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        modifier(FrameDynamicSize(width: width, height: height))
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func condition<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        transform(self)
    }
    
    @ViewBuilder
    func cardCornerRadius() -> some View {
        if #available(iOS 26.0, *) {
            clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
