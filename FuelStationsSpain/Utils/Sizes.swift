import SwiftUI

func fontSizeMultiplier(for typeSize: DynamicTypeSize) -> CGFloat {
    switch typeSize {
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
