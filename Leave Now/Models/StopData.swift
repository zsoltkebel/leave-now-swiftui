//
//  StopData.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 19/03/2022.
//

import Foundation
import CoreLocation

struct Results: Decodable {
    let member: [Stop]
}

struct Stop: Decodable, Identifiable, Hashable {
    var id: String {
        return atcocode
    }
    let atcocode: String
    let latitude: Double
    let longitude: Double
    let accuracy: Int
    let name: String
    let description: String
    let distance: Int
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var shortName: String? {
        return name.components(separatedBy: " - ").first
    }
}
