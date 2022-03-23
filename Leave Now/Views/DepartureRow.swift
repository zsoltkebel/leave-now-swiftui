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
    
    @State var trailingMessage: String?
    @State var timer: Timer?  // for updating the time remaining if live
    
    var body: some View {
        HStack {
            Text(departure.line)
                .padding(6)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
            Text(departure.direction)
            Text(departure.bestDepartureEstimate)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(trailingMessage == nil ? 1 : 0.4)
            if trailingMessage != nil {
                Text(trailingMessage!)
                    .onAppear {
                        startTimer()
                    }
            }
        }
        .onAppear {
            if live {
                updateMessage()
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        // calculate delay till next full minute
        let interval = Double(Date().timeIntervalSinceReferenceDate)
        let delay = 60  - fmod(interval, 60.0)
        print("delay: \(delay)")
        //Create a "one-off" timer that fires on the next minute
        let _ = Timer.scheduledTimer(withTimeInterval: delay, repeats: false ) { timer in
            print("timer started")
            updateMessage()
            self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true ) { timer in
                //Put your repeating code here.
                print("update time remaining")
                updateMessage()
            }
        }
    }
    
    func updateMessage() {
        trailingMessage = departure.displayMessage()
    }
}

struct DepartureRow_Previews: PreviewProvider {
    static var previews: some View {
        DepartureRow(departure: Departure(line: "", lineName: "", direction: "", date: "", aimedDepartureTime: "", expectedDepartureTime: "", bestDepartureEstimate: ""))
    }
}
