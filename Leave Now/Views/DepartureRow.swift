//
//  DepartureRow.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 23/03/2022.
//

import SwiftUI

struct DepartureRow: View {
    let departure: Departure
    var live: Bool = false
    
    @State var remainingMinutes: Int?
    @State var timer: Timer?  // for updating the time remaining if live

    var body: some View {
        HStack {
            Text(departure.line)
                .padding(6)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
            Text(departure.direction)
            Text(departure.aimed_departure_time)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(remainingMinutes == nil ? 1 : 0.4)
            if remainingMinutes != nil {
                Text(remainingMinutes! > 1 ? "\(remainingMinutes!) mins" : "\(remainingMinutes!) min")
                    .onAppear {
                        startTimer()
                    }
            }
        }
        .onAppear {
            if live {
                remainingMinutes = departure.calculateMinutesTillDeparture()
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        let interval = Double(Date().timeIntervalSinceReferenceDate)
        let delay = 60  - fmod(interval, 60.0)
        //        message.text = "Delay = \(delay)"
        print("delay: \(delay)")
        //Create a "one-off" timer that fires on the next even minute
        let _ = Timer.scheduledTimer(withTimeInterval: delay, repeats: false ) { timer in
            //          self.message.text = "\(Date())"
            print("timer started")
            remainingMinutes = departure.calculateMinutesTillDeparture()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true ) { timer in
                //Put your repeating code here.
                print("update time remaining")
                remainingMinutes = departure.calculateMinutesTillDeparture()
            }
        }
    }
}

struct DepartureRow_Previews: PreviewProvider {
    static var previews: some View {
        DepartureRow(departure: Departure(line: "", lineName: "", direction: "", date: "", aimed_departure_time: "", expected_departure_time: ""))
    }
}
