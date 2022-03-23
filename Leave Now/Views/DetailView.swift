//
//  DetailView.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 19/03/2022.
//

import SwiftUI
import CoreLocation
import MapKit

struct DetailView: View {
    
    let stop: Stop
    @State var favorite: Bool = false
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion()
    
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        List {
            Section(header: Text("Info")) {
                Text(stop.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(stop.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                //                .background(Color.red)
                //                .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            
            Section(header: Text("Departures")) {
                if (!networkManager.departures.isEmpty) {
                    ForEach(networkManager.departures) { departure in
                        DepartureRow(departure: departure, live: departure.calculateMinutesTillDeparture()! <= 15)
                    }
                } else {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
            }
            
            
            Section {
                Map(coordinateRegion: $region, interactionModes: [], showsUserLocation: true, userTrackingMode: .constant(.none), annotationItems: [MapLocation(stop: stop)]) { item in
                    MapMarker(coordinate: stop.location)
                }
                .frame(height: 300)
                .listRowInsets(EdgeInsets())
                .onTapGesture {
                    MapManager.openMap(stop: stop)
                }
            } header: {
                Text("Map")
            }
        }
        .onAppear {
            print("called")
            print("bus stop code: \(stop.atcocode)")
            networkManager.fetchDeparturesData(of: stop.atcocode)
            print(networkManager.departures)
            
            // set up for map view
            let meters = (CLLocationManager().location?.distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude)) ?? 300) * 2 * 1.3
            region = MKCoordinateRegion(center: CLLocationManager().location!.coordinate, latitudinalMeters: meters, longitudinalMeters: meters)
        }
        .onAppear(perform: {
            networkManager.departures.removeAll()
        })
        .navigationTitle("Stop")
        .refreshable {
            await networkManager.fetchDepartures(of: stop.atcocode)
        }
        .navigationBarItems(trailing:
                                Button(action: toggleFavorite) {
            Image(systemName: favorite ? "star.fill" : "star")
        })
    }
    
    func toggleFavorite() {
        favorite.toggle()
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard
        
        // Create and Write Array of Strings
        var favorites = userDefaults.stringArray(forKey: "favorite_stops") ?? []
        if (favorite) {
            if !favorites.contains(where: { s in
                return s == stop.atcocode
            }) {
                favorites.append(stop.atcocode)
            }
        } else {
            favorites.removeAll(where: { s in
                return s == stop.atcocode
            })
        }
        
        userDefaults.set(favorites, forKey: "favorite_stops")
        print(favorites)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(stop: Stop(atcocode: "639002262", latitude: 0.0, longitude: 0.0, accuracy: 0, name: "", description: "", distance: 14), networkManager: NetworkManager())
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let stop: Stop
}
