//
//  NetworkManager.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 19/03/2022.
//

import Foundation
import CoreLocation

class NetworkManager: ObservableObject {
    
    let appId: String
    let appKey: String
    
    @Published var stops = [Stop]()
    @Published var departures = [Departure]()
    
    init() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            if let keys = NSDictionary(contentsOfFile: path) {
                appId = keys["transportapi_app_id"] as! String
                appKey = keys["transportapi_app_key"] as! String
                return
            }
        }
        fatalError("No app id and/or app key found for transportapi. Make sure to create keys.plist with those keys.")
    }
    
    func fetchStopsData(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        if let url = URL(string: "https://transportapi.com/v3/uk/places.json?lat=\(lat)&lon=\(lon)&type=bus_stop&app_id=\(appId)&app_key=\(appKey)") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error == nil {
                    if let safeData = data {
                        do {
                            let decoder = JSONDecoder()
                            let results = try decoder.decode(Results.self, from: safeData)
                            print(results.member)
                            print("https://transportapi.com/v3/uk/bus/stop/639002262/live.json?app_id=\(self.appId)&app_key=\(self.appKey)")
                            DispatchQueue.main.async {
                                self.stops = results.member.sorted(by: { s1, s2 in
                                    return s1.distance < s2.distance
                                })
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func fetchDeparturesData(of atcocode: String) {
        if let url = URL(string: "https://transportapi.com/v3/uk/bus/stop/\(atcocode)/live.json?app_id=\(appId)&app_key=\(appKey)") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error == nil {
                    if let safeData = data {
                        do {
                            print(url)
                            let decoder = JSONDecoder()
                            let results = try decoder.decode(LiveResults.self, from: safeData)
                            //                            print(results.departures)
                            DispatchQueue.main.async {
                                self.departures = results.departures.values.flatMap({ departures in
                                    departures
                                }).sorted(by: { d1, d2 in
                                    return d1.aimed_departure_time < d2.aimed_departure_time
                                })
                                print("array comiung now")
                                print(self.departures)
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func fetchStops(lat: CLLocationDegrees, lon: CLLocationDegrees) async {
        if let url = URL(string: "https://transportapi.com/v3/uk/places.json?lat=\(lat)&lon=\(lon)&type=bus_stop&app_id=\(appId)&app_key=\(appKey)") {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let results = try JSONDecoder().decode(Results.self, from: data)
                
                DispatchQueue.main.async {
                    self.stops = results.member.sorted(by: { s1, s2 in
                        return s1.distance < s2.distance
                    })
                }
                
                print("Stops data fetched:")
                print(self.stops)
            } catch {
                print(error)
            }
        }
    }
    
    func fetchDepartures(of atcocode: String) async {
        if let url = URL(string: "https://transportapi.com/v3/uk/bus/stop/\(atcocode)/live.json?app_id=\(appId)&app_key=\(appKey)") {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let results = try JSONDecoder().decode(LiveResults.self, from: data)
                
                DispatchQueue.main.async {
                    self.departures = results.departures.values.flatMap({ departures in
                        departures
                    }).sorted(by: { d1, d2 in
                        return d1.aimed_departure_time < d2.aimed_departure_time
                    })
                }
                
                print("Departures data fetched:")
                print(self.departures)
            } catch {
                print(error)
            }
        }
    }
}
