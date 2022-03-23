//
//  BusData.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 19/03/2022.
//

import Foundation

struct LiveResults: Decodable {
    let departures: [String: [Departure]]
}

struct Departure: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let line: String
    let lineName: String
    let direction: String
    let date: String
    let aimedDepartureTime: String
    let expectedDepartureTime: String?
    let bestDepartureEstimate: String
    
    enum CodingKeys: String, CodingKey {
        case line
        case lineName = "line_name"
        case direction
        case date
        case aimedDepartureTime = "aimed_departure_time"
        case expectedDepartureTime = "expected_departure_time"
        case bestDepartureEstimate = "best_departure_estimate"
    }
    
    func calculateMinutesTillDeparture() -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        guard let departureDate = dateFormatter.date(from: date + "T" + bestDepartureEstimate) else {
            return nil
        }
        let currentDate = Date()
        let distance = currentDate.distance(to: departureDate)
        return Int((distance / 60.0).rounded())
    }
    
    func displayMessage() -> String {
        let mins = calculateMinutesTillDeparture()!
        return mins > 1 ? "\(mins) mins" : (mins == 1 ? "\(mins) min" : "Due")
    }
}
