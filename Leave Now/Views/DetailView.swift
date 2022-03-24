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
    
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        List {
            Section {
                MapView(stops: [stop])
                .frame(height: 200)
                .listRowInsets(EdgeInsets())
                .onTapGesture {
                    MapManager.openMap(stop: stop)
                }
            } header: {
                Text("Map")
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
            
            Section(header: Text("Info")) {
                Text(stop.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(stop.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            print("called")
            print("bus stop code: \(stop.atcocode)")
            networkManager.fetchDeparturesData(of: stop.atcocode)
            print(networkManager.departures)
        }
        .onAppear(perform: {
            networkManager.departures.removeAll()
        })
        .navigationTitle(stop.shortName ?? "Stop")
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
