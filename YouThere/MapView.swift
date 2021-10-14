//
//  MapView.swift
//  YouThere
//
//  Created by Jake King on 21/09/2021.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    var centerCoordinate: CLLocationCoordinate2D
    @Binding var contactLocationPin: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType,
                      context: Context) {
        if annotations.count != uiView.annotations.count {
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(annotations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject,
                       MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        //we want to recycle views where possible becuase creating them is expensive
        func mapView(_ mapView: MKMapView,
                     viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            //this is our unique identifier for view reuse
            let identifier = "Placemark"
            
            //attempt to find a cell we can recycle
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                //we need to make a new one
                annotationView = MKPinAnnotationView(annotation: annotation,
                                                     reuseIdentifier: identifier)
                
                //allow this to show pop up information
                annotationView?.canShowCallout = true
                
                //attach an information button to the view
//                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                //we have a view to reuse, so give it the new annotation
                annotationView?.annotation = annotation
            }
            
            //whether it's a new view or a recycled one, send it back
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView,
                     annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? MKPointAnnotation else {
                return
            }
            
            parent.contactLocationPin = placemark
            parent.showingPlaceDetails = true
        }
    }
}
//to ensure the MapView_Previews struct doesn't break
extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "Example Location"
        annotation.subtitle = "Example description of Example Location."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 49.5,
                                                       longitude: -0.04)
        return annotation
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(centerCoordinate: CLLocationCoordinate2D(),
                contactLocationPin: .constant(MKPointAnnotation.example),
                showingPlaceDetails: .constant(false),
                annotations: [MKPointAnnotation.example])
    }
}

