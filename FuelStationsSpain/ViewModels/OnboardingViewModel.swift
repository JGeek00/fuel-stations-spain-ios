import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    static let shared = OnboardingViewModel()
    
    @Published var showOnboarding = false
    @Published var selectedTab = 0
    
    func finishOnboarding() {
        UserDefaults.shared.set(true, forKey: StorageKeys.onboardingCompleted)
        self.showOnboarding = false
    }
}
