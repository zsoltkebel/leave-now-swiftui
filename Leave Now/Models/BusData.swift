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
    let aimed_departure_time: String
    let expected_departure_time: String?
    
    enum CodingKeys: String, CodingKey {
        case line
        case lineName = "line_name"
        case direction
        case date
        case aimed_departure_time
        case expected_departure_time
    }
    
    func calculateMinutesTillDeparture() -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        guard let departureDate = dateFormatter.date(from: date + "T" + aimed_departure_time) else {
            return nil
        }
        let currentDate = Date()
        let distance = currentDate.distance(to: departureDate)
        return Int((distance / 60.0).rounded())
    }
}
