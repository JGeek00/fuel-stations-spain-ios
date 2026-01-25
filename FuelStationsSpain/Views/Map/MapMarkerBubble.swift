import SwiftUI

struct MapMarkerBubble: View {
    var value: FuelStation
    
    init(_ value: FuelStation) {
        self.value = value
    }
    
    @EnvironmentObject private var mapManager: MapManager
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @AppStorage(StorageKeys.closedStationsShowMethod, store: UserDefaults.shared) private var closedStationsShowMethod: Enums.ClosedStationsMode = Defaults.closedStationsShowMethod
    @AppStorage(StorageKeys.showRedClockClosedStations, store: UserDefaults.shared) private var showRedClockClosedStations = Defaults.showRedClockClosedStations
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    
    @State private var formattedSchedule: OpeningSchedule?
    
    var body: some View {
        let fuelPrice: Double? = FuelStation.getObjectProperty(station: value, propertyName: "\(favoriteFuel.rawValue)Price")
        Group {
            if !(formattedSchedule?.isCurrentlyOpen == false && closedStationsShowMethod == .hideCompletely) {
                if favoriteFuel != .none, let fuelPrice = fuelPrice {
                    PriceMarker()
                        .foregroundStyle(Color.background)
                        .frameDynamicSize(width: 60, height: 34)
                        .overlay(alignment: .center) {
                            Text(verbatim: "\(formattedNumber(value: fuelPrice, digits: 3))€")
                                .fontSize(14)
                                .fontWeight(.semibold)
                                .padding(.bottom, 30*0.2)
                        }
                        .overlay(PriceMarker().stroke(Color.gray, lineWidth: 0.5))
                        .overlay(alignment: .topTrailing, content: {
                            if formattedSchedule?.isCurrentlyOpen == false && showRedClockClosedStations == true {
                                RedClock()
                            }
                        })
                        .opacity(formattedSchedule?.isCurrentlyOpen == false && closedStationsShowMethod == .showDimmed ? 0.5 : 1)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                        .scaleEffect(value.id == mapManager.selectedStationAnimation?.id ? 1.5 : 1, anchor: .bottom)
                        .animation(.bouncy(extraBounce: 0.2), value: mapManager.selectedStationAnimation?.id)
                        .onTapGesture {
                            mapManager.selectStation(station: value)
                        }
                }
                else {
                    NormalMarker()
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.markerGradientStart, Color.markerGradientEnd]), startPoint: .top, endPoint: .bottom))
                        .frameDynamicSize(width: 30, height: 30)
                        .overlay(alignment: .topTrailing, content: {
                            if formattedSchedule?.isCurrentlyOpen == false && showRedClockClosedStations == true {
                                RedClock()
                            }
                        })
                        .opacity(formattedSchedule?.isCurrentlyOpen == false && closedStationsShowMethod == .showDimmed ? 0.5 : 1)
                        .scaleEffect(value.id == mapManager.selectedStationAnimation?.id ? 1.5 : 1, anchor: .bottom)
                        .animation(.bouncy(extraBounce: 0.2), value: mapManager.selectedStationAnimation?.id)
                        .onTapGesture {
                            mapManager.selectStation(station: value)
                        }
                }
            }
        }
        .onAppear {
            formattedSchedule = value.openingHours != nil ? getStationSchedule(value.openingHours!) : nil
        }
    }
    
    @ViewBuilder
    private func RedClock() -> some View {
        Circle()
            .offset(x: 6 * fontSizeMultiplier(for: dynamicTypeSize), y: -6 * fontSizeMultiplier(for: dynamicTypeSize))
            .frameDynamicSize(width: 15, height: 15)
            .foregroundStyle(Color.background)
            .overlay(alignment: .center) {
                Image(systemName: "clock.fill")
                    .offset(x: 6 * fontSizeMultiplier(for: dynamicTypeSize), y: -6 * fontSizeMultiplier(for: dynamicTypeSize))
                    .foregroundStyle(Color.red)
                    .fontSize(14)
            }
    }
    
}
