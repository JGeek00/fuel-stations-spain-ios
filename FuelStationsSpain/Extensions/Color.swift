import SwiftUI
#if canImport(UIKit)
import UIKit
typealias CompatibleColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias CompatibleColor = NSColor
#endif

extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    func toHex() -> String? {
        #if canImport(UIKit)
        let compatibleColor = CompatibleColor(self)
        #elseif canImport(AppKit)
        guard let cgColor = self.cgColor else { return nil }
        guard let compatibleColor = CompatibleColor(cgColor: cgColor) else { return nil }
        #endif
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        compatibleColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        guard (0...1).contains(red), (0...1).contains(green), (0...1).contains(blue), (0...1).contains(alpha) else {
            return nil
        }
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
