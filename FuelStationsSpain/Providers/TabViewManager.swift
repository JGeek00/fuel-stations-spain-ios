import Foundation

@MainActor
class TabViewManager: ObservableObject {
    static let shared = TabViewManager()
    
    @Published var selectedTab: Enums.Tabs = .map
}
