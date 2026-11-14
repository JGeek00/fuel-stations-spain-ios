import SwiftUI

struct StationSidePanel: View {

    @EnvironmentObject private var mapManager: MapManager

    @State private var dragOffset: CGFloat = 0

    private var isExpanded: Bool {
        mapManager.stationDetailsSheetPosition == .expanded
    }

    var body: some View {
        VStack(spacing: 0) {
            StationDetailsSheetHeader(isSideSheet: true)

            if isExpanded {
                Divider()
                    .padding(.horizontal)

                ScrollView {
                    StationDetailsSheetContent()
                        .padding(.top, 8)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(width: 380)
        .frame(maxHeight: isExpanded ? .infinity : nil, alignment: .top)
        .panelGlassBackground()
        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 4)
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    let threshold: CGFloat = 60
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        if value.translation.height < -threshold {
                            mapManager.stationDetailsSheetPosition = .expanded
                        } else if value.translation.height > threshold {
                            if isExpanded {
                                mapManager.stationDetailsSheetPosition = .collapsed
                            }
                        }
                        dragOffset = 0
                    }
                }
        )
        .transition(.move(edge: .leading).combined(with: .opacity))
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: mapManager.stationDetailsSheetPosition)
        .onAppear {
            if mapManager.stationDetailsSheetPosition == .collapsed {
                return
            }
            mapManager.stationDetailsSheetPosition = .expanded
        }
    }
}

fileprivate struct PanelGlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: 24))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

fileprivate extension View {
    func panelGlassBackground() -> some View {
        modifier(PanelGlassBackground())
    }
}
