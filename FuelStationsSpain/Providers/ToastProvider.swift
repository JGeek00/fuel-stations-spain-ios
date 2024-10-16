import SwiftUI
import AlertToast

@MainActor
@Observable
class ToastProvider: ObservableObject {
    static let shared = ToastProvider()
    
    var presenting = false
    var toast: AlertToast? = nil
    
    func showToast(icon: String, title: String) {
        self.toast = AlertToast(type: .systemImage(icon, .foreground.opacity(0.7)), title: title, style: .style(titleColor: .foreground.opacity(0.7)))
        self.presenting = true
    }
}
