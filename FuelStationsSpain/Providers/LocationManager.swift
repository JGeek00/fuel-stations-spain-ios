import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var firstLocation: CLLocation?
    
    // Last location is not published because it causes unwanted rerenders
    var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    init(mockData: Bool) {
        if mockData == true {
            authorizationStatus = .authorizedWhenInUse
            firstLocation = .init(latitude: Config.defaultCoordinates.latitude, longitude: Config.defaultCoordinates.longitude)
            lastLocation = .init(latitude: Config.defaultCoordinates.latitude, longitude: Config.defaultCoordinates.longitude)
        }
    }
    
    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if firstLocation == nil {
            self.firstLocation = location
        }
        self.lastLocation = location
    }
}
