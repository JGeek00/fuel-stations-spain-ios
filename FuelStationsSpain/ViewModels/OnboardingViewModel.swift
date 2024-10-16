import SwiftUI

@MainActor
@Observable
class OnboardingViewModel {    
    var showOnboarding = false
    var selectedTab = 0
    
    func finishOnboarding() {
        UserDefaults.shared.set(true, forKey: StorageKeys.onboardingCompleted)
        self.showOnboarding = false
    }
}
