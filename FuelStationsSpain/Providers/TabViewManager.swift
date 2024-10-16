import SwiftUI

@MainActor
@Observable
class TabViewManager {
    static let shared = TabViewManager()
    
    var selectedTab: Enums.Tabs = .map
}
