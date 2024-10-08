import Foundation
import AlertToast

@MainActor
class ToastProvider: ObservableObject {
    static let shared = ToastProvider()
    
    @Published var presenting = false
    @Published var toast: AlertToast? = nil
    
    func showToast(icon: String, title: String) {
        self.toast = AlertToast(type: .systemImage(icon, .foreground.opacity(0.7)), title: title, style: .style(titleColor: .foreground.opacity(0.7)))
        self.presenting = true
    }
}
