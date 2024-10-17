import SwiftUI
import AlertToast
import BottomSheet

struct StationDetailsSheetHeader: View {
    var isSideSheet: Bool
    
    init(isSideSheet: Bool) {
        self.isSideSheet = isSideSheet
    }
    
    @EnvironmentObject private var mapManager: MapManager
    @Environment(LocationManager.self) private var locationManager
    @Environment(FavoritesProvider.self) private var favoritesProvider
    @Environment(ToastProvider.self) private var toastProvider
    
    var body: some View {
        if let station = mapManager.selectedStation {
            HStack {
                if let name = station.signage {
                    Text(verbatim: name.capitalized)
                        .fontSize(30)
                        .fontWeight(.bold)
                        .truncationMode(.tail)
                        .lineLimit(1)
                }
                Spacer()
                if let stationId = station.id {
                    StationDetailsComponents.FavoriteButton(station: station)
                }
                if isSideSheet == false {
                    Button {
                        mapManager.showStationDetailsSheet = false
                        mapManager.selectedStationAnimation = nil
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
                else {
                    Button {
                        if mapManager.stationDetailsSheetPosition == .dynamicTop {
                            mapManager.stationDetailsSheetPosition = .absoluteTop(70)
                        }
                        else {
                            mapManager.stationDetailsSheetPosition = .dynamicTop
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                            .fontWeight(.semibold)
                            .foregroundColor(.foreground.opacity(0.5))
                            .padding(4.5)
                            .rotationEffect(mapManager.stationDetailsSheetPosition == .dynamicTop ? .degrees(0) : .degrees(180), anchor: .center)
                            .animation(.default, value: mapManager.stationDetailsSheetPosition)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
            }
            .padding(.top)
            .padding(.horizontal)
        }
    }
    
}

struct StationDetailsSheetContent: View {

    @EnvironmentObject private var mapManager: MapManager
    @Environment(LocationManager.self) private var locationManager
    @Environment(FavoritesProvider.self) private var favoritesProvider
    @Environment(ToastProvider.self) private var toastProvider
    
    @State private var showHistoricPricesSheet = false
    @State private var showHowToReachSheet = false
    
    var body: some View {
        if let station = mapManager.selectedStation {
            VStack(alignment: .leading, spacing: 12) {
                if let address = station.address {
                    let distanceText: String? = {
                        if station.latitude != nil && station.longitude != nil && locationManager.lastLocation?.coordinate.latitude != nil && locationManager.lastLocation?.coordinate.longitude != nil {
                            let distance = distanceBetweenCoordinates(Coordinate(latitude: station.latitude!, longitude: station.longitude!), Coordinate(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude))
                            if distance < 1 {
                                return String(localized: "\(Int(distance*1000)) m from your current location")
                            } else {
                                return String(localized: "\(formattedNumber(value: distance)) Km from your current location")
                            }
                        }
                        return nil
                    }()
                    
                    Button {
                        UIPasteboard.general.string = address.capitalized
                        toastProvider.showToast(icon: "document.on.document.fill", title: String(localized: "Address copied to the clipboard"))
                    } label: {
                        StationDetailsComponents.ListItem(
                            icon: "mappin",
                            iconColor: .red,
                            title: address.capitalized,
                            subtitle: distanceText
                        )
                        .customBackgroundWithMaterial()
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                    .buttonStyle(.plain)
                }
                if let locality = station.locality {
                    StationDetailsComponents.ListItem(
                        icon: "building.2.fill",
                        iconColor: .green,
                        title: String(localized: "Locality"),
                        subtitle: String(locality.capitalized)
                    )
                    .customBackgroundWithMaterial()
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                StationDetailsComponents.ScheduleItem(station: station)
                    .customBackgroundWithMaterial()
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                if let saleType = station.saleType {
                    StationDetailsComponents.ListItem(
                        icon: "person.fill",
                        iconColor: .purple,
                        title: String(localized: "Sales to the general public")
                    ) {
                        switch saleType {
                        case .p:
                            AnyView(
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Spacer()
                                        .frame(width: 4)
                                    Text("Yes")
                                }
                                .foregroundStyle(Color.green)
                                .fontSize(14)
                                .fontWeight(.medium)
                            )
                        case .r:
                            AnyView(
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Spacer()
                                        .frame(width: 4)
                                    Text("No")
                                }
                                .foregroundStyle(Color.red)
                                .fontSize(14)
                                .fontWeight(.medium)
                            )
                        }
                    }
                    .customBackgroundWithMaterial()
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                StationDetailsComponents.PricesItem(station: station)
                    .customBackgroundWithMaterial()
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                StationDetailsComponents.PriceScale(station: station)
                    .customBackgroundWithMaterial()
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                if let update = mapManager.data?.lastUpdated {
                    if let date = formatDate(update) {
                        StationDetailsComponents.ListItem(
                            icon: "arrow.down.circle.fill",
                            iconColor: .brown,
                            title: String(localized: "Latest information")
                        ) {
                            AnyView(
                                Text(date, format: .dateTime.weekday().day().hour().minute())
                                    .fontSize(14)
                                    .foregroundStyle(Color.gray)
                                    .fontWeight(.medium)
                            )
                        }
                        .customBackgroundWithMaterial()
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                }
                HStack {
                    Spacer()
                    Button {
                        showHowToReachSheet = true
                    } label: {
                        Label("How to get there", systemImage: "point.topleft.down.to.point.bottomright.curvepath.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(.rect(cornerRadius: 30))
                    Spacer()
                    Button {
                        showHistoricPricesSheet = true
                    } label: {
                        Label("Price history", systemImage: "chart.line.uptrend.xyaxis")
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    Spacer()
                }
                .padding(.top, 12)
            }
            .padding(.bottom)
            .padding(.horizontal)
            .animation(.easeOut, value: mapManager.selectedStation)
            .transition(.opacity)
            .sheet(isPresented: $showHistoricPricesSheet) {
                NavigationStack {
                    ServiceStationHistoric(station: station, showingInSheet: true)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    showHistoricPricesSheet = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.foreground.opacity(0.5))
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .clipShape(Circle())
                            }
                        }
                }
            }
            .sheet(isPresented: $showHowToReachSheet) {
                NavigationStack {
                    HowToReachStation(station: station)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    showHowToReachSheet = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.foreground.opacity(0.5))
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .clipShape(Circle())
                            }
                        }
                }
            }
        }
    }
}
