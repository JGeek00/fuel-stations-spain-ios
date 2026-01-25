import SwiftUI
import MapKit

struct MapOverlayRightButtons: View {
    var mapScope: Namespace.ID
    
    init(mapScope: Namespace.ID) {
        self.mapScope = mapScope
    }
    
    @EnvironmentObject private var mapManager: MapManager
    @EnvironmentObject private var locationManager: LocationManager
    
    @Namespace private var unionNamespace
    
    var body: some View {
        if #available(iOS 26.0, *) {
            VStack {
                GlassEffectContainer {
                    VStack {
                        Button {
                            withAnimation(.easeOut) {
                                mapManager.centerToLocation(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude)
                            }
                        } label: {
                            Image(systemName: "location.fill.viewfinder")
                                .fontSize(22)
                                .padding(.top, 8)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: "mapOptions", namespace: unionNamespace)
                        .disabled(locationManager.lastLocation == nil)
                        
                        Button {
                            mapManager.showStationDetailsSheet = false
                            mapManager.stationDetailsSheetPosition = .hidden
                            mapManager.selectedStationAnimation = nil
                            mapManager.selectedStation = nil
                            mapManager.showStationsSheet = true
                        } label: {
                            Image(systemName: "list.bullet")
                                .fontSize(22)
                                .padding(.bottom, 8)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: "mapOptions", namespace: unionNamespace)
                    }
                }
                Spacer()
                    .frame(height: 12)
                
                MapCompass(scope: mapScope)
            }
            .offset(x: -12, y: 12)
        }
        else {
            VStack {
                Button {
                    withAnimation(.easeOut) {
                        mapManager.centerToLocation(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude)
                    }
                } label: {
                    Image(systemName: "location.fill.viewfinder")
                        .fontSize(22)
                        .foregroundStyle(locationManager.lastLocation != nil ? Color.foreground : Color.gray)
                        .contentShape(Rectangle())
                }
                .disabled(locationManager.lastLocation == nil)
                .frameDynamicSize(width: 40, height: 40)
                .background(.regularMaterial)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3), radius: 5)
                
                Spacer()
                    .frame(height: 12)
                
                Button {
                    mapManager.showStationDetailsSheet = false
                    mapManager.stationDetailsSheetPosition = .hidden
                    mapManager.selectedStationAnimation = nil
                    mapManager.selectedStation = nil
                    mapManager.showStationsSheet = true
                } label: {
                    Image(systemName: "list.bullet")
                        .fontSize(22)
                        .foregroundStyle(Color.foreground)
                        .contentShape(Rectangle())
                }
                .frameDynamicSize(width: 40, height: 40)
                .background(.regularMaterial)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3), radius: 5)
                
                Spacer()
                    .frame(height: 12)
                
                MapCompass(scope: mapScope)
            }
            .offset(x: -12, y: 12)
        }
    }
}
