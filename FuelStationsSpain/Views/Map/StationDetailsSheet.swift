import SwiftUI
import MapKit
import AlertToast
import BottomSheet

struct StationDetailsSheetHeader: View {
    var isSideSheet: Bool
    
    init(isSideSheet: Bool) {
        self.isSideSheet = isSideSheet
    }
    
    @EnvironmentObject private var mapManager: MapManager
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var toastProvier: ToastProvider
    
    var body: some View {
        if let station = mapManager.selectedStation {
            HStack {
                if let name = station.signage {
                    Text(verbatim: name.capitalized)
                        .fontSize(32)
                        .fontWeight(.bold)
                        .truncationMode(.tail)
                        .lineLimit(1)
                }
                Spacer()
                StationDetailsFavoriteButton(station: station)
                if isSideSheet == false {
                    CloseButton {
                        mapManager.showStationDetailsSheet = false
                        mapManager.selectedStationAnimation = nil
                    }
                }
                else {
                    ChevronButton {
                        if mapManager.stationDetailsSheetPosition == .dynamicTop {
                            mapManager.stationDetailsSheetPosition = .absoluteTop(70)
                        }
                        else {
                            mapManager.stationDetailsSheetPosition = .dynamicTop
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func CloseButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .fontWeight(.semibold)
                .padding(4)
                .condition { view in
                    if #available(iOS 26.0, *) {
                        view
                    } else {
                        view.foregroundColor(.foreground.opacity(0.5))
                    }
                }
        }
        .condition { view in
            if #available(iOS 26.0, *) {
                view.buttonStyle(.glass)
            }
            else {
                view.buttonStyle(BorderedButtonStyle())
            }
            
        }
        .clipShape(Circle())
    }
    
    @ViewBuilder
    func ChevronButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.up")
                .fontWeight(.semibold)
                .padding(4)
                .condition { view in
                    if #available(iOS 26.0, *) {
                        view
                    }
                    else {
                        view.foregroundColor(.foreground.opacity(0.5))
                    }
                }
                .rotationEffect(mapManager.stationDetailsSheetPosition == .dynamicTop ? .degrees(0) : .degrees(180), anchor: .center)
                .animation(.default, value: mapManager.stationDetailsSheetPosition)
        }
        .condition { view in
            if #available(iOS 26.0, *) {
                view.buttonStyle(.glass)
            }
            else {
                view.buttonStyle(BorderedButtonStyle())
            }
            
        }
        .clipShape(Circle())
    }
}

struct StationDetailsSheetContent: View {
    var width: Double
    
    init(width: Double) {
        self.width = width
    }
    

    @EnvironmentObject private var mapManager: MapManager
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var toastProvider: ToastProvider
    
    @AppStorage(StorageKeys.showStationSummary, store: UserDefaults.shared) private var showStationSummary = Defaults.showStationSummary
    
    @State private var showHistoricPricesSheet = false
    @State private var showHowToReachSheet = false
    @State private var lookAroundScene: MKLookAroundScene? = nil
    @State private var pricesScaleItems: [PriceScaleItem]? = nil
    
    var body: some View {
        if let station = mapManager.selectedStation {
            let formattedSchedule = getStationSchedule(station.openingHours!)
            let distanceToUserLocation: Double? = {
                if station.latitude != nil && station.longitude != nil && locationManager.lastLocation?.coordinate.latitude != nil && locationManager.lastLocation?.coordinate.longitude != nil {
                    let distance = distanceBetweenCoordinates(Coordinate(latitude: station.latitude!, longitude: station.longitude!), Coordinate(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude))
                    return distance
                }
                return nil
            }()
            
            VStack(alignment: .leading) {
                if showStationSummary {
                    StationDetailsSummary(width: width, station: station, schedule: formattedSchedule, distanceToLocation: distanceToUserLocation)
                        .cardGlassBackgroundIfAvailable()
                
                    Divider()
                        .padding(.vertical)
                    
                    Text("Details")
                        .fontSize(22)
                        .fontWeight(.semibold)
                }
                
                LazyVStack(alignment: .leading, spacing: 12) {
                    if let address = station.address {
                        let distanceText: String? = {
                            if let distance = distanceToUserLocation {
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
                            StationDetailsListItem(
                                icon: "mappin",
                                iconColor: .red,
                                title: address.capitalized,
                                subtitle: distanceText
                            )
                            .cardGlassBackgroundIfAvailable()
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if let locality = station.locality {
                        StationDetailsListItem(
                            icon: "building.2.fill",
                            iconColor: .green,
                            title: String(localized: "Locality"),
                            subtitle: String(locality.capitalized)
                        )
                        .cardGlassBackgroundIfAvailable()
                    }
                    
                    StationDetailsScheduleItem(station: station, schedule: formattedSchedule, alwaysExpanded: showStationSummary)
                        .cardGlassBackgroundIfAvailable()
                    
                    if let saleType = station.saleType {
                        StationDetailsListItem(
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
                        .cardGlassBackgroundIfAvailable()
                    }
                    
                    StationDetailsPricesItem(station: station)
                        .cardGlassBackgroundIfAvailable()
                    
                    StationDetailsPriceScale(station: station, priceScaleItems: pricesScaleItems, alwaysExpanded: false)
                        .cardGlassBackgroundIfAvailable()
                    
                    StationDetailsMapItem(station: station, showOnlyLookAround: true, lookAroundScene: lookAroundScene) {}
                        .clipShape(.rect(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.1), radius: 16)
                    
                    if let update = mapManager.data?.lastUpdated {
                        if let date = formatDate(update) {
                            StationDetailsListItem(
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
                            .cardGlassBackgroundIfAvailable()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            showHowToReachSheet = true
                        } label: {
                            Label("How to get there", systemImage: "point.topleft.down.to.point.bottomright.curvepath.fill")
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .condition { view in
                            if #available(iOS 26.0, *) {
                                view.buttonStyle(.glassProminent)
                            }
                            else {
                                view.buttonStyle(.borderedProminent)
                            }
                        }
                        .clipShape(.rect(cornerRadius: 30))
                        Spacer()
                        Button {
                            showHistoricPricesSheet = true
                        } label: {
                            Label("Price history", systemImage: "chart.line.uptrend.xyaxis")
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .condition { view in
                            if #available(iOS 26.0, *) {
                                view.buttonStyle(.glassProminent)
                            }
                            else {
                                view.buttonStyle(.borderedProminent)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        Spacer()
                    }
                    .padding(.top, 12)
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            .animation(.easeOut, value: mapManager.selectedStation)
            .transition(.opacity)
            .onChange(of: station, initial: true) {
                DispatchQueue.global(qos: .background).async {
                    Task {
                        let result = await getLookAroundScene(latitude: station.latitude!, longitude: station.longitude!)
                        DispatchQueue.main.async {
                            lookAroundScene = result
                        }
                    }
                }
                if let nearbyStations = mapManager.data?.results {
                    DispatchQueue.global(qos: .background).async {
                        let pricesScale = calculatePriceScale(nearbyStations: nearbyStations, station: station)
                        DispatchQueue.main.async {
                            pricesScaleItems = pricesScale
                        }
                    }
                }
            }
            .sheet(isPresented: $showHistoricPricesSheet) {
                NavigationStack {
                    HistoricPricesView(station: station, showingInSheet: true)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                CloseButton {
                                    showHistoricPricesSheet = false
                                }
                            }
                        }
                }
            }
            .sheet(isPresented: $showHowToReachSheet) {
                NavigationStack {
                    HowToReachStation(station: station)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                CloseButton {
                                    showHowToReachSheet = false
                                }
                            }
                        }
                }
            }
        }
    }
}
