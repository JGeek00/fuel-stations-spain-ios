import SwiftUI

fileprivate struct StationWithDistance: Hashable {
    let station: FuelStation
    let distance: Double?
    
    init(station: FuelStation, distance: Double?) {
        self.station = station
        self.distance = distance
    }
}

struct StationsSheet: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        NavigationStack {
            Group {
                if mapViewModel.loading {
                    ProgressView()
                }
                else {
                    if let data = mapViewModel.data?.results {
                        let dataWithDistances: [StationWithDistance] = data.map() { item in
                            if item.latitude != nil && item.longitude != nil && locationManager.lastLocation?.coordinate.latitude != nil && locationManager.lastLocation?.coordinate.longitude != nil {
                                let distance = distanceBetweenCoordinates(Coordinate(latitude: item.latitude!, longitude: item.longitude!), Coordinate(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude))
                                return StationWithDistance(station: item, distance: distance)
                            }
                            else {
                                return StationWithDistance(station: item, distance: nil)
                            }
                        }.sorted { a, b in
                            if a.distance != nil && b.distance != nil {
                                return a.distance! < b.distance!
                            }
                            else if a.distance == nil && b.distance != nil {
                                return true
                            }
                            else if a.distance != nil && b.distance == nil {
                                return false
                            }
                            else {
                                return false
                            }
                        }
                        List(dataWithDistances, id: \.self) { item in
                            Button {
                                mapViewModel.showStationsSheet.toggle()
                                // await to prevent opening a sheet with another one already open
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                    mapViewModel.selectStation(station: item.station, centerLocation: true)
                                    Task {
                                        await mapViewModel.fetchData(latitude: item.station.latitude!, longitude: item.station.longitude!)
                                    }
                                })
                            } label: {
                                VStack(alignment: .leading) {
                                    if let signage = item.station.signage {
                                        Text(signage.capitalized)
                                            .font(.system(size: 18))
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                        .frame(height: 4)
                                    if let distance = item.distance {
                                        if distance < 1 {
                                            Text("\(Int(distance*1000)) m from your current location")
                                                .font(.system(size: 14))
                                        } else {
                                            Text("\(formattedNumber(value: distance)) Km from your current location")
                                                .font(.system(size: 14))
                                        }
                                    }
                                }
                                .foregroundStyle(Color.foreground)
                            }
                        }
                    }
                    else {
                        ContentUnavailableView("Data unavailable", systemImage: "exclamationmark.circle.fill", description: Text("Nearby stations couldn't be loaded due to an error."))
                    }
                }
            }
            .navigationTitle("Nearby service stations")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        mapViewModel.showStationsSheet.toggle()
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
