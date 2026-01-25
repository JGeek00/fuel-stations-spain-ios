import SwiftUI

struct MapOverlayLeftButtons: View {
    init() {}
    
    @EnvironmentObject private var mapManager: MapManager
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        if mapManager.loading == true || mapManager.error != nil {
            if #available(iOS 26.0, *) {
                Group {
                    Button {
                        mapManager.showErrorAlert.toggle()
                    } label: {
                        Group {
                            if mapManager.loading == true {
                                ProgressView()
                                    .fontSize(24)
                            }
                            else {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .fontSize(22)
                                    .foregroundStyle(Color.red)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .buttonStyle(.glass)
                    .frameDynamicSize(width: 40, height: 40)
                    .disabled(mapManager.loading)
                }
                .offset(x: 12 * fontSizeMultiplier(for: dynamicTypeSize), y: 50 * fontSizeMultiplier(for: dynamicTypeSize))
                .transition(.opacity)
            }
            else {
                Group {
                    Button {
                        mapManager.showErrorAlert.toggle()
                    } label: {
                        Group {
                            if mapManager.loading == true {
                                ProgressView()
                                    .fontSize(24)
                            }
                            else {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .fontSize(22)
                                    .foregroundStyle(Color.red)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .frameDynamicSize(width: 40, height: 40)
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                    .disabled(mapManager.loading)
                }
                .offset(x: 12 * fontSizeMultiplier(for: dynamicTypeSize), y: 50 * fontSizeMultiplier(for: dynamicTypeSize))
                .transition(.opacity)
            }
           
        }
    }
}
