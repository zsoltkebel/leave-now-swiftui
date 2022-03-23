//
//  ContentView.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 28/02/2022.
//
import CoreLocation
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var networkManager = NetworkManager()
    
    // atcocodes
    var favorites: [String] {
        return UserDefaults.standard.stringArray(forKey: "favorite_stops") ?? []
    }
    
    @State var favStops = [Stop]()
    
    var body: some View {
        NavigationView {
            if let location = locationManager.location {
                Group {
                    if (networkManager.stops.isEmpty) {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    }
                    else {
                        List {
                            if !networkManager.stops.filter({ stop in
                                return self.favorites.contains(stop.atcocode)
                            }).isEmpty {
                                Section(header: Text("Favourites")) {
                                    ForEach(networkManager.stops.filter({ stop in
                                        return self.favorites.contains(stop.atcocode)
                                    })) { stop in
                                        NavigationLink(destination: DetailView(stop: stop, favorite: true, networkManager: networkManager)) {
                                            BusStopRow(stop: stop)
                                        }
                                    }
                                    
                                }
                            }
                            
                            Section(header: Text("All")) {
                                ForEach(networkManager.stops) { stop in
                                    NavigationLink(destination: DetailView(stop: stop, favorite: self.favorites.contains(stop.atcocode), networkManager: networkManager)) {
                                        BusStopRow(stop: stop)
                                    }
                                }
                                
                            }
                            
                        }
                        .refreshable {
                            locationManager.requestLocation()
                            await networkManager.fetchStops(lat: location.latitude, lon: location.longitude)
                        }
                        .onAppear {
                            networkManager.fetchStopsData(lat: location.latitude, lon: location.longitude)
                        }
                    }
                }
                .navigationBarTitle(Text("Nearby"))
                .onAppear {
                    locationManager.requestLocation()
                    networkManager.fetchStopsData(lat: location.latitude, lon: location.longitude)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
