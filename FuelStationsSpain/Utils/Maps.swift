import Foundation
import MapKit

func openInAppleMaps(sourceLatitude: Double, sourceLongitude: Double, destinationLatitude: Double, destinationLongitude: Double, stationName: String) {
    let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: sourceLatitude, longitude: sourceLongitude)))
    source.name = String(localized: "Your position")
            
    let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)))
    destination.name = stationName
            
    MKMapItem.openMaps(
      with: [source, destination],
      launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    )
}
