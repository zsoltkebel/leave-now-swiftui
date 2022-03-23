//
//  MapManager.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 23/03/2022.
//

import Foundation
import MapKit

struct MapManager {
    static public func searchPublicTransport(stop: Stop, completionHandler: @escaping MKLocalSearch.CompletionHandler) {
        // TODO: is this the most efficient way to find the bus stop at coordinate?
        // Reverse geocoder didn't return desired mapItem
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "public transport"
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: stop.location, latitudinalMeters: CLLocationDistance(stop.accuracy), longitudinalMeters: CLLocationDistance(stop.accuracy))
        
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: completionHandler)
    }
    
    static public func openMap(stop: Stop) {
        searchPublicTransport(stop: stop) { response, error in
            guard let response = response else {
                return
            }
            print(response)
            
            if let suggestedMapItem = response.mapItems.min(by: { mi1, mi2 in
                (mi1.placemark.location?.distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude)))! < (mi2.placemark.location?.distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude)))!
            }) {
                // open maps
                let regionDistance:CLLocationDistance = 80
                let regionSpan = MKCoordinateRegion(center: suggestedMapItem.placemark.location!.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                suggestedMapItem.openInMaps(launchOptions: options)
            }
        }
    }
}
