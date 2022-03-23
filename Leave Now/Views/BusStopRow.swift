//
//  BusStopRow.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 28/02/2022.
//

import SwiftUI
import MapKit

struct BusStopRow: View {
    var stop: Stop
    
    var body: some View {
        HStack {
            MapSnapshotView(location: CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude))
                .frame(width: 90, height: 90)
                .cornerRadius(10.0)
            //                .onTapGesture {
            //                    let regionDistance:CLLocationDistance = 1000
            //                    let coordinates = CLLocationCoordinate2DMake(stop.latitude, stop.longitude)
            //                    let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            //                    let options = [
            //                        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            //                        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            //                    ]
            //                    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            //                    let mapItem = MKMapItem(placemark: placemark)
            //                    mapItem.name = "stop"
            //                    mapItem.openInMaps(launchOptions: options)
            //                }
                .onTapGesture {
                    searchPublicTransport { response, error in
                        guard let response = response else {
                            return
                        }
                        print(response)
                        
                        if let suggestedMapItem = response.mapItems.first {
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
            Text(stop.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(String(stop.distance))
        }
    }
    
    public func searchPublicTransport(completionHandler: @escaping MKLocalSearch.CompletionHandler) {
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
}

struct BusStopRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BusStopRow(stop: Stop(atcocode: "", latitude: 0.0, longitude: 0.0, accuracy: 0, name: "Music Hall (Stop C4) - SW-bound", description: "", distance: 14))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
