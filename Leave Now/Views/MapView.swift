//
//  MapView.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 23/03/2022.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject var managerDelegate: LocationDelegate = LocationDelegate()
    
    let stops: [Stop]
    
    var body: some View {
        Map(coordinateRegion: $managerDelegate.region, interactionModes: [], showsUserLocation: true, userTrackingMode: .constant(.none), annotationItems: managerDelegate.markers) { pin in
            MapMarker(coordinate: pin.location.coordinate)
        }.onAppear {
            managerDelegate.set(stops: stops)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(stops: [])
    }
}


class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var markers : [Pin] = []
    
    @Published var location: CLLocation?
        
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.898150, longitude: -77.034340),
        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    )
    
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        
        manager.delegate = self
    }
    
    func set(stops: [Stop]) {
        markers = stops.map({ stop in
            Pin(location: stop.location)
        })
        calculate()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .authorizedWhenInUse{
            print("Authorized")
            manager.startUpdatingLocation()
        } else {
            print("not authorized")
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
            print("updating location")
            self.location = location
            
            calculate()
        }
    }
    
    func calculate() {
        if let location = location {
            let maxDistance = (markers.map({ pin in
                location.distance(from: pin.location) * 2 * 1.3
            }).max()) ?? 300
            
            let distance = markers.last!.location.distance(from: location)
            print("distance: \(distance)")
            //            self.region = MKCoordinateRegion(center: pins.first!.location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
            self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: maxDistance, longitudinalMeters: maxDistance)
            print("max distance: \(maxDistance)")
            print("region set: \(region)")
            
            //            self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        }
        
        
    }
}

// Map pins for update
struct Pin : Identifiable {
    var id = UUID().uuidString
    var location : CLLocation
}
