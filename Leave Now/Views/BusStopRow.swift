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
                .onTapGesture {
                    MapManager.openMap(stop: stop)
                }
            VStack {
                Text(stop.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                Text(stop.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
            }
        }
    }
}

struct BusStopRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BusStopRow(stop: Stop(atcocode: "", latitude: 0.0, longitude: 0.0, accuracy: 0, name: "Music Hall (Stop C4) - SW-bound", description: "Aberdeen", distance: 14))
        }
        .previewLayout(.fixed(width: 300, height: 90))
    }
}
