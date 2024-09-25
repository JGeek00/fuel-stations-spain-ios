import Foundation

func formattedNumber(value: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.locale = Locale.current
    
    return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
}
