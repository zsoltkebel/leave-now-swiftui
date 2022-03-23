//
//  MapSnapshotView.swift
//  Leave Now
//
//  Created by Zsolt Kébel on 19/03/2022.
//

import SwiftUI
import MapKit

struct MapSnapshotView: View {
    
    let location: CLLocationCoordinate2D
    var span: CLLocationDegrees = 0.002
    
    @State private var snapshotImage: UIImage? = nil
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = snapshotImage {
                    Image(uiImage: image)
                } else {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
            }
            .background(Color(UIColor.tertiarySystemBackground))
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .onAppear {
                //            generateSnapshot(width: 80, height: 80)
                generateSnapshot(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        
        // The region the map should display.
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )
        
        // Map options.
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true
        mapOptions.pointOfInterestFilter = MKPointOfInterestFilter(including: [])
        
        // Create the snapshotter and run it.
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                print(error)
                return
            }
            
            if let snapshot = snapshotOrNil {
                // annotation
                let image = UIGraphicsImageRenderer(size: mapOptions.size).image { _ in
                    snapshot.image.draw(at: .zero)
                    
                    let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                    let pinImage = pinView.image
                    
                    var point = snapshot.point(for: self.location)
                    
                    let finalImageRect = CGRect(x: 0, y: 0, width: width, height: height);
                    if finalImageRect.contains(point) {
                        point.x -= pinView.bounds.width / 2
                        point.y -= pinView.bounds.height / 2
                        point.x += pinView.centerOffset.x
                        point.y += pinView.centerOffset.y
                        pinImage?.draw(at: point)
                    }
                }
                
                //                self.snapshotImage = snapshot.image
                self.snapshotImage = image
            }
        }
    }
}

struct MapSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        MapSnapshotView(location: CLLocationCoordinate2D(latitude: 57.145224, longitude: -2.101817))
    }
}
