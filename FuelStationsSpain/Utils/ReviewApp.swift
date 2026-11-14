import Foundation
import StoreKit

/// Decisión pura de pedir review: >=24h desde el primer lanzamiento y no se
/// ha pedido antes. El efecto StoreKit queda fuera, en `requestAppReview`.
func shouldRequestReview(now: TimeInterval, firstLaunchDate: TimeInterval, hasRequestedReview: Bool) -> Bool {
    (now - firstLaunchDate) >= 24 * 60 * 60 && !hasRequestedReview
}

@MainActor
func requestAppReview() {
    let firstLaunchDate: Double? = UserDefaults.shared.double(forKey: StorageKeys.appFirstLaunch)
    let hasRequestedReview: Bool? = UserDefaults.shared.bool(forKey: StorageKeys.hasRequestedReview)
    
    let currentDate = Date().timeIntervalSince1970
            
    if firstLaunchDate == 0 {
        UserDefaults.shared.setValue(currentDate, forKey: StorageKeys.appFirstLaunch)
    } else {
        guard let firstLaunchDate = firstLaunchDate else { return }
        if shouldRequestReview(now: currentDate, firstLaunchDate: firstLaunchDate, hasRequestedReview: hasRequestedReview == true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                #if os(iOS)
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                SKStoreReviewController.requestReview(in: windowScene)
                UserDefaults.shared.setValue(true, forKey: StorageKeys.hasRequestedReview)
                #endif
            }
        }
    }
}
