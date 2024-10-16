import SwiftUI

struct ChartsSettings: View {
    
    @AppStorage(StorageKeys.chartAnnotationMode, store: UserDefaults.shared) private var chartAnnotationMode = Defaults.chartAnnotationMode
    
    var body: some View {
        List {
            Section {
                Picker("Value indicator mode", selection: $chartAnnotationMode) {
                    Text("Outside the chart")
                        .tag(Enums.ChartAnnotationMode.outsideChart)
                    Text("Floating tooltip")
                        .tag(Enums.ChartAnnotationMode.tooltip)
                }
            } footer: {
                Text("Using the floating tooltip can cause performance issues.")
            }
        }
        .navigationTitle("Charts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChartsSettings()
}
