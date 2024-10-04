import Foundation

extension Double {
    func truncate()-> Int {
        return Int(floor(pow(10.0, 0) * self)/pow(10.0, 0))
    }
}
