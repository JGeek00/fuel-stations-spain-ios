import Foundation

func formattedNumber(value: Double, digits: Int = 2) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = digits
    numberFormatter.maximumFractionDigits = digits
    numberFormatter.locale = Locale.current
    
    return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
}
